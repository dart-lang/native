// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../context.dart';
import '../visitor/ast.dart';

import 'type.dart';

/// A library import which will be written as an import in the generated file.
class LibraryImport extends AstNode {
  /// The identifier prefix used to reference symbols from this library in the
  /// generated Dart file.
  final String name;

  /// The URI string or path of the library to import (e.g. `'dart:ffi'` or
  /// `'package:my_pkg/my_pkg.dart'`).
  final String _importPath;

  /// An optional import path override used when generating code for
  /// `package:objective_c`.
  final String? _importPathWhenImportedByPackageObjC;

  /// Creates a [LibraryImport] with the given [name] (used as prefix/identifier)
  /// and [_importPath].
  const LibraryImport(
    this.name,
    this._importPath, {
    String? importPathWhenImportedByPackageObjC,
  }) : _importPathWhenImportedByPackageObjC =
           importPathWhenImportedByPackageObjC;

  @override
  bool operator ==(Object other) {
    return other is LibraryImport && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  // The import path, which may be different if this library is being imported
  // into package:objective_c's generated code.
  String importPath(bool generateForPackageObjectiveC) {
    if (!generateForPackageObjectiveC) return _importPath;
    return _importPathWhenImportedByPackageObjC ?? _importPath;
  }

  @override
  String toString() => '$name $_importPath';

  @override
  void visit(Visitation visitation) => visitation.visitLibraryImport(this);
}

/// An imported type which will be used in the generated code.
class ImportedType extends Type {
  /// The [LibraryImport] representing the library where this type is defined.
  final LibraryImport libraryImport;

  /// The C-type representation in FFI (e.g. `'Int64'`, `'Pointer<Void>'`, or
  /// the name of an imported struct).
  final String cType;

  /// The Dart representation of the type (e.g. `'int'`, `'double'`, or the
  /// Dart class name).
  final String dartType;

  /// The C/native type string as it appears in C declarations (e.g. `'time_t'`).
  final String nativeType;

  /// An optional default value expression for this type when used as an
  /// optional parameter.
  final String? defaultValue;

  /// Whether the [dartType] is an import from the [libraryImport].
  ///
  /// When `true`, [dartType] will be prefixed with the import prefix in
  /// generated Dart signatures. When `false`, [dartType] is treated as a core
  /// or locally available type unless [cType] equals [dartType].
  final bool importedDartType;

  /// Creates an [ImportedType].
  ///
  /// [libraryImport] specifies the library providing the type.
  /// [cType] is the FFI representation (e.g. `'Int64'`, `'Pointer<Void>'`).
  /// [dartType] is the Dart representation (e.g. `'int'`, `'MyClass'`).
  /// [nativeType] is the native C type name (e.g. `'time_t'`).
  /// [defaultValue] is an optional default value expression.
  /// [importedDartType] indicates whether [dartType] should be prefixed by the
  /// import prefix.
  ImportedType(
    this.libraryImport,
    this.cType,
    this.dartType,
    this.nativeType, {
    this.defaultValue,
    this.importedDartType = false,
  });

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
  bool get sameFfiDartAndCType => cType == dartType;

  @override
  String toString() => '${libraryImport.name}.$cType';

  @override
  String? getDefaultValue(Context context) => defaultValue;

  @override
  void visit(Visitation visitation) => visitation.visitImportedType(this);

  @override
  void visitChildren(Visitor visitor) {
    super.visitChildren(visitor);
    visitor.visit(libraryImport);
  }
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

final voidType = ImportedType(ffiImport, 'Void', 'void', 'void');

final unsignedCharType = ImportedType(
  ffiImport,
  'UnsignedChar',
  'int',
  'unsigned char',
  defaultValue: '0',
);
final signedCharType = ImportedType(
  ffiImport,
  'SignedChar',
  'int',
  'char',
  defaultValue: '0',
);
final charType = ImportedType(
  ffiImport,
  'Char',
  'int',
  'char',
  defaultValue: '0',
);
final unsignedShortType = ImportedType(
  ffiImport,
  'UnsignedShort',
  'int',
  'unsigned short',
  defaultValue: '0',
);
final shortType = ImportedType(
  ffiImport,
  'Short',
  'int',
  'short',
  defaultValue: '0',
);
final unsignedIntType = ImportedType(
  ffiImport,
  'UnsignedInt',
  'int',
  'unsigned',
  defaultValue: '0',
);
final intType = ImportedType(ffiImport, 'Int', 'int', 'int', defaultValue: '0');
final unsignedLongType = ImportedType(
  ffiImport,
  'UnsignedLong',
  'int',
  'unsigned long',
  defaultValue: '0',
);
final longType = ImportedType(
  ffiImport,
  'Long',
  'int',
  'long',
  defaultValue: '0',
);
final unsignedLongLongType = ImportedType(
  ffiImport,
  'UnsignedLongLong',
  'int',
  'unsigned long long',
  defaultValue: '0',
);
final longLongType = ImportedType(
  ffiImport,
  'LongLong',
  'int',
  'long long',
  defaultValue: '0',
);

final floatType = ImportedType(
  ffiImport,
  'Float',
  'double',
  'float',
  defaultValue: '0.0',
);
final doubleType = ImportedType(
  ffiImport,
  'Double',
  'double',
  'double',
  defaultValue: '0.0',
);

final sizeType = ImportedType(
  ffiImport,
  'Size',
  'int',
  'size_t',
  defaultValue: '0',
);
final wCharType = ImportedType(
  ffiImport,
  'WChar',
  'int',
  'wchar_t',
  defaultValue: '0',
);

final objCObjectType = ImportedType(
  objcPkgImport,
  'ObjCObjectImpl',
  'ObjCObjectImpl',
  'void',
);
final objCSelType = ImportedType(
  objcPkgImport,
  'ObjCSelector',
  'ObjCSelector',
  'struct objc_selector',
);
final objCBlockType = ImportedType(
  objcPkgImport,
  'ObjCBlockImpl',
  'ObjCBlockImpl',
  'id',
);
final objCProtocolType = ImportedType(
  objcPkgImport,
  'ObjCProtocolImpl',
  'ObjCProtocolImpl',
  'void',
);
final objCContextType = ImportedType(
  objcPkgImport,
  'DOBJC_Context',
  'DOBJC_Context',
  'DOBJC_Context',
);
