// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Extracts code_gen Type from type.
library;

import '../../code_generator.dart';
import '../../context.dart';
import '../../strings.dart' as strings;
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../sub_parsers/compounddecl_parser.dart';
import '../sub_parsers/enumdecl_parser.dart';
import '../sub_parsers/function_type_param_parser.dart';
import '../sub_parsers/objc_block_parser.dart';
import '../sub_parsers/objcinterfacedecl_parser.dart';
import '../sub_parsers/objcprotocoldecl_parser.dart';
import '../sub_parsers/typedefdecl_parser.dart';
import '../type_extractor/cxtypekindmap.dart';
import '../utils.dart';

const _padding = '  ';

const maxRecursionDepth = 5;

/// Converts cxtype to a typestring code_generator can accept.
Type getCodeGenType(
  Context context,
  clang_types.CXType cxtype, {

  /// Cursor of the declaration, currently this is useful only to extract
  /// parameter names in function types.
  clang_types.CXCursor? originalCursor,
  bool supportNonInlineArray = false,
}) {
  context.logger.fine(
    '${_padding}getCodeGenType ${cxtype.completeStringRepr()}',
  );

  // Special case: Elaborated types just refer to another type.
  if (cxtype.kind == clang_types.CXTypeKind.CXType_Elaborated) {
    return getCodeGenType(context, clang.clang_Type_getNamedType(cxtype));
  }

  // These basic Objective C types skip the cache, and are conditional on the
  // language flag.
  if (context.config.objectiveC != null) {
    switch (cxtype.kind) {
      case clang_types.CXTypeKind.CXType_ObjCObjectPointer:
        final pt = clang.clang_getPointeeType(cxtype);
        final s = getCodeGenType(context, pt);
        if (s is ObjCInterface) {
          return s;
        }
        final numProtocols = clang.clang_Type_getNumObjCProtocolRefs(pt);
        if (numProtocols > 0) {
          final protocols = <ObjCProtocol>[];
          for (var i = 0; i < numProtocols; ++i) {
            final pdecl = clang.clang_Type_getObjCProtocolDecl(pt, i);
            final p = parseCursor(context, pdecl);
            if (p != null) protocols.add(p as ObjCProtocol);
          }
          if (protocols.isNotEmpty) {
            return ObjCObjectPointerWithProtocols(protocols);
          }
        }
        return PointerType(objCObjectType);
      case clang_types.CXTypeKind.CXType_ObjCId:
      case clang_types.CXTypeKind.CXType_ObjCTypeParam:
      case clang_types.CXTypeKind.CXType_ObjCClass:
        return PointerType(objCObjectType);
      case clang_types.CXTypeKind.CXType_ObjCSel:
        return PointerType(objCSelType);
      case clang_types.CXTypeKind.CXType_BlockPointer:
        return parseObjCBlock(context, cxtype);
    }
  }

  // If the type has a declaration cursor, then use the BindingsIndex to break
  // any potential cycles, and dedupe the Type.
  final cursor = clang.clang_getTypeDeclaration(cxtype);
  if (cursor.kind != clang_types.CXCursorKind.CXCursor_NoDeclFound) {
    return _createTypeFromCursor(context, cursor);
  }

  // If the type doesn't have a declaration cursor, then it's a basic type such
  // as int, or a simple derived type like a pointer, so doesn't need to be
  // cached.
  switch (cxtype.kind) {
    case clang_types.CXTypeKind.CXType_Pointer:
      final pt = clang.clang_getPointeeType(cxtype);
      final s = getCodeGenType(context, pt, originalCursor: originalCursor);

      // Replace Pointer<_Dart_Handle> with Handle.
      if (s is Struct && s.usr == strings.dartHandleUsr) {
        return HandleType();
      }
      return PointerType(s);
    case clang_types.CXTypeKind.CXType_FunctionProto:
      // Primarily used for function pointers.
      return _extractFromFunctionProto(context, cxtype, cursor: originalCursor);
    case clang_types.CXTypeKind.CXType_FunctionNoProto:
      // Primarily used for function types with zero arguments.
      return _extractFromFunctionProto(context, cxtype, cursor: originalCursor);
    case clang_types.CXTypeKind.CXType_ConstantArray:
      // Primarily used for constant array in struct members.
      final numElements = clang.clang_getNumElements(cxtype);
      final elementType = clang
          .clang_getArrayElementType(cxtype)
          .toCodeGenType(context, supportNonInlineArray: supportNonInlineArray);
      // Handle numElements being 0 as an incomplete array.
      return numElements == 0
          ? IncompleteArray(elementType)
          : ConstantArray(
              numElements,
              elementType,
              useArrayType: supportNonInlineArray,
            );
    case clang_types.CXTypeKind.CXType_IncompleteArray:
      // Primarily used for incomplete array in function parameters.
      return IncompleteArray(
        clang.clang_getArrayElementType(cxtype).toCodeGenType(context),
      );
    case clang_types.CXTypeKind.CXType_Bool:
      return BooleanType();
    case clang_types.CXTypeKind.CXType_Attributed:
    case clang_types.CXTypeKind.CXType_Unexposed:
      final innerType = getCodeGenType(
        context,
        clang.clang_Type_getModifiedType(cxtype),
        originalCursor: originalCursor,
      );
      final isNullable =
          clang.clang_Type_getNullability(cxtype) ==
          clang_types.CXTypeNullabilityKind.CXTypeNullability_Nullable;
      return isNullable && ObjCNullable.isSupported(innerType)
          ? ObjCNullable(innerType)
          : innerType;
    default:
      var typeSpellKey = clang
          .clang_getTypeSpelling(cxtype)
          .toStringAndDispose();
      if (typeSpellKey.startsWith('const ')) {
        typeSpellKey = typeSpellKey.replaceFirst('const ', '');
      }
      if (context.config.importedIntegers.containsKey(typeSpellKey)) {
        context.logger.fine('  Type $typeSpellKey mapped from type-map.');
        return context.config.importedIntegers[typeSpellKey]!;
      } else if (cxTypeKindToImportedTypes.containsKey(typeSpellKey)) {
        return cxTypeKindToImportedTypes[typeSpellKey]!;
      } else {
        context.logger.fine(
          'typedeclarationCursorVisitor: getCodeGenType: Type Not '
          'Implemented, ${cxtype.completeStringRepr()}',
        );
        return UnimplementedType('${cxtype.kindSpelling()} not implemented');
      }
  }
}

Type _createTypeFromCursor(Context context, clang_types.CXCursor cursor) {
  final usr = cursor.usr();
  final importedType = context.config.importedTypesByUsr[usr];
  if (importedType != null) {
    context.logger.fine('  Type $usr mapped from usr');
    return importedType;
  }

  final binding = parseCursor(context, cursor) as BindingType?;
  if (binding == null) {
    return UnimplementedType('Unknown type: ${cursor.completeStringRepr()}');
  }
  if (binding is EnumClass && binding.isOmitted) {
    return binding.nativeType;
  }
  return binding;

  switch (cxtype.kind) {
    case clang_types.CXTypeKind.CXType_Typedef:
      final spelling = clang.clang_getTypedefName(cxtype).toStringAndDispose();
      if (config.objectiveC != null && spelling == strings.objcBOOL) {
        // Objective C's BOOL type can be either bool or signed char, depending
        // on the platform. We want to present a consistent API to the user, and
        // those two types are ABI compatible, so just return bool regardless.
        return BooleanType();
      }
      if (config.typedefTypeMappings.containsKey(spelling)) {
        logger.fine('  Type $spelling mapped from type-map');
        return config.typedefTypeMappings[spelling]!;
      }
      // Get name from supported typedef name if config allows.
      if (config.typedefs.useSupportedTypedefs) {
        if (suportedTypedefToSuportedNativeType.containsKey(spelling)) {
          logger.fine('  Type Mapped from supported typedef');
          return NativeType(suportedTypedefToSuportedNativeType[spelling]!);
        } else if (supportedTypedefToImportedType.containsKey(spelling)) {
          logger.fine('  Type Mapped from supported typedef');
          return supportedTypedefToImportedType[spelling]!;
        }
      }

      final typealias = parseTypedefDeclaration(context, cursor);

      if (typealias != null) {
        return typealias;
      } else {
        // Use underlying type if typealias couldn't be created or if the user
        // excluded this typedef.
        final ct = clang.clang_getTypedefDeclUnderlyingType(cursor);
        return getCodeGenType(context, ct);
      }
  }
}

/*
void _fillFromCursorIfNeeded(
  Context context,
  Type? type,
  clang_types.CXCursor cursor,
) {
  if (type == null) return;
  if (type is Compound) {
    fillCompoundMembersIfNeeded(type, cursor, context);
  } else if (type is ObjCInterface) {
    fillObjCInterfaceMethodsIfNeeded(context, type, cursor);
  }
}
*/

// Used for function pointer arguments.
Type _extractFromFunctionProto(
  Context context,
  clang_types.CXType cxtype, {
  clang_types.CXCursor? cursor,
}) {
  final parameters = <Parameter>[];
  final totalArgs = clang.clang_getNumArgTypes(cxtype);
  for (var i = 0; i < totalArgs; i++) {
    final t = clang.clang_getArgType(cxtype, i);
    final pt = getCodeGenType(context, t);

    if (pt.isIncompleteCompound) {
      return UnimplementedType(
        'Incomplete Struct by value in function parameter.',
      );
    } else if (pt.baseType is UnimplementedType) {
      return UnimplementedType('Function parameter has an unsupported type.');
    }

    parameters.add(Parameter(name: '', type: pt, objCConsumed: false));
  }

  final functionType = FunctionType(
    parameters: parameters,
    returnType: clang.clang_getResultType(cxtype).toCodeGenType(context),
  );
  _parseAndMergeParamNames(context, functionType, cursor, maxRecursionDepth);
  return NativeFunc(functionType);
}

void _parseAndMergeParamNames(
  Context context,
  FunctionType functionType,
  clang_types.CXCursor? cursor,
  int recursionDepth,
) {
  if (cursor == null) {
    return;
  }
  if (recursionDepth == 0) {
    final cursorRepr = cursor.completeStringRepr();
    context.logger.warning(
      'Recursion depth exceeded when merging function parameters.'
      ' Last cursor encountered was $cursorRepr',
    );
    return;
  }

  final paramsInfo = parseFunctionPointerParamNames(cursor);
  functionType.addParameterNames(paramsInfo.paramNames);

  for (final param in functionType.parameters) {
    final paramRealType = param.type.typealiasType;
    final paramBaseType = paramRealType.baseType.typealiasType;
    if (paramBaseType is NativeFunc && param.originalName.isNotEmpty) {
      final paramFunctionType = paramBaseType.type;
      final paramCursor = paramsInfo.params[param.originalName];
      _parseAndMergeParamNames(
        context,
        paramFunctionType,
        paramCursor,
        recursionDepth - 1,
      );
    }
  }
}
