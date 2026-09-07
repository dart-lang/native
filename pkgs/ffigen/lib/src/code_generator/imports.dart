// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen_symbols/ffigen_symbols.dart';

import '../context.dart';
import '../visitor/ast.dart';

import 'type.dart';

export 'package:ffigen_symbols/ffigen_symbols.dart'
    show Declaration, ImportedType, LibraryImport;

/// An AST wrapper for [ImportedType] which will be used in the generated code.
class AstImportedType extends Type implements ImportedType {
  final ImportedType importedType;

  const AstImportedType(this.importedType);

  @override
  LibraryImport get libraryImport => importedType.libraryImport;
  @override
  String get cType => importedType.cType;
  @override
  String get dartType => importedType.dartType;
  @override
  String get nativeType => importedType.nativeType;
  @override
  String? get defaultValue => importedType.defaultValue;
  @override
  bool get importedDartType => importedType.importedDartType;

  @override
  String getCType(Context context) =>
      '${context.libs.prefix(libraryImport)}.$cType';

  @override
  String getFfiDartType(Context context) {
    if (importedDartType) {
      return '${context.libs.prefix(libraryImport)}.$dartType';
    } else {
      return cType == dartType ? getCType(context) : dartType;
    }
  }

  @override
  String getNativeType(Context context, {String varName = ''}) =>
      '$nativeType $varName';

  @override
  bool get sameFfiDartAndCType => importedType.sameFfiDartAndCType;

  @override
  String toString() => importedType.toString();

  @override
  String? getDefaultValue(Context context) => defaultValue;

  @override
  void visit(Visitation visitation) => visitation.visitImportedType(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(libraryImport);
  }

  @override
  bool operator ==(Object other) {
    if (other is AstImportedType) {
      return importedType == other.importedType;
    }
    if (other is ImportedType) {
      return importedType == other;
    }
    return false;
  }

  @override
  int get hashCode => importedType.hashCode;
}

/// An unchecked type similar to [ImportedType] which exists in the generated
/// binding itself.
class SelfImportedType extends Type {
  final String cType;
  final String dartType;
  final String? defaultValue;

  SelfImportedType(this.cType, this.dartType, [this.defaultValue]);

  @override
  String getCType(Context context) => cType;

  @override
  String getFfiDartType(Context context) => dartType;

  @override
  bool get sameFfiDartAndCType => cType == dartType;

  @override
  String toString() => cType;
}

const ffiImport = LibraryImport('ffi', 'dart:ffi');
const ffiPkgImport = LibraryImport('pkg_ffi', 'package:ffi/ffi.dart');
const metaImport = LibraryImport('meta', 'package:meta/meta.dart');
const objcPkgImport = LibraryImport(
  'objc',
  'package:objective_c/objective_c.dart',
  importPathWhenImportedByPackageObjC: '../objective_c.dart',
);
const objcMajorVersion = 9;
const objcMinorVersion = 6;
const selfImport = LibraryImport('self', '');
final builtInLibraries = {
  for (final l in [
    ffiImport,
    ffiPkgImport,
    metaImport,
    objcPkgImport,
    selfImport,
  ])
    l.name: l,
};

final voidType = const AstImportedType(
  ImportedType(ffiImport, 'Void', 'void', 'void'),
);

final unsignedCharType = const AstImportedType(
  ImportedType(
    ffiImport,
    'UnsignedChar',
    'int',
    'unsigned char',
    defaultValue: '0',
  ),
);
final signedCharType = const AstImportedType(
  ImportedType(ffiImport, 'SignedChar', 'int', 'char', defaultValue: '0'),
);
final charType = const AstImportedType(
  ImportedType(ffiImport, 'Char', 'int', 'char', defaultValue: '0'),
);
final unsignedShortType = const AstImportedType(
  ImportedType(
    ffiImport,
    'UnsignedShort',
    'int',
    'unsigned short',
    defaultValue: '0',
  ),
);
final shortType = const AstImportedType(
  ImportedType(ffiImport, 'Short', 'int', 'short', defaultValue: '0'),
);
final unsignedIntType = const AstImportedType(
  ImportedType(
    ffiImport,
    'UnsignedInt',
    'int',
    'unsigned',
    defaultValue: '0',
  ),
);
final intType = const AstImportedType(
  ImportedType(ffiImport, 'Int', 'int', 'int', defaultValue: '0'),
);
final unsignedLongType = const AstImportedType(
  ImportedType(
    ffiImport,
    'UnsignedLong',
    'int',
    'unsigned long',
    defaultValue: '0',
  ),
);
final longType = const AstImportedType(
  ImportedType(ffiImport, 'Long', 'int', 'long', defaultValue: '0'),
);
final unsignedLongLongType = const AstImportedType(
  ImportedType(
    ffiImport,
    'UnsignedLongLong',
    'int',
    'unsigned long long',
    defaultValue: '0',
  ),
);
final longLongType = const AstImportedType(
  ImportedType(
    ffiImport,
    'LongLong',
    'int',
    'long long',
    defaultValue: '0',
  ),
);

final floatType = const AstImportedType(
  ImportedType(ffiImport, 'Float', 'double', 'float', defaultValue: '0.0'),
);
final doubleType = const AstImportedType(
  ImportedType(ffiImport, 'Double', 'double', 'double', defaultValue: '0.0'),
);

final sizeType = const AstImportedType(
  ImportedType(ffiImport, 'Size', 'int', 'size_t', defaultValue: '0'),
);
final wCharType = const AstImportedType(
  ImportedType(ffiImport, 'WChar', 'int', 'wchar_t', defaultValue: '0'),
);

final objCObjectType = const AstImportedType(
  ImportedType(
    objcPkgImport,
    'ObjCObjectImpl',
    'ObjCObjectImpl',
    'void',
  ),
);
final objCSelType = const AstImportedType(
  ImportedType(
    objcPkgImport,
    'ObjCSelector',
    'ObjCSelector',
    'struct objc_selector',
  ),
);
final objCBlockType = const AstImportedType(
  ImportedType(
    objcPkgImport,
    'ObjCBlockImpl',
    'ObjCBlockImpl',
    'id',
  ),
);
final objCProtocolType = const AstImportedType(
  ImportedType(
    objcPkgImport,
    'ObjCProtocolImpl',
    'ObjCProtocolImpl',
    'void',
  ),
);
final objCContextType = const AstImportedType(
  ImportedType(
    objcPkgImport,
    'DOBJC_Context',
    'DOBJC_Context',
    'DOBJC_Context',
  ),
);
