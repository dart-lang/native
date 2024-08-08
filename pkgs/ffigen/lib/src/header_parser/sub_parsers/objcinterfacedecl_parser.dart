// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';

import '../../code_generator.dart';
import '../../config_provider/config_types.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../data.dart';
import '../includer.dart';
import '../utils.dart';

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

  if (!isObjCApiAvailable(cursor)) {
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
  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ObjCSuperClassRef:
        _parseSuperType(child, itf);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCPropertyDecl:
        _parseProperty(child, itf);
        break;
      case clang_types.CXCursorKind.CXCursor_ObjCInstanceMethodDecl:
      case clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl:
        _parseInterfaceMethod(child, itf);
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

void _parseProperty(clang_types.CXCursor cursor, ObjCInterface itf) {
  final fieldName = cursor.spelling();
  final fieldType = cursor.type().toCodeGenType();

  if (fieldType.isIncompleteCompound) {
    _logger.warning('Property "$fieldName" in instance "${itf.originalName}" '
        'has incomplete type: $fieldType.');
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

  final property = ObjCProperty(fieldName);

  _logger.fine('       > Property: '
      '$fieldType $fieldName ${cursor.completeStringRepr()}');

  final getterName =
      clang.clang_Cursor_getObjCPropertyGetterName(cursor).toStringAndDispose();
  final getter = ObjCMethod(
    originalName: getterName,
    property: property,
    dartDoc: dartDoc,
    kind: ObjCMethodKind.propertyGetter,
    isClassMethod: isClassMethod,
    isOptional: isOptionalMethod,
    returnType: fieldType,
  );
  itf.addMethod(getter);

  if (!isReadOnly) {
    final setterName = clang
        .clang_Cursor_getObjCPropertySetterName(cursor)
        .toStringAndDispose();
    final setter = ObjCMethod(
        originalName: setterName,
        property: property,
        dartDoc: dartDoc,
        kind: ObjCMethodKind.propertySetter,
        isClassMethod: isClassMethod,
        isOptional: isOptionalMethod,
        returnType: NativeType(SupportedNativeType.voidType));
    setter.params.add(ObjCMethodParam(fieldType, 'value'));
    itf.addMethod(setter);
  }
}

void _parseInterfaceMethod(clang_types.CXCursor cursor, ObjCInterface itf) {
  final method = parseObjCMethod(cursor, itf.originalName);
  if (method != null) {
    itf.addMethod(method);
  }
}

ObjCMethod? parseObjCMethod(clang_types.CXCursor cursor, String itfName) {
  final methodName = cursor.spelling();
  final isClassMethod =
      cursor.kind == clang_types.CXCursorKind.CXCursor_ObjCClassMethodDecl;
  final isOptionalMethod = clang.clang_Cursor_isObjCOptional(cursor) != 0;
  final returnType = clang.clang_getCursorResultType(cursor).toCodeGenType();
  if (returnType.isIncompleteCompound) {
    _logger.warning('Method "$methodName" in instance '
        '"$itfName" has incomplete '
        'return type: $returnType.');
    return null;
  }

  if (!isObjCApiAvailable(cursor)) {
    _logger.info('Omitting deprecated method $itfName.$methodName');
    return null;
  }

  final method = ObjCMethod(
    originalName: methodName,
    dartDoc: getCursorDocComment(cursor),
    kind: ObjCMethodKind.method,
    isClassMethod: isClassMethod,
    isOptional: isOptionalMethod,
    returnType: returnType,
  );
  _logger.fine('       > ${isClassMethod ? 'Class' : 'Instance'} method: '
      '${method.originalName} ${cursor.completeStringRepr()}');
  var hasError = false;
  cursor.visitChildren((child) {
    switch (child.kind) {
      case clang_types.CXCursorKind.CXCursor_ParmDecl:
        if (!_parseMethodParam(child, itfName, method)) {
          hasError = true;
        }
        break;
      case clang_types.CXCursorKind.CXCursor_NSReturnsRetained:
        method.returnsRetained = true;
        break;
      default:
    }
  });
  return hasError ? null : method;
}

bool _parseMethodParam(
    clang_types.CXCursor cursor, String itfName, ObjCMethod method) {
  final name = cursor.spelling();
  final type = cursor.type().toCodeGenType();
  if (type.isIncompleteCompound) {
    _logger.warning('Method "${method.originalName}" in instance '
        '"$itfName" has incomplete '
        'parameter type: $type.');
    return false;
  }
  _logger.fine(
      '           >> Parameter: $type $name ${cursor.completeStringRepr()}');
  method.params.add(ObjCMethodParam(type, name));
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

class PlatformAvailability {
  VersionTriple? introduced;
  VersionTriple? deprecated;
  VersionTriple? obsoleted;
  bool unavailable;

  PlatformAvailability({
    this.introduced,
    this.deprecated,
    this.obsoleted,
    this.unavailable = false,
  });

  @override
  String toString() => 'introduced: $introduced, deprecated: $deprecated, '
      'obsoleted: $obsoleted, unavailable: $unavailable';
}

class ApiAvailability {
  final bool alwaysDeprecated;
  final bool alwaysUnavailable;
  PlatformAvailability? ios;
  PlatformAvailability? macos;

  ApiAvailability({
    this.alwaysDeprecated = false,
    this.alwaysUnavailable = false,
    this.ios,
    this.macos,
  });

  static ApiAvailability fromCursor(clang_types.CXCursor cursor) {
    final platformsLength = clang.clang_getCursorPlatformAvailability(
        cursor, nullptr, nullptr, nullptr, nullptr, nullptr, 0);

    final alwaysDeprecated = calloc<Int>();
    final alwaysUnavailable = calloc<Int>();
    final platforms =
        calloc<clang_types.CXPlatformAvailability>(platformsLength);

    clang.clang_getCursorPlatformAvailability(cursor, alwaysDeprecated, nullptr,
        alwaysUnavailable, nullptr, platforms, platformsLength);

    PlatformAvailability? ios;
    PlatformAvailability? macos;

    for (var i = 0; i < platformsLength; ++i) {
      final platform = platforms[i];
      final platformAvailability = PlatformAvailability(
        introduced: platform.Introduced.triple,
        deprecated: platform.Deprecated.triple,
        obsoleted: platform.Obsoleted.triple,
        unavailable: platform.Unavailable != 0,
      );
      switch (platform.Platform.string()) {
        case 'ios':
          ios = platformAvailability;
          break;
        case 'macos':
          macos = platformAvailability;
          break;
      }
    }

    final api = ApiAvailability(
      alwaysDeprecated: alwaysDeprecated.value != 0,
      alwaysUnavailable: alwaysUnavailable.value != 0,
      ios: ios,
      macos: macos,
    );

    for (var i = 0; i < platformsLength; ++i) {
      clang.clang_disposeCXPlatformAvailability(platforms + i);
    }
    calloc.free(alwaysDeprecated);
    calloc.free(alwaysUnavailable);
    calloc.free(platforms);

    return api;
  }

  bool isAvailable(ObjCTargetVersion minVers) {
    if (alwaysDeprecated || alwaysUnavailable) {
      return false;
    }

    // If no minimum versions are specified, everything is available.
    if (minVers.ios == null && minVers.macos == null) {
      return true;
    }

    for (final (plat, minVer) in [(ios, minVers.ios), (macos, minVers.macos)]) {
      // If the user hasn't specified a minimum version for this platform, defer
      // to the other platforms.
      if (minVer == null) {
        continue;
      }
      // If the API is available on any platform, return that it's available.
      if (_platformAvailable(plat, minVer)) {
        return true;
      }
    }
    // The API is not available on any of the platforms the user cares about.
    return false;
  }

  bool _platformAvailable(PlatformAvailability? plat, VersionTriple minVer) {
    if (plat == null) {
      // Clang's availability info has nothing to say about the given platform,
      // so assume the API is available.
      return true;
    }
    if (plat.unavailable) {
      return false;
    }
    if (minVer >= plat.deprecated || minVer >= plat.obsoleted) {
      return false;
    }
    return true;
  }

  @override
  String toString() => '''Availability {
  alwaysDeprecated: $alwaysDeprecated
  alwaysUnavailable: $alwaysUnavailable
  ios: $ios
  macos: $macos
}''';
}

bool isObjCApiAvailable(clang_types.CXCursor cursor) {
  final api = ApiAvailability.fromCursor(cursor);
  return api.isAvailable(config.objCMinTargetVersion);
}
