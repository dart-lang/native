// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

import '../../code_generator.dart';
import '../../config_provider/config.dart';
import '../../config_provider/config_types.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../utils.dart';
import 'api_availability.dart';
import 'objcprotocoldecl_parser.dart';

final _logger = Logger('ffigen.header_parser.objcinterfacedecl_parser');

String applyModulePrefix(String name, String? module) =>
    module == null ? name : '$module.$name';

Type? parseObjCInterfaceDeclaration(
  clang_types.CXCursor cursor, {
  /// Option to ignore declaration filter (Useful in case of extracting
  /// declarations when they are passed/returned by an included function.)
  bool ignoreFilter = false,
}) {
  final itfUsr = cursor.usr();
  final itfName = cursor.spelling();
  final decl = Declaration(usr: itfUsr, originalName: itfName);
  if (!ignoreFilter && !shouldIncludeObjCInterface(decl)) {
    return null;
  }

  if (!isApiAvailable(cursor)) {
    _logger.info('Omitting deprecated interface $itfName');
    return null;
  }

  _logger.fine('++++ Adding ObjC interface: '
      'Name: $itfName, ${cursor.completeStringRepr()}');

  return ObjCInterface(
    usr: itfUsr,
    originalName: itfName,
    name: config.objcInterfaces.rename(decl),
    lookupName: applyModulePrefix(itfName, config.interfaceModule(decl)),
    dartDoc: getCursorDocComment(cursor),
    builtInFunctions: objCBuiltInFunctions,
  );
}

void fillObjCInterfaceMethodsIfNeeded(
    ObjCInterface itf, clang_types.CXCursor cursor) {
  if (_isClassDeclaration(cursor)) {
    // @class declarations are ObjC's way of forward declaring classes. In that
    // case there's nothing to fill yet.
    return;
  }

  if (itf.filled) return;
  itf.filled = true; // Break cycles.

  _logger.fine('++++ Filling ObjC interface: '
      'Name: ${itf.originalName}, ${cursor.completeStringRepr()}');

  _fillInterface(itf, cursor);

  _logger.fine('++++ Finished ObjC interface: '
      'Name: ${itf.originalName}, ${cursor.completeStringRepr()}');
}

void _fillInterface(ObjCInterface itf, clang_types.CXCursor cursor) {
  final itfDecl = Declaration(usr: itf.usr, originalName: itf.originalName);
  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ObjCSuperClassRef:
        _parseSuperType(child, itf);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCProtocolRef:
        _parseProtocol(child, itf);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCPropertyDecl:
        _parseProperty(child, itf, itfDecl);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        _parseInterfaceMethod(child, itf, itfDecl);
        break;
    }
  });
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

void _parseSuperType(clang_types.CXCursor cursor, ObjCInterface itf) {
  final superType = cursor.type().toCodeGenType();
  _logger.fine('       > Super type: '
      '$superType ${cursor.completeStringRepr()}');
  if (superType is ObjCInterface) {
    itf.superType = superType;
  } else {
    _logger.severe(
        'Super type of $itf is $superType, which is not a valid interface.');
  }
}

void _parseProtocol(clang_types.CXCursor cursor, ObjCInterface itf) {
  final protoCursor = clang.clang_getCursorDefinition(cursor);
  final proto = parseObjCProtocolDeclaration(protoCursor, ignoreFilter: true);
  if (proto != null) {
    itf.addProtocol(proto);
  }
}

void _parseProperty(
    clang_types.CXCursor cursor, ObjCInterface itf, Declaration itfDecl) {
  final fieldName = cursor.spelling();
  final fieldType = cursor.type().toCodeGenType();

  if (!isApiAvailable(cursor)) {
    _logger.info('Omitting deprecated property ${itf.originalName}.$fieldName');
    return;
  }

  if (fieldType.isIncompleteCompound) {
    _logger.warning('Property "$fieldName" in instance "${itf.originalName}" '
        'has incomplete type: $fieldType.');
    return;
  }

  if (!config.objcInterfaces.shouldIncludeMember(itfDecl, fieldName)) {
    return;
  }

  final dartDoc = getCursorDocComment(cursor);

  final propertyAttributes =
      clang.clang_Cursor_getObjCPropertyAttributes(cursor, 0);
  final isClassMethod = propertyAttributes &
          clang_types.CXObjCPropertyAttrKind.CXObjCPropertyAttr_class >
      0;
  final isReadOnly = propertyAttributes &
          clang_types.CXObjCPropertyAttrKind.CXObjCPropertyAttr_readonly >
      0;
  final isOptionalMethod = clang.clang_Cursor_isObjCOptional(cursor) != 0;

  final property = ObjCProperty(
    originalName: fieldName,
    name: config.objcInterfaces.renameMember(itfDecl, fieldName),
  );

  _logger.fine('       > Property: '
      '$fieldType $fieldName ${cursor.completeStringRepr()}');

  final getterName =
      clang.clang_Cursor_getObjCPropertyGetterName(cursor).toStringAndDispose();
  final getter = ObjCMethod(
    originalName: getterName,
    name: getterName,
    property: property,
    dartDoc: dartDoc,
    kind: ObjCMethodKind.propertyGetter,
    isClassMethod: isClassMethod,
    isOptional: isOptionalMethod,
    returnType: fieldType,
    family: null,
  );
  itf.addMethod(getter);

  if (!isReadOnly) {
    final setterName = clang
        .clang_Cursor_getObjCPropertySetterName(cursor)
        .toStringAndDispose();
    final setter = ObjCMethod(
      originalName: setterName,
      name: setterName,
      property: property,
      dartDoc: dartDoc,
      kind: ObjCMethodKind.propertySetter,
      isClassMethod: isClassMethod,
      isOptional: isOptionalMethod,
      returnType: NativeType(SupportedNativeType.voidType),
      family: null,
    );
    setter.params
        .add(Parameter(name: 'value', type: fieldType, objCConsumed: false));
    itf.addMethod(setter);
  }
}

void _parseInterfaceMethod(
    clang_types.CXCursor cursor, ObjCInterface itf, Declaration itfDecl) {
  final method = parseObjCMethod(cursor, itfDecl, config.objcInterfaces);
  if (method != null) {
    itf.addMethod(method);
  }
}

ObjCMethod? parseObjCMethod(clang_types.CXCursor cursor, Declaration itfDecl,
    DeclarationFilters filters) {
  final methodName = cursor.spelling();
  final isClassMethod =
      cursor.kind == clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl;
  final isOptionalMethod = clang.clang_Cursor_isObjCOptional(cursor) != 0;
  final returnType = clang.clang_getCursorResultType(cursor).toCodeGenType();
  if (returnType.isIncompleteCompound) {
    _logger.warning('Method "$methodName" in instance '
        '"${itfDecl.originalName}" has incomplete '
        'return type: $returnType.');
    return null;
  }

  if (!isApiAvailable(cursor)) {
    _logger
        .info('Omitting deprecated method ${itfDecl.originalName}.$methodName');
    return null;
  }

  if (!filters.shouldIncludeMember(itfDecl, methodName)) {
    return null;
  }

  final method = ObjCMethod(
    originalName: methodName,
    name: filters.renameMember(itfDecl, methodName),
    dartDoc: getCursorDocComment(cursor),
    kind: ObjCMethodKind.method,
    isClassMethod: isClassMethod,
    isOptional: isOptionalMethod,
    returnType: returnType,
    family: ObjCMethodFamily.parse(methodName),
  );
  _logger.fine('       > ${isClassMethod ? 'Class' : 'Instance'} method: '
      '${method.originalName} ${cursor.completeStringRepr()}');
  var hasError = false;
  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ParmDecl:
        if (!_parseMethodParam(child, itfDecl.originalName, method, debug)) {
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
  return hasError ? null : method;
}

bool _parseMethodParam(clang_types.CXCursor cursor, String itfName,
    ObjCMethod method, bool debug) {
  final name = cursor.spelling();
  final cursorType = cursor.type();

  // Ignore methods with variadic args.
  // TODO(https://github.com/dart-lang/native/issues/1192): Remove this.
  if (cursorType.kind == clang_types.CXTypeKind.CXType_Elaborated &&
      cursorType.spelling == 'va_list') {
    _logger.warning('Method "${method.originalName}" in instance '
        '"$itfName" has variadic args, which are not currently supported');
    return false;
  }

  final type = cursorType.toCodeGenType();
  if (type.isIncompleteCompound) {
    _logger.warning('Method "${method.originalName}" in instance '
        '"$itfName" has incomplete parameter type: $type.');
    return false;
  }

  _logger.fine(
      '           >> Parameter: $type $name ${cursor.completeStringRepr()}');
  final consumed =
      cursor.hasChildWithKind(clang_types.CXCursorKind.CXCursor_NSConsumed);
  method.params.add(Parameter(name: name, type: type, objCConsumed: consumed));
  return true;
}

BindingType? parseObjCCategoryDeclaration(clang_types.CXCursor cursor) {
  // Categories add methods to an existing interface, so first we run a visitor
  // to find the interface, then we fully parse that interface, then we run
  // _fillInterface over the category to add its methods etc. Reusing the
  // interface visitor relies on the fact that the structure of the category AST
  // looks exactly the same as the interface AST, and that the category's
  // interface is a different kind of node to the interface's super type (so is
  // ignored by _fillInterface).
  final name = cursor.spelling();
  _logger.fine('++++ Adding ObjC category: '
      'Name: $name, ${cursor.completeStringRepr()}');

  final itfCursor =
      cursor.findChildWithKind(clang_types.CXCursorKind.CXCursor_ObjCClassRef);
  if (itfCursor == null) {
    _logger.severe('Category $name has no interface.');
    return null;
  }

  // TODO(https://github.com/dart-lang/ffigen/issues/347): Currently any
  // interface with a category bypasses the filters.
  final itf = itfCursor.type().toCodeGenType();
  if (itf is! ObjCInterface) {
    _logger.severe(
        'Interface of category $name is $itf, which is not a valid interface.');
    return null;
  }

  _fillInterface(itf, cursor);

  _logger.fine('++++ Finished ObjC category: '
      'Name: $name, ${cursor.completeStringRepr()}');

  return itf;
}
