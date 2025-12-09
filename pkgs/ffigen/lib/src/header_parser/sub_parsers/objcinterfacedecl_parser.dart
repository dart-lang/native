// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../code_generator.dart';
import '../../config_provider/config.dart';
import '../../config_provider/config_types.dart';
import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';
import 'api_availability.dart';
import 'objcprotocoldecl_parser.dart';

String applyModulePrefix(String name, String? module) =>
    module == null ? name : '$module.$name';

Type? parseObjCInterfaceDeclaration(
  Context context,
  clang_types.CXCursor cursor,
) {
  final usr = cursor.usr();

  final cachedItf = context.bindingsIndex.getSeenObjCInterface(usr);
  if (cachedItf != null) return cachedItf;

  final name = cursor.spelling();
  final decl = Declaration(usr: usr, originalName: name);
  final apiAvailability = ApiAvailability.fromCursor(cursor, context);

  final config = context.config;
  final objcInterfaces = config.objectiveC?.interfaces;
  if (objcInterfaces == null) {
    return null;
  }

  context.logger.fine(
    '++++ Adding ObjC interface: '
    'Name: $name, ${cursor.completeStringRepr()}',
  );

  final config = context.config;
  final itf = ObjCInterface(
    context: context,
    usr: usr,
    originalName: name,
    name: objcInterfaces.rename(decl),
    lookupName: applyModulePrefix(name, config.interfaceModule(decl)),
    dartDoc: getCursorDocComment(
      context,
      cursor,
      fallbackComment: name,
      availability: apiAvailability.dartDoc,
    ),
    apiAvailability: apiAvailability,
  );
  context.bindingsIndex.addObjCInterfaceToSeen(usr, itf);
  return itf;
}

void fillObjCInterfaceMethodsIfNeeded(
  Context context,
  ObjCInterface itf,
  clang_types.CXCursor cursor,
) {
  if (_isClassDeclaration(cursor)) {
    // @class declarations are ObjC's way of forward declaring classes. In that
    // case there's nothing to fill yet.
    return;
  }

  if (itf.filled) return;
  itf.filled = true; // Break cycles.

  final objcInterfaces = context.config.objectiveC!.interfaces;

  context.logger.fine(
    '++++ Filling ObjC interface: '
    'Name: ${itf.originalName}, ${cursor.completeStringRepr()}',
  );

  final itfDecl = Declaration(usr: itf.usr, originalName: itf.originalName);
  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ObjCSuperClassRef:
        _parseSuperType(context, child, itf);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCProtocolRef:
        final protoCursor = clang.clang_getCursorDefinition(child);
        itf.addProtocol(parseObjCProtocolDeclaration(context, protoCursor));
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCPropertyDecl:
        final (getter, setter) = parseObjCProperty(
          context,
          child,
          itfDecl,
          objcInterfaces,
        );
        itf.addMethod(getter);
        itf.addMethod(setter);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        itf.addMethod(parseObjCMethod(context, child, itfDecl, objcInterfaces));
        break;
    }
  });

  context.logger.fine(
    '++++ Finished ObjC interface: '
    'Name: ${itf.originalName}, ${cursor.completeStringRepr()}',
  );
}

bool _isClassDeclaration(clang_types.CXCursor cursor) {
  // It's a class declaration if it has no children other than ObjCClassRef.
  var result = true;
  cursor.visitChildrenMayBreak((child) {
    if (child.kind == clang_types.CXCursorKind.CXCursor_ObjCClassRef) {
      return true;
    }
    result = false;
    return false;
  });
  return result;
}

void _parseSuperType(
  Context context,
  clang_types.CXCursor cursor,
  ObjCInterface itf,
) {
  final superType = cursor.type().toCodeGenType(context);
  context.logger.fine(
    '       > Super type: '
    '$superType ${cursor.completeStringRepr()}',
  );
  if (superType is ObjCInterface) {
    itf.superType = superType;
    superType.subtypes.add(itf);
  } else {
    context.logger.severe(
      'Super type of $itf is $superType, which is not a valid interface.',
    );
  }
}

(ObjCMethod?, ObjCMethod?) parseObjCProperty(
  Context context,
  clang_types.CXCursor cursor,
  Declaration decl,
  Declarations filters,
) {
  final fieldName = cursor.spelling();
  final fieldType = cursor.type().toCodeGenType(context);

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);
  if (apiAvailability.availability == Availability.none) {
    context.logger.info(
      'Omitting deprecated property ${decl.originalName}.$fieldName',
    );
    return (null, null);
  }

  if (fieldType.isIncompleteCompound) {
    context.logger.warning(
      'Property "$fieldName" in instance "${decl.originalName}" '
      'has incomplete type: $fieldType.',
    );
    return (null, null);
  }

  final dartDoc = getCursorDocComment(
    context,
    cursor,
    availability: apiAvailability.dartDoc,
  );

  final propertyAttributes = clang.clang_Cursor_getObjCPropertyAttributes(
    cursor,
    0,
  );
  final isClassMethod =
      propertyAttributes &
          clang_types.CXObjCPropertyAttrKind.CXObjCPropertyAttr_class >
      0;
  final isReadOnly =
      propertyAttributes &
          clang_types.CXObjCPropertyAttrKind.CXObjCPropertyAttr_readonly >
      0;
  final isOptionalMethod = clang.clang_Cursor_isObjCOptional(cursor) != 0;

  context.logger.fine(
    '       > Property: '
    '$fieldType $fieldName ${cursor.completeStringRepr()}',
  );

  final getterName = clang
      .clang_Cursor_getObjCPropertyGetterName(cursor)
      .toStringAndDispose();
  final getter = ObjCMethod(
    context: context,
    originalName: getterName,
    name: filters.renameMember(decl, getterName),
    dartDoc: dartDoc ?? getterName,
    kind: ObjCMethodKind.propertyGetter,
    isClassMethod: isClassMethod,
    isOptional: isOptionalMethod,
    returnType: fieldType,
    params: const [],
    family: null,
    apiAvailability: apiAvailability,
    ownershipAttribute: null,
    consumesSelfAttribute: false,
  );

  ObjCMethod? setter;
  if (!isReadOnly) {
    final setterName = clang
        .clang_Cursor_getObjCPropertySetterName(cursor)
        .toStringAndDispose();
    setter = ObjCMethod.withSymbol(
      context: context,
      originalName: setterName,
      symbol: getter.symbol,
      protocolMethodName: setterName,
      dartDoc: dartDoc ?? setterName,
      kind: ObjCMethodKind.propertySetter,
      isClassMethod: isClassMethod,
      isOptional: isOptionalMethod,
      returnType: voidType,
      params: [Parameter(name: 'value', type: fieldType, objCConsumed: false)],
      family: null,
      apiAvailability: apiAvailability,
      ownershipAttribute: null,
      consumesSelfAttribute: false,
    );
  }
  return (getter, setter);
}

ObjCMethod? parseObjCMethod(
  Context context,
  clang_types.CXCursor cursor,
  Declaration itfDecl,
  Declarations filters,
) {
  final logger = context.logger;
  final methodName = cursor.spelling();
  final isClassMethod =
      cursor.kind == clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl;
  final isOptionalMethod = clang.clang_Cursor_isObjCOptional(cursor) != 0;
  final returnType = clang
      .clang_getCursorResultType(cursor)
      .toCodeGenType(context);
  if (returnType.isIncompleteCompound) {
    logger.warning(
      'Method "$methodName" in instance '
      '"${itfDecl.originalName}" has incomplete '
      'return type: $returnType.',
    );
    return null;
  }

  final apiAvailability = ApiAvailability.fromCursor(cursor, context);
  if (apiAvailability.availability == Availability.none) {
    logger.info(
      'Omitting deprecated method ${itfDecl.originalName}.$methodName',
    );
    return null;
  }

  logger.fine(
    '       > ${isClassMethod ? 'Class' : 'Instance'} method: '
    '$methodName ${cursor.completeStringRepr()}',
  );

  final params = <Parameter>[];
  ObjCMethodOwnership? ownershipAttribute;
  var consumesSelfAttribute = false;

  var hasError = false;
  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ParmDecl:
        final p = _parseMethodParam(
          context,
          child,
          itfDecl.originalName,
          methodName,
        );
        if (p == null) {
          hasError = true;
        } else {
          params.add(p);
        }
        break;
      case clang_types.CXCursorKind.CXCursor_NSReturnsRetained:
        ownershipAttribute = ObjCMethodOwnership.retained;
        break;
      case clang_types.CXCursorKind.CXCursor_NSReturnsNotRetained:
        ownershipAttribute = ObjCMethodOwnership.notRetained;
        break;
      case clang_types.CXCursorKind.CXCursor_NSReturnsAutoreleased:
        ownershipAttribute = ObjCMethodOwnership.autoreleased;
        break;
      case clang_types.CXCursorKind.CXCursor_NSConsumesSelf:
        consumesSelfAttribute = true;
        break;
      default:
    }
  });
  if (hasError) return null;

  return ObjCMethod(
    context: context,
    originalName: methodName,
    name: filters.renameMember(itfDecl, methodName),
    dartDoc: getCursorDocComment(
      context,
      cursor,
      fallbackComment: methodName,
      availability: apiAvailability.dartDoc,
    ),
    kind: ObjCMethodKind.method,
    isClassMethod: isClassMethod,
    isOptional: isOptionalMethod,
    returnType: returnType,
    params: params,
    family: ObjCMethodFamily.parse(methodName),
    apiAvailability: apiAvailability,
    ownershipAttribute: ownershipAttribute,
    consumesSelfAttribute: consumesSelfAttribute,
  );
}

Parameter? _parseMethodParam(
  Context context,
  clang_types.CXCursor cursor,
  String itfName,
  String methodName,
) {
  final logger = context.logger;
  final name = cursor.spelling();
  final cursorType = cursor.type();

  // Ignore methods with variadic args.
  // TODO(https://github.com/dart-lang/native/issues/1192): Remove this.
  if (cursorType.kind == clang_types.CXTypeKind.CXType_Elaborated &&
      cursorType.spelling() == 'va_list') {
    logger.warning(
      'Method "$methodName" in instance '
      '"$itfName" has variadic args, which are not currently supported',
    );
    return null;
  }

  final type = cursorType.toCodeGenType(context);
  if (type.isIncompleteCompound) {
    logger.warning(
      'Method "$methodName" in instance '
      '"$itfName" has incomplete parameter type: $type.',
    );
    return null;
  }

  logger.fine(
    '           >> Parameter: $type $name ${cursor.completeStringRepr()}',
  );
  final consumed = cursor.hasChildWithKind(
    clang_types.CXCursorKind.CXCursor_NSConsumed,
  );
  return Parameter(name: name, type: type, objCConsumed: consumed);
}
