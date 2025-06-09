// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../visitor/ast.dart';

import 'type.dart';
import 'writer.dart';

/// A library import which will be written as an import in the generated file.
class LibraryImport extends AstNode {
  final String name;
  final String _importPath;
  final String? _importPathWhenImportedByPackageObjC;

  String prefix;

  LibraryImport(this.name, this._importPath,
      {String? importPathWhenImportedByPackageObjC})
      : _importPathWhenImportedByPackageObjC =
            importPathWhenImportedByPackageObjC,
        prefix = name;

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
}

/// An imported type which will be used in the generated code.
class ImportedType extends Type {
  final LibraryImport libraryImport;
  final String cType;
  final String dartType;
  final String nativeType;
  final String? defaultValue;

  /// Whether the [dartType] is an import from the [libraryImport].
  final bool importedDartType;

  ImportedType(
    this.libraryImport,
    this.cType,
    this.dartType,
    this.nativeType, {
    this.defaultValue,
    this.importedDartType = false,
  });

  @override
  String getCType(Writer w) {
    w.markImportUsed(libraryImport);
    return '${libraryImport.prefix}.$cType';
  }

  @override
  String getFfiDartType(Writer w) {
    if (importedDartType) {
      w.markImportUsed(libraryImport);
      return '${libraryImport.prefix}.$dartType';
    } else {
      return cType == dartType ? getCType(w) : dartType;
    }
  }

  @override
  String getNativeType({String varName = ''}) => '$nativeType $varName';

  @override
  bool get sameFfiDartAndCType => cType == dartType;

  @override
  String toString() => '${libraryImport.name}.$cType';

  @override
  String? getDefaultValue(Writer w) => defaultValue;

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
final allLibraries = [ffiImport, ffiPkgImport, objcPkgImport, self];

final voidType = ImportedType(ffiImport, 'Void', 'void', 'void');

final unsignedCharType = ImportedType(
    ffiImport, 'UnsignedChar', 'int', 'unsigned char',
    defaultValue: '0');
final signedCharType =
    ImportedType(ffiImport, 'SignedChar', 'int', 'char', defaultValue: '0');
final charType =
    ImportedType(ffiImport, 'Char', 'int', 'char', defaultValue: '0');
final unsignedShortType = ImportedType(
    ffiImport, 'UnsignedShort', 'int', 'unsigned short',
    defaultValue: '0');
final shortType =
    ImportedType(ffiImport, 'Short', 'int', 'short', defaultValue: '0');
final unsignedIntType = ImportedType(
    ffiImport, 'UnsignedInt', 'int', 'unsigned',
    defaultValue: '0');
final intType = ImportedType(ffiImport, 'Int', 'int', 'int', defaultValue: '0');
final unsignedLongType = ImportedType(
    ffiImport, 'UnsignedLong', 'int', 'unsigned long',
    defaultValue: '0');
final longType =
    ImportedType(ffiImport, 'Long', 'int', 'long', defaultValue: '0');
final unsignedLongLongType = ImportedType(
    ffiImport, 'UnsignedLongLong', 'int', 'unsigned long long',
    defaultValue: '0');
final longLongType =
    ImportedType(ffiImport, 'LongLong', 'int', 'long long', defaultValue: '0');

final floatType =
    ImportedType(ffiImport, 'Float', 'double', 'float', defaultValue: '0.0');
final doubleType =
    ImportedType(ffiImport, 'Double', 'double', 'double', defaultValue: '0.0');

final sizeType =
    ImportedType(ffiImport, 'Size', 'int', 'size_t', defaultValue: '0');
final wCharType =
    ImportedType(ffiImport, 'WChar', 'int', 'wchar_t', defaultValue: '0');

final objCObjectType =
    ImportedType(objcPkgImport, 'ObjCObject', 'ObjCObject', 'void');
final objCSelType = ImportedType(
    objcPkgImport, 'ObjCSelector', 'ObjCSelector', 'struct objc_selector');
final objCBlockType =
    ImportedType(objcPkgImport, 'ObjCBlockImpl', 'ObjCBlockImpl', 'id');
final objCProtocolType =
    ImportedType(objcPkgImport, 'ObjCProtocol', 'ObjCProtocol', 'void');
final objCContextType = ImportedType(
    objcPkgImport, 'DOBJC_Context', 'DOBJC_Context', 'DOBJC_Context');
