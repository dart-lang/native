// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Extracts code_gen Type from type.
library;

import 'package:logging/logging.dart';

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../../strings.dart' as strings;
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../sub_parsers/compounddecl_parser.dart';
import '../sub_parsers/enumdecl_parser.dart';
import '../sub_parsers/function_type_param_parser.dart';
import '../sub_parsers/objc_block_parser.dart';
import '../sub_parsers/objcinterfacedecl_parser.dart';
import '../sub_parsers/objcprotocoldecl_parser.dart';
import '../sub_parsers/typedefdecl_parser.dart';
import '../type_extractor/cxtypekindmap.dart';
import '../utils.dart';

final _logger = Logger('ffigen.header_parser.extractor');
const _padding = '  ';

const maxRecursionDepth = 5;

/// Converts cxtype to a typestring code_generator can accept.
Type getCodeGenType(
  clang_types.CXType cxtype, {

  /// Passed on if a value was marked as a pointer before this one.
  bool pointerReference = false,

  /// Cursor of the declaration, currently this is useful only to extract
  /// parameter names in function types.
  clang_types.CXCursor? originalCursor,
  bool supportNonInlineArray = false,
}) {
  _logger.fine('${_padding}getCodeGenType ${cxtype.completeStringRepr()}');

  // Special case: Elaborated types just refer to another type.
  if (cxtype.kind == clang_types.CXTypeKind.CXType_Elaborated) {
    return getCodeGenType(
      clang.clang_Type_getNamedType(cxtype),
      pointerReference: pointerReference,
    );
  }

  // These basic Objective C types skip the cache, and are conditional on the
  // language flag.
  if (config.language == Language.objc) {
    switch (cxtype.kind) {
      case clang_types.CXTypeKind.CXType_ObjCObjectPointer:
        final pt = clang.clang_getPointeeType(cxtype);
        final s = getCodeGenType(pt, pointerReference: true);
        if (s is ObjCInterface) {
          return s;
        }
        final numProtocols = clang.clang_Type_getNumObjCProtocolRefs(pt);
        if (numProtocols > 0) {
          final protocols = <ObjCProtocol>[];
          for (var i = 0; i < numProtocols; ++i) {
            final pdecl = clang.clang_Type_getObjCProtocolDecl(pt, i);
            final p = parseObjCProtocolDeclaration(pdecl);
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
        return parseObjCBlock(cxtype);
    }
  }

  // If the type has a declaration cursor, then use the BindingsIndex to break
  // any potential cycles, and dedupe the Type.
  final cursor = clang.clang_getTypeDeclaration(cxtype);
  if (cursor.kind != clang_types.CXCursorKind.CXCursor_NoDeclFound) {
    final usr = cursor.usr();
    var type = bindingsIndex.getSeenType(usr);
    if (type == null) {
      final result = _createTypeFromCursor(cxtype, cursor, pointerReference);
      type = result.type;
      if (type == null) {
        return UnimplementedType('${cxtype.kindSpelling()} not implemented');
      }
      if (result.addToCache) {
        bindingsIndex.addTypeToSeen(usr, type);
      }
    }
    _fillFromCursorIfNeeded(type, cursor, pointerReference);
    return type;
  }

  // If the type doesn't have a declaration cursor, then it's a basic type such
  // as int, or a simple derived type like a pointer, so doesn't need to be
  // cached.
  switch (cxtype.kind) {
    case clang_types.CXTypeKind.CXType_Pointer:
      final pt = clang.clang_getPointeeType(cxtype);
      final s = getCodeGenType(
        pt,
        pointerReference: true,
        originalCursor: originalCursor,
      );

      // Replace Pointer<_Dart_Handle> with Handle.
      if (config.useDartHandle &&
          s is Compound &&
          s.compoundType == CompoundType.struct &&
          s.usr == strings.dartHandleUsr) {
        return HandleType();
      }
      return PointerType(s);
    case clang_types.CXTypeKind.CXType_FunctionProto:
      // Primarily used for function pointers.
      return _extractFromFunctionProto(cxtype, cursor: originalCursor);
    case clang_types.CXTypeKind.CXType_FunctionNoProto:
      // Primarily used for function types with zero arguments.
      return _extractFromFunctionProto(cxtype, cursor: originalCursor);
    case clang_types.CXTypeKind.CXType_ConstantArray:
      // Primarily used for constant array in struct members.
      final numElements = clang.clang_getNumElements(cxtype);
      final elementType = clang
          .clang_getArrayElementType(cxtype)
          .toCodeGenType(supportNonInlineArray: supportNonInlineArray);
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
        clang.clang_getArrayElementType(cxtype).toCodeGenType(),
      );
    case clang_types.CXTypeKind.CXType_Bool:
      return BooleanType();
    case clang_types.CXTypeKind.CXType_Attributed:
    case clang_types.CXTypeKind.CXType_Unexposed:
      final innerType = getCodeGenType(
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
      if (config.nativeTypeMappings.containsKey(typeSpellKey)) {
        _logger.fine('  Type $typeSpellKey mapped from type-map.');
        return config.nativeTypeMappings[typeSpellKey]!;
      } else if (cxTypeKindToImportedTypes.containsKey(typeSpellKey)) {
        return cxTypeKindToImportedTypes[typeSpellKey]!;
      } else {
        _logger.fine(
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
  clang_types.CXType cxtype,
  clang_types.CXCursor cursor,
  bool pointerReference,
) {
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
        _logger.fine('  Type $spelling mapped from type-map');
        return _CreateTypeFromCursorResult(
          config.typedefTypeMappings[spelling]!,
        );
      }
      if (config.usrTypeMappings.containsKey(usr)) {
        _logger.fine('  Type $spelling mapped from usr');
        return _CreateTypeFromCursorResult(config.usrTypeMappings[usr]!);
      }
      // Get name from supported typedef name if config allows.
      if (config.useSupportedTypedefs) {
        if (suportedTypedefToSuportedNativeType.containsKey(spelling)) {
          _logger.fine('  Type Mapped from supported typedef');
          return _CreateTypeFromCursorResult(
            NativeType(suportedTypedefToSuportedNativeType[spelling]!),
          );
        } else if (supportedTypedefToImportedType.containsKey(spelling)) {
          _logger.fine('  Type Mapped from supported typedef');
          return _CreateTypeFromCursorResult(
            supportedTypedefToImportedType[spelling]!,
          );
        }
      }

      final typealias = parseTypedefDeclaration(
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
          getCodeGenType(ct, pointerReference: pointerReference),
          addToCache: false,
        );
      }
    case clang_types.CXTypeKind.CXType_Record:
      return _CreateTypeFromCursorResult(
        _extractfromRecord(cxtype, cursor, pointerReference),
      );
    case clang_types.CXTypeKind.CXType_Enum:
      final (enumClass, nativeType) = parseEnumDeclaration(cursor);
      if (enumClass == null) {
        // Handle anonymous enum declarations within another declaration.
        return _CreateTypeFromCursorResult(nativeType, addToCache: false);
      } else {
        return _CreateTypeFromCursorResult(enumClass);
      }
    case clang_types.CXTypeKind.CXType_ObjCInterface:
    case clang_types.CXTypeKind.CXType_ObjCObject:
      return _CreateTypeFromCursorResult(parseObjCInterfaceDeclaration(cursor));
    default:
      return _CreateTypeFromCursorResult(
        UnimplementedType('Unknown type: ${cxtype.completeStringRepr()}'),
        addToCache: false,
      );
  }
}

void _fillFromCursorIfNeeded(
  Type? type,
  clang_types.CXCursor cursor,
  bool pointerReference,
) {
  if (type == null) return;
  if (type is Compound) {
    fillCompoundMembersIfNeeded(
      type,
      cursor,
      pointerReference: pointerReference,
    );
  } else if (type is ObjCInterface) {
    fillObjCInterfaceMethodsIfNeeded(type, cursor);
  }
}

Type? _extractfromRecord(
  clang_types.CXType cxtype,
  clang_types.CXCursor cursor,
  bool pointerReference,
) {
  _logger.fine('${_padding}_extractfromRecord: ${cursor.completeStringRepr()}');

  final cursorKind = clang.clang_getCursorKind(cursor);
  if (cursorKind == clang_types.CXCursorKind.CXCursor_StructDecl ||
      cursorKind == clang_types.CXCursorKind.CXCursor_UnionDecl) {
    final declSpelling = cursor.spelling();
    final declUsr = cursor.usr();

    // Set includer functions according to compoundType.
    final CompoundType compoundType;
    final Map<String, ImportedType> compoundTypeMappings;

    switch (cursorKind) {
      case clang_types.CXCursorKind.CXCursor_StructDecl:
        compoundType = CompoundType.struct;
        compoundTypeMappings = config.structTypeMappings;
        break;
      case clang_types.CXCursorKind.CXCursor_UnionDecl:
        compoundType = CompoundType.union;
        compoundTypeMappings = config.unionTypeMappings;
        break;
      default:
        throw Exception('Unhandled compound type cursorkind.');
    }

    // Also add a struct binding, if its unseen.
    if (compoundTypeMappings.containsKey(declSpelling)) {
      _logger.fine('  Type Mapped from type-map');
      return compoundTypeMappings[declSpelling]!;
    } else if (config.usrTypeMappings.containsKey(declUsr)) {
      _logger.fine('  Type Mapped from usr');
      return config.usrTypeMappings[declUsr]!;
    } else {
      final struct = parseCompoundDeclaration(
        cursor,
        compoundType,
        pointerReference: pointerReference,
      );
      return struct;
    }
  }
  _logger.fine(
    'typedeclarationCursorVisitor: _extractfromRecord: '
    'Not Implemented, ${cursor.completeStringRepr()}',
  );
  return UnimplementedType('${cxtype.kindSpelling()} not implemented');
}

// Used for function pointer arguments.
Type _extractFromFunctionProto(
  clang_types.CXType cxtype, {
  clang_types.CXCursor? cursor,
}) {
  final parameters = <Parameter>[];
  final totalArgs = clang.clang_getNumArgTypes(cxtype);
  for (var i = 0; i < totalArgs; i++) {
    final t = clang.clang_getArgType(cxtype, i);
    final pt = t.toCodeGenType();

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
    returnType: clang.clang_getResultType(cxtype).toCodeGenType(),
  );
  _parseAndMergeParamNames(functionType, cursor, maxRecursionDepth);
  return NativeFunc(functionType);
}

void _parseAndMergeParamNames(
  FunctionType functionType,
  clang_types.CXCursor? cursor,
  int recursionDepth,
) {
  if (cursor == null) {
    return;
  }
  if (recursionDepth == 0) {
    final cursorRepr = cursor.completeStringRepr();
    _logger.warning(
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
    if (paramBaseType is NativeFunc && param.name.isNotEmpty) {
      final paramFunctionType = paramBaseType.type;
      final paramCursor = paramsInfo.params[param.name];
      _parseAndMergeParamNames(
        paramFunctionType,
        paramCursor,
        recursionDepth - 1,
      );
    }
  }
}
