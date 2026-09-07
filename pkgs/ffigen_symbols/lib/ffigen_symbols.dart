// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Symbol definitions exported and imported by ffigen.
library;

/// Represents a C/ObjC declaration.
class Declaration {
  /// The unique symbol resolution (USR) string for this declaration.
  final String usr;

  /// The original name of the declaration in the C/ObjC header.
  final String originalName;

  const Declaration({required this.usr, required this.originalName});

  @override
  bool operator ==(Object other) =>
      other is Declaration &&
      usr == other.usr &&
      originalName == other.originalName;

  @override
  int get hashCode => Object.hash(usr, originalName);

  @override
  String toString() => 'Declaration($usr, $originalName)';
}

/// A library import which will be written as an import in the generated file.
class LibraryImport {
  final String name;
  final String _importPath;
  final String? _importPathWhenImportedByPackageObjC;

  const LibraryImport(
    this.name,
    this._importPath, {
    String? importPathWhenImportedByPackageObjC,
  }) : _importPathWhenImportedByPackageObjC =
           importPathWhenImportedByPackageObjC;

  @override
  bool operator ==(Object other) {
    return other is LibraryImport &&
        name == other.name &&
        _importPath == other._importPath &&
        _importPathWhenImportedByPackageObjC ==
            other._importPathWhenImportedByPackageObjC;
  }

  @override
  int get hashCode => Object.hash(
        name,
        _importPath,
        _importPathWhenImportedByPackageObjC,
      );

  /// The import path, which may be different if this library is being imported
  /// into package:objective_c's generated code.
  String importPath(bool generateForPackageObjectiveC) {
    if (!generateForPackageObjectiveC) return _importPath;
    return _importPathWhenImportedByPackageObjC ?? _importPath;
  }

  @override
  String toString() => '$name $_importPath';
}

/// An imported type which will be used in the generated code.
class ImportedType {
  final LibraryImport libraryImport;
  final String cType;
  final String dartType;
  final String nativeType;
  final String? defaultValue;

  /// Whether the [dartType] is an import from the [libraryImport].
  final bool importedDartType;

  const ImportedType(
    this.libraryImport,
    this.cType,
    this.dartType,
    this.nativeType, {
    this.defaultValue,
    this.importedDartType = false,
  });

  bool get sameFfiDartAndCType => cType == dartType;

  @override
  bool operator ==(Object other) =>
      other is ImportedType &&
      libraryImport == other.libraryImport &&
      cType == other.cType &&
      dartType == other.dartType &&
      nativeType == other.nativeType &&
      defaultValue == other.defaultValue &&
      importedDartType == other.importedDartType;

  @override
  int get hashCode => Object.hash(
    libraryImport,
    cType,
    dartType,
    nativeType,
    defaultValue,
    importedDartType,
  );

  @override
  String toString() => '${libraryImport.name}.$cType';
}
