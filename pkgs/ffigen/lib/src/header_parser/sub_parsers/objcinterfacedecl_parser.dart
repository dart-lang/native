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
  final itfUsr = cursor.usr();
  final itfName = cursor.spelling();
  final decl = Declaration(usr: itfUsr, originalName: itfName);
  final apiAvailability = ApiAvailability.fromCursor(cursor, context);

  context.logger.fine(
    '++++ Adding ObjC interface: '
    'Name: $itfName, ${cursor.completeStringRepr()}',
  );

  final config = context.config;
  return ObjCInterface(
    context: context,
    usr: itfUsr,
    originalName: itfName,
    name: config.objcInterfaces.rename(decl),
    lookupName: applyModulePrefix(itfName, config.interfaceModule(decl)),
    dartDoc: getCursorDocComment(
      context,
      cursor,
      fallbackComment: itfName,
      availability: apiAvailability.dartDoc,
    ),
    apiAvailability: apiAvailability,
  );
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
          context.config.objcInterfaces,
        );
        itf.addMethod(getter);
        itf.addMethod(setter);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        itf.addMethod(
          parseObjCMethod(
            context,
            child,
            itfDecl,
            context.config.objcInterfaces,
          ),
        );
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
  DeclarationFiltersConfig filters,
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

  final property = ObjCProperty(
    originalName: fieldName,
    name: filters.renameMember(decl, fieldName),
  );

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
    name: getterName,
    property: property,
    dartDoc: dartDoc ?? getterName,
    kind: ObjCMethodKind.propertyGetter,
    isClassMethod: isClassMethod,
    isOptional: isOptionalMethod,
    returnType: fieldType,
    family: null,
    apiAvailability: apiAvailability,
  )..finalizeParams();

  ObjCMethod? setter;
  if (!isReadOnly) {
    final setterName = clang
        .clang_Cursor_getObjCPropertySetterName(cursor)
        .toStringAndDispose();
    setter = ObjCMethod(
      context: context,
      originalName: setterName,
      name: setterName,
      property: property,
      dartDoc: dartDoc ?? setterName,
      kind: ObjCMethodKind.propertySetter,
      isClassMethod: isClassMethod,
      isOptional: isOptionalMethod,
      returnType: voidType,
      family: null,
      apiAvailability: apiAvailability,
    );
    setter.params.add(
      Parameter(name: 'value', type: fieldType, objCConsumed: false),
    );
    setter.finalizeParams();
  }
  return (getter, setter);
}

ObjCMethod? parseObjCMethod(
  Context context,
  clang_types.CXCursor cursor,
  Declaration itfDecl,
  DeclarationFiltersConfig filters,
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

  final method = ObjCMethod(
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
    family: ObjCMethodFamily.parse(methodName),
    apiAvailability: apiAvailability,
  );
  logger.fine(
    '       > ${isClassMethod ? 'Class' : 'Instance'} method: '
    '${method.originalName} ${cursor.completeStringRepr()}',
  );
  var hasError = false;
  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ParmDecl:
        if (!_parseMethodParam(context, child, itfDecl.originalName, method)) {
          hasError = true;
        }
        break;
      case clang_types.CXCursorKind.CXCursor_NSReturnsRetained:
        method.ownershipAttribute = ObjCMethodOwnership.retained;
        break;
      case clang_types.CXCursorKind.CXCursor_NSReturnsNotRetained:
        method.ownershipAttribute = ObjCMethodOwnership.notRetained;
        break;
      case clang_types.CXCursorKind.CXCursor_NSReturnsAutoreleased:
        method.ownershipAttribute = ObjCMethodOwnership.autoreleased;
        break;
      case clang_types.CXCursorKind.CXCursor_NSConsumesSelf:
        method.consumesSelfAttribute = true;
        break;
      default:
    }
  });
  method.finalizeParams();
  return hasError ? null : method;
}

bool _parseMethodParam(
  Context context,
  clang_types.CXCursor cursor,
  String itfName,
  ObjCMethod method,
) {
  final logger = context.logger;
  final name = cursor.spelling();
  final cursorType = cursor.type();

  // Ignore methods with variadic args.
  // TODO(https://github.com/dart-lang/native/issues/1192): Remove this.
  if (cursorType.kind == clang_types.CXTypeKind.CXType_Elaborated &&
      cursorType.spelling() == 'va_list') {
    logger.warning(
      'Method "${method.originalName}" in instance '
      '"$itfName" has variadic args, which are not currently supported',
    );
    return false;
  }

  final type = cursorType.toCodeGenType(context);
  if (type.isIncompleteCompound) {
    logger.warning(
      'Method "${method.originalName}" in instance '
      '"$itfName" has incomplete parameter type: $type.',
    );
    return false;
  }

  logger.fine(
    '           >> Parameter: $type $name ${cursor.completeStringRepr()}',
  );
  final consumed = cursor.hasChildWithKind(
    clang_types.CXCursorKind.CXCursor_NSConsumed,
  );
  method.params.add(Parameter(name: name, type: type, objCConsumed: consumed));
  return true;
}
