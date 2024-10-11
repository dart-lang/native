// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/imports.dart' show LibraryImport;

import 'type.dart';
import 'writer.dart';

export 'package:ffigen/src/code_generator/imports.dart' show LibraryImport;

/// An imported type which will be used in the generated code.
class ImportedType extends Type {
  final LibraryImport libraryImport;
  final String cType;
  final String dartType;
  final String nativeType;
  final String? defaultValue;

  ImportedType(this.libraryImport, this.cType, this.dartType, this.nativeType,
      [this.defaultValue]);

  @override
  String getCType(Writer w) {
    w.markImportUsed(libraryImport);
    return '${libraryImport.prefix}.$cType';
  }

  @override
  String getFfiDartType(Writer w) => cType == dartType ? getCType(w) : dartType;

  @override
  String getNativeType({String varName = ''}) => '$nativeType $varName';

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

final voidType = ImportedType(ffiImport, 'Void', 'void', 'void');

final unsignedCharType =
    ImportedType(ffiImport, 'UnsignedChar', 'int', 'unsigned char', '0');
final signedCharType =
    ImportedType(ffiImport, 'SignedChar', 'int', 'char', '0');
final charType = ImportedType(ffiImport, 'Char', 'int', 'char', '0');
final unsignedShortType =
    ImportedType(ffiImport, 'UnsignedShort', 'int', 'unsigned short', '0');
final shortType = ImportedType(ffiImport, 'Short', 'int', 'short', '0');
final unsignedIntType =
    ImportedType(ffiImport, 'UnsignedInt', 'int', 'unsigned', '0');
final intType = ImportedType(ffiImport, 'Int', 'int', 'int', '0');
final unsignedLongType =
    ImportedType(ffiImport, 'UnsignedLong', 'int', 'unsigned long', '0');
final longType = ImportedType(ffiImport, 'Long', 'int', 'long', '0');
final unsignedLongLongType = ImportedType(
    ffiImport, 'UnsignedLongLong', 'int', 'unsigned long long', '0');
final longLongType =
    ImportedType(ffiImport, 'LongLong', 'int', 'long long', '0');

final floatType = ImportedType(ffiImport, 'Float', 'double', 'float', '0.0');
final doubleType = ImportedType(ffiImport, 'Double', 'double', 'double', '0.0');

final sizeType = ImportedType(ffiImport, 'Size', 'int', 'size_t', '0');
final wCharType = ImportedType(ffiImport, 'WChar', 'int', 'wchar_t', '0');

final objCObjectType =
    ImportedType(objcPkgImport, 'ObjCObject', 'ObjCObject', 'void');
final objCSelType =
    ImportedType(objcPkgImport, 'ObjCSelector', 'ObjCSelector', 'void');
final objCBlockType =
    ImportedType(objcPkgImport, 'ObjCBlock', 'ObjCBlock', 'id');
