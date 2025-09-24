// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Extracts code_gen Type from type.
library;

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
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

  /// Passed on if a value was marked as a pointer before this one.
  bool pointerReference = false,

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
    return getCodeGenType(
      context,
      clang.clang_Type_getNamedType(cxtype),
      pointerReference: pointerReference,
    );
  }

  // These basic Objective C types skip the cache, and are conditional on the
  // language flag.
  if (context.config.language == Language.objc) {
    switch (cxtype.kind) {
      case clang_types.CXTypeKind.CXType_ObjCObjectPointer:
        final pt = clang.clang_getPointeeType(cxtype);
        final s = getCodeGenType(context, pt, pointerReference: true);
        if (s is ObjCInterface) {
          return s;
        }
        final numProtocols = clang.clang_Type_getNumObjCProtocolRefs(pt);
        if (numProtocols > 0) {
          final protocols = <ObjCProtocol>[];
          for (var i = 0; i < numProtocols; ++i) {
            final pdecl = clang.clang_Type_getObjCProtocolDecl(pt, i);
            final p = parseObjCProtocolDeclaration(context, pdecl);
            if (p != null) protocols.add(p);
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
    final usr = cursor.usr();
    var type = context.bindingsIndex.getSeenType(usr);
    if (type == null) {
      final result = _createTypeFromCursor(
        context,
        cxtype,
        cursor,
        pointerReference,
      );
      type = result.type;
      if (type == null) {
        return UnimplementedType('${cxtype.kindSpelling()} not implemented');
      }
      if (result.addToCache) {
        context.bindingsIndex.addTypeToSeen(usr, type);
      }
    }
    _fillFromCursorIfNeeded(context, type, cursor, pointerReference);
    return type;
  }

  // If the type doesn't have a declaration cursor, then it's a basic type such
  // as int, or a simple derived type like a pointer, so doesn't need to be
  // cached.
  switch (cxtype.kind) {
    case clang_types.CXTypeKind.CXType_Pointer:
      final pt = clang.clang_getPointeeType(cxtype);
      final s = getCodeGenType(
        context,
        pt,
        pointerReference: true,
        originalCursor: originalCursor,
      );

      // Replace Pointer<_Dart_Handle> with Handle.
      if (context.config.useDartHandle &&
          s is Struct &&
          s.usr == strings.dartHandleUsr) {
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

class _CreateTypeFromCursorResult {
  final Type? type;

  // Flag that controls whether the type is added to the cache. It should not
  // be added to the cache if it's just a fallback implementation, such as the
  // int that is returned when an enum is excluded by the config. Later we might
  // need to build the full enum type (eg if it's part of an included struct),
  // and if we put the fallback int in the cache then the full enum will never
  // be created.
  final bool addToCache;

  _CreateTypeFromCursorResult(this.type, {this.addToCache = true});
}

_CreateTypeFromCursorResult _createTypeFromCursor(
  Context context,
  clang_types.CXType cxtype,
  clang_types.CXCursor cursor,
  bool pointerReference,
) {
  final logger = context.logger;
  final config = context.config;
  switch (cxtype.kind) {
    case clang_types.CXTypeKind.CXType_Typedef:
      final spelling = clang.clang_getTypedefName(cxtype).toStringAndDispose();
      if (config.language == Language.objc && spelling == strings.objcBOOL) {
        // Objective C's BOOL type can be either bool or signed char, depending
        // on the platform. We want to present a consistent API to the user, and
        // those two types are ABI compatible, so just return bool regardless.
        return _CreateTypeFromCursorResult(BooleanType());
      }
      final usr = cursor.usr();
      if (config.typedefTypeMappings.containsKey(spelling)) {
        logger.fine('  Type $spelling mapped from type-map');
        return _CreateTypeFromCursorResult(
          config.typedefTypeMappings[spelling]!,
        );
      }
      if (config.importedTypesByUsr.containsKey(usr)) {
        logger.fine('  Type $spelling mapped from usr');
        return _CreateTypeFromCursorResult(config.importedTypesByUsr[usr]!);
      }
      // Get name from supported typedef name if config allows.
      if (config.typedefs.useSupportedTypedefs) {
        if (suportedTypedefToSuportedNativeType.containsKey(spelling)) {
          logger.fine('  Type Mapped from supported typedef');
          return _CreateTypeFromCursorResult(
            NativeType(suportedTypedefToSuportedNativeType[spelling]!),
          );
        } else if (supportedTypedefToImportedType.containsKey(spelling)) {
          logger.fine('  Type Mapped from supported typedef');
          return _CreateTypeFromCursorResult(
            supportedTypedefToImportedType[spelling]!,
          );
        }
      }

      final typealias = parseTypedefDeclaration(
        context,
        cursor,
        pointerReference: pointerReference,
      );

      if (typealias != null) {
        return _CreateTypeFromCursorResult(typealias);
      } else {
        // Use underlying type if typealias couldn't be created or if the user
        // excluded this typedef.
        final ct = clang.clang_getTypedefDeclUnderlyingType(cursor);
        return _CreateTypeFromCursorResult(
          getCodeGenType(context, ct, pointerReference: pointerReference),
          addToCache: false,
        );
      }
    case clang_types.CXTypeKind.CXType_Record:
      return _CreateTypeFromCursorResult(
        _extractfromRecord(context, cxtype, cursor, pointerReference),
      );
    case clang_types.CXTypeKind.CXType_Enum:
      final (enumClass, nativeType) = parseEnumDeclaration(cursor, context);
      if (enumClass == null) {
        // Handle anonymous enum declarations within another declaration.
        return _CreateTypeFromCursorResult(nativeType, addToCache: false);
      } else {
        return _CreateTypeFromCursorResult(enumClass);
      }
    case clang_types.CXTypeKind.CXType_ObjCInterface:
    case clang_types.CXTypeKind.CXType_ObjCObject:
      return _CreateTypeFromCursorResult(
        parseObjCInterfaceDeclaration(context, cursor),
      );
    default:
      return _CreateTypeFromCursorResult(
        UnimplementedType('Unknown type: ${cxtype.completeStringRepr()}'),
        addToCache: false,
      );
  }
}

void _fillFromCursorIfNeeded(
  Context context,
  Type? type,
  clang_types.CXCursor cursor,
  bool pointerReference,
) {
  if (type == null) return;
  if (type is Compound) {
    fillCompoundMembersIfNeeded(
      type,
      cursor,
      context,
      pointerReference: pointerReference,
    );
  } else if (type is ObjCInterface) {
    fillObjCInterfaceMethodsIfNeeded(context, type, cursor);
  }
}

Type? _extractfromRecord(
  Context context,
  clang_types.CXType cxtype,
  clang_types.CXCursor cursor,
  bool pointerReference,
) {
  final logger = context.logger;
  final config = context.config;
  logger.fine('${_padding}_extractfromRecord: ${cursor.completeStringRepr()}');

  final declUsr = cursor.usr();
  if (config.importedTypesByUsr.containsKey(declUsr)) {
    logger.fine('  Type Mapped from usr');
    return config.importedTypesByUsr[declUsr]!;
  }

  final declSpelling = cursor.spelling();
  final cursorKind = clang.clang_getCursorKind(cursor);
  if (cursorKind == clang_types.CXCursorKind.CXCursor_StructDecl) {
    if (config.structTypeMappings.containsKey(declSpelling)) {
      logger.fine('  Type Mapped from type-map');
      return config.structTypeMappings[declSpelling]!;
    }
    return parseStructDeclaration(
      cursor,
      context,
      pointerReference: pointerReference,
    );
  } else if (cursorKind == clang_types.CXCursorKind.CXCursor_UnionDecl) {
    if (config.unionTypeMappings.containsKey(declSpelling)) {
      logger.fine('  Type Mapped from type-map');
      return config.unionTypeMappings[declSpelling]!;
    }
    return parseUnionDeclaration(
      cursor,
      context,
      pointerReference: pointerReference,
    );
  }

  logger.fine(
    'typedeclarationCursorVisitor: _extractfromRecord: '
    'Not Implemented, ${cursor.completeStringRepr()}',
  );
  return UnimplementedType('${cxtype.kindSpelling()} not implemented');
}

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
