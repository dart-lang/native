// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'code_buffer.dart';
import 'path_resolver.dart';

/// Emits `importType` configuration and related imports/type mappings.
class ImportTypeEmitter {
  final Map<dynamic, dynamic> yamlMap;
  final PathResolver pathResolver;

  ImportTypeEmitter({required this.yamlMap, required this.pathResolver});

  bool get hasSymbolFiles {
    final importMap = yamlMap['import'];
    if (importMap is Map && importMap.containsKey('symbol-files')) {
      final syms = importMap['symbol-files'] as List?;
      return syms != null && syms.isNotEmpty;
    }
    return false;
  }

  bool get hasTypeMap {
    final typeMap = yamlMap['type-map'];
    return typeMap is Map && typeMap.isNotEmpty;
  }

  bool get needsImportType => hasSymbolFiles || hasTypeMap;

  /// Emits any top-level helper definitions needed before `getConfig`.
  void emitTopLevelDeclarations(CodeBuffer buffer) {
    if (!hasTypeMap) return;

    final libImports = yamlMap['library-imports'] as Map? ?? {};
    final usedLibs = <String>{};

    final typeMap = yamlMap['type-map'] as Map;
    for (final section in typeMap.values) {
      if (section is Map) {
        for (final entry in section.values) {
          if (entry is Map && entry.containsKey('lib')) {
            usedLibs.add(entry['lib'] as String);
          }
        }
      }
    }

    for (final lib in usedLibs) {
      final varName = _libImportVarName(lib);
      if (lib == 'ffi') {
        buffer.writeln("const $varName = LibraryImport('ffi', 'dart:ffi');");
      } else if (libImports.containsKey(lib)) {
        final importPath = libImports[lib] as String;
        buffer.writeln(
          "const $varName = LibraryImport('$lib', '$importPath');",
        );
      } else {
        buffer.writeln("const $varName = LibraryImport('$lib', '$lib');");
      }
    }

    buffer.writeln();
    buffer.writeln('ImportedType? importType(Declaration declaration) {');
    buffer.indent();

    for (final section in typeMap.values) {
      if (section is Map) {
        for (final entry in section.entries) {
          final typeName = entry.key as String;
          final typeInfo = entry.value as Map;
          final lib = typeInfo['lib'] as String? ?? 'ffi';
          final cType = typeInfo['c-type'] as String? ?? typeName;
          final dartType = typeInfo['dart-type'] as String? ?? typeName;
          final libVar = _libImportVarName(lib);

          buffer.writeln("if (declaration.originalName == '$typeName') {");
          buffer.indent();
          buffer.writeln(
            "return ImportedType($libVar, '$cType', '$dartType', '$typeName');",
          );
          buffer.dedent();
          buffer.writeln('}');
        }
      }
    }

    buffer.writeln('return null;');
    buffer.dedent();
    buffer.writeln('}');
    buffer.writeln();
  }

  /// Emits the `importType:` argument inside `FfiGenerator`.
  void emitImportTypeArgument(CodeBuffer buffer) {
    if (hasSymbolFiles && !hasTypeMap) {
      final importMap = yamlMap['import'] as Map;
      final syms = (importMap['symbol-files'] as List).cast<String>();
      if (syms.length == 1) {
        final pathExpr = pathResolver.emitPath(syms.first);
        buffer.writeln('importType: importFromSymbolFile($pathExpr),');
      } else {
        final symExprs = syms.map(pathResolver.emitPath).join(', ');
        buffer.writeln('importType: importFromSymbolFiles([$symExprs]),');
      }
    } else if (hasTypeMap) {
      buffer.writeln('importType: importType,');
    }
  }

  static String _libImportVarName(String lib) {
    if (lib == 'ffi') return 'ffiImport';
    final parts = lib.split(RegExp(r'[-_]'));
    final camel =
        parts.first.toLowerCase() +
        parts
            .skip(1)
            .map(
              (p) => p.isEmpty
                  ? ''
                  : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}',
            )
            .join();
    if (camel.toLowerCase().endsWith('import')) {
      return camel;
    }
    return '${camel}Import';
  }
}
