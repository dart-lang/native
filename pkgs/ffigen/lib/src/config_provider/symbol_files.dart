// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:package_config/package_config.dart';
import 'package:yaml/yaml.dart';

import '../code_generator.dart';
import '../code_generator/scope.dart';
import '../strings.dart' as strings;
import 'config_types.dart';

/// Loads type mappings from the given [symbolFiles].
///
/// If [packageConfig] is provided, it is used to resolve `package:` URIs.
/// If any URI is a `package:` URI and [packageConfig] is null, an
/// [ArgumentError] is thrown.
///
/// If [libraryImports] is provided, existing imports will be reused and new
/// imports will be added to it.
Map<String, ImportedType> loadSymbolFiles(
  Iterable<Uri> symbolFiles, {
  PackageConfig? packageConfig,
  Map<String, LibraryImport>? libraryImports,
}) {
  final libImports = libraryImports ?? <String, LibraryImport>{};
  final namer = Namer({
    ...libImports.keys,
    strings.defaultSymbolFileImportPrefix,
  });
  for (final l in libImports.values) {
    namer.markUsed(l.name);
  }
  final usrTypeMappings = <String, ImportedType>{};

  for (final uri in symbolFiles) {
    final File file;
    if (uri.isScheme('package')) {
      if (packageConfig == null) {
        throw ArgumentError(
          'packageConfig is required to resolve package: URIs.',
        );
      }
      final resolved = packageConfig.resolve(uri);
      if (resolved == null) {
        throw FormatException('Unable to resolve package URI: $uri');
      }
      file = File.fromUri(resolved);
    } else if (uri.isScheme('file')) {
      file = File.fromUri(uri);
    } else if (!uri.hasScheme) {
      file = File(uri.path);
    } else {
      throw FormatException('Unsupported URI scheme: ${uri.scheme}');
    }

    final yamlContent = file.readAsStringSync();
    final Object? yamlMap;
    try {
      yamlMap = loadYaml(yamlContent);
    } catch (e) {
      throw FormatException('Failed to parse YAML file $uri: $e');
    }
    if (yamlMap is! YamlMap) {
      throw FormatException('Symbol file $uri is not a valid YAML map.');
    }

    final formatVersion = yamlMap[strings.formatVersion];
    if (formatVersion is! String ||
        formatVersion.split('.')[0] !=
            strings.symbolFileFormatVersion.split('.')[0]) {
      throw FormatException(
        'Incompatible format versions for file $uri: '
        '${strings.symbolFileFormatVersion}(ours), $formatVersion(theirs).',
      );
    }

    final files = yamlMap[strings.files];
    if (files is YamlMap) {
      for (final fileEntry in files.entries) {
        final filePath = fileEntry.key as String;
        final fileConfig = fileEntry.value;
        if (fileConfig is! YamlMap) continue;

        LibraryImport? libraryImport;
        for (final existing in libImports.values) {
          if (existing.importPath(false) == filePath) {
            libraryImport = existing;
            break;
          }
        }
        if (libraryImport == null && libImports.containsKey(filePath)) {
          libraryImport = libImports[filePath];
        }
        if (libraryImport == null) {
          final prefix = namer.add(
            strings.defaultSymbolFileImportPrefix,
            SymbolKind.lib,
          );
          libraryImport = LibraryImport(prefix, filePath);
          libImports[prefix] = libraryImport;
        }

        final symbols = fileConfig[strings.symbols];
        if (symbols is YamlMap) {
          for (final symbolEntry in symbols.entries) {
            final usr = symbolEntry.key as String;
            final value = symbolEntry.value;
            if (value is YamlMap) {
              final name = value[strings.name] as String;
              final dartName = (value[strings.dartName] as String?) ?? name;
              usrTypeMappings[usr] = ImportedType(
                libraryImport,
                name,
                dartName,
                name,
                importedDartType: true,
              );
            }
          }
        }
      }
    }
  }

  return usrTypeMappings;
}

/// Returns a function suitable for use as `Input.importType` that imports
/// declarations defined in the given [symbolFiles].
///
/// If [packageConfig] is provided, it is used to resolve `package:` URIs.
ImportedType? Function(Declaration) importFromSymbolFiles(
  Iterable<Uri> symbolFiles, {
  PackageConfig? packageConfig,
}) {
  final typeMap = loadSymbolFiles(symbolFiles, packageConfig: packageConfig);
  return (Declaration decl) => decl.usr.isNotEmpty ? typeMap[decl.usr] : null;
}

/// Returns a function suitable for use as `Input.importType` that imports
/// declarations defined in the given [symbolFile].
///
/// If [packageConfig] is provided, it is used to resolve `package:` URIs.
ImportedType? Function(Declaration) importFromSymbolFile(
  Uri symbolFile, {
  PackageConfig? packageConfig,
}) => importFromSymbolFiles([symbolFile], packageConfig: packageConfig);
