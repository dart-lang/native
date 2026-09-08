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

/// A container for symbols exported by an ffigen-generated file.
///
/// A symbol file contains a mapping from declaration USR (Unique Symbol
/// Resolution) strings to [ImportedType] definitions.
///
/// Pre-generated bindings can export a top-level [FfigenSymbols] instance so
/// that other packages can reuse declarations without reparsing the original
/// C/ObjC headers.
///
/// Example:
///
/// ```dart
/// const symbols = FfigenSymbols(
///   formatVersion: '1.0.0',
///   symbols: {
///     'c:@F@my_func': ImportedType(
///       _import,
///       'my_func',
///       'my_func',
///       'my_func',
///       importedDartType: true,
///     ),
///   },
/// );
/// ```
class FfigenSymbols {
  /// The current format version for symbol files.
  static const currentFormatVersion = '1.0.0';

  /// The format version of this symbol file.
  final String formatVersion;

  /// The mapping of symbol USRs to their imported type definitions.
  final Map<String, ImportedType> symbols;

  const FfigenSymbols({
    this.formatVersion = currentFormatVersion,
    required this.symbols,
  });

  /// Returns the [ImportedType] for the given declaration [usr], if present.
  ImportedType? operator [](String usr) => symbols[usr];

  /// Returns whether a symbol with the given [usr] is present.
  bool containsKey(String usr) => symbols.containsKey(usr);

  /// The number of symbols defined.
  int get length => symbols.length;

  /// Whether no symbols are defined.
  bool get isEmpty => symbols.isEmpty;

  /// Whether any symbols are defined.
  bool get isNotEmpty => symbols.isNotEmpty;

  /// The symbol USR keys.
  Iterable<String> get keys => symbols.keys;

  /// The imported type definitions.
  Iterable<ImportedType> get values => symbols.values;

  /// The entries of symbol USRs to their imported type definitions.
  Iterable<MapEntry<String, ImportedType>> get entries => symbols.entries;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FfigenSymbols) return false;
    if (formatVersion != other.formatVersion) return false;
    if (symbols.length != other.symbols.length) return false;
    for (final entry in symbols.entries) {
      if (other.symbols[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    formatVersion,
    Object.hashAllUnordered(
      symbols.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() =>
      'FfigenSymbols(formatVersion: $formatVersion, ${symbols.length} symbols)';
}

/// Alias for [FfigenSymbols].
typedef Symbols = FfigenSymbols;

