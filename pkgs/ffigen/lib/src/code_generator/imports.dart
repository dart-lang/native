// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'type.dart';
import 'writer.dart';

/// A library import which will be written as an import in the generated file.
class LibraryImport {
  final String name;
  final String _importPath;
  final String? importPathWhenImportedByPackageObjC;
  String prefix;

  LibraryImport(this.name, this._importPath,
      {this.importPathWhenImportedByPackageObjC})
      : prefix = name;

  @override
  bool operator ==(other) {
    return other is LibraryImport && name == other.name;
  }

  @override
  int get hashCode => name.hashCode;

  String importPath(bool generateForPackageObjectiveC) {
    if (!generateForPackageObjectiveC) return _importPath;
    return importPathWhenImportedByPackageObjC ?? _importPath;
  }
}

/// An imported type which will be used in the generated code.
class ImportedType extends Type {
  final LibraryImport libraryImport;
  final String cType;
  final String dartType;
  final String? defaultValue;

  ImportedType(this.libraryImport, this.cType, this.dartType,
      [this.defaultValue]);

  @override
  String getCType(Writer w) {
    w.markImportUsed(libraryImport);
    return '${libraryImport.prefix}.$cType';
  }

  @override
  String getFfiDartType(Writer w) => cType == dartType ? getCType(w) : dartType;

  @override
  bool get sameFfiDartAndCType => cType == dartType;

  @override
  String toString() => '${libraryImport.name}.$cType';

  @override
  String? getDefaultValue(Writer w) => defaultValue;
}

/// An unchecked type similar to [ImportedType] which exists in the generated
/// binding itself.
class SelfImportedType extends Type {
  final String cType;
  final String dartType;
  final String? defaultValue;

  SelfImportedType(this.cType, this.dartType, [this.defaultValue]);

  @override
  String getCType(Writer w) => cType;

  @override
  String getFfiDartType(Writer w) => dartType;

  @override
  bool get sameFfiDartAndCType => cType == dartType;

  @override
  String toString() => cType;
}

final ffiImport = LibraryImport('ffi', 'dart:ffi');
final ffiPkgImport = LibraryImport('pkg_ffi', 'package:ffi/ffi.dart');
final objcPkgImport = LibraryImport(
    'objc', 'package:objective_c/objective_c.dart',
    importPathWhenImportedByPackageObjC: '../objective_c.dart');
final self = LibraryImport('self', '');

final voidType = ImportedType(ffiImport, 'Void', 'void');

final unsignedCharType = ImportedType(ffiImport, 'UnsignedChar', 'int', '0');
final signedCharType = ImportedType(ffiImport, 'SignedChar', 'int', '0');
final charType = ImportedType(ffiImport, 'Char', 'int', '0');
final unsignedShortType = ImportedType(ffiImport, 'UnsignedShort', 'int', '0');
final shortType = ImportedType(ffiImport, 'Short', 'int', '0');
final unsignedIntType = ImportedType(ffiImport, 'UnsignedInt', 'int', '0');
final intType = ImportedType(ffiImport, 'Int', 'int', '0');
final unsignedLongType = ImportedType(ffiImport, 'UnsignedLong', 'int', '0');
final longType = ImportedType(ffiImport, 'Long', 'int', '0');
final unsignedLongLongType =
    ImportedType(ffiImport, 'UnsignedLongLong', 'int', '0');
final longLongType = ImportedType(ffiImport, 'LongLong', 'int', '0');

final floatType = ImportedType(ffiImport, 'Float', 'double', '0.0');
final doubleType = ImportedType(ffiImport, 'Double', 'double', '0.0');

final sizeType = ImportedType(ffiImport, 'Size', 'int', '0');
final wCharType = ImportedType(ffiImport, 'WChar', 'int', '0');

final objCObjectType = ImportedType(objcPkgImport, 'ObjCObject', 'ObjCObject');
final objCSelType = ImportedType(objcPkgImport, 'ObjCSelector', 'ObjCSelector');
final objCBlockType = ImportedType(objcPkgImport, 'ObjCBlock', 'ObjCBlock');
