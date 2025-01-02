// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:logging/logging.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../code_generator.dart';
import '../config_provider/config_types.dart';
import 'utils.dart';
import 'writer.dart';

final _logger = Logger('ffigen.code_generator.library');
final _formatter = DartFormatter();

/// Container for all Bindings.
class Library {
  /// List of bindings in this library.
  late List<Binding> bindings;

  late Writer _writer;
  Writer get writer => _writer;

  Library({
    required String name,
    String? description,
    required List<Binding> bindings,
    String? header,
    bool sort = false,
    bool generateForPackageObjectiveC = false,
    PackingValue? Function(Declaration)? packingOverride,
    List<LibraryImport>? libraryImports,
    bool silenceEnumWarning = false,
    List<String> nativeEntryPoints = const <String>[],
  }) {
    _findBindings(bindings, sort);

    /// Handle any declaration-declaration name conflicts and emit warnings.
    final declConflictHandler = UniqueNamer({});
    for (final b in this.bindings) {
      _warnIfPrivateDeclaration(b);
      _resolveIfNameConflicts(declConflictHandler, b);
    }

    // Override pack values according to config. We do this after declaration
    // conflicts have been handled so that users can target the generated names.
    if (packingOverride != null) {
      for (final b in this.bindings) {
        if (b is Struct) {
          final pack = packingOverride(Declaration(
            usr: b.usr,
            originalName: b.originalName,
          ));
          if (pack != null) {
            b.pack = pack.value;
          }
        }
      }
    }

    // Seperate bindings which require lookup.
    final lookupBindings = <LookUpBinding>[];
    final nativeBindings = <LookUpBinding>[];
    FfiNativeConfig? nativeConfig;

    for (final binding in this.bindings.whereType<LookUpBinding>()) {
      final nativeConfigForBinding = switch (binding) {
        Func() => binding.ffiNativeConfig,
        Global() => binding.nativeConfig,
        _ => null,
      };

      // At the moment, all bindings share their native config.
      nativeConfig ??= nativeConfigForBinding;

      final usesLookup =
          nativeConfigForBinding == null || !nativeConfigForBinding.enabled;
      (usesLookup ? lookupBindings : nativeBindings).add(binding);
    }
    final noLookUpBindings =
        this.bindings.whereType<NoLookUpBinding>().toList();

    _writer = Writer(
      lookUpBindings: lookupBindings,
      ffiNativeBindings: nativeBindings,
      nativeAssetId: nativeConfig?.assetId,
      noLookUpBindings: noLookUpBindings,
      className: name,
      classDocComment: description,
      header: header,
      additionalImports: libraryImports,
      generateForPackageObjectiveC: generateForPackageObjectiveC,
      silenceEnumWarning: silenceEnumWarning,
      nativeEntryPoints: nativeEntryPoints,
    );
  }

  void _findBindings(List<Binding> original, bool sort) {
    /// Get all dependencies (includes itself).
    final dependencies = <Binding>{};
    for (final b in original) {
      b.addDependencies(dependencies);
    }

    /// Save bindings.
    bindings = dependencies.toList();
    if (sort) {
      bindings.sortBy((b) => b.name);
    }
  }

  /// Logs a warning if generated declaration will be private.
  void _warnIfPrivateDeclaration(Binding b) {
    if (b.name.startsWith('_') && !b.isInternal) {
      _logger.warning("Generated declaration '${b.name}' starts with '_' "
          'and therefore will be private.');
    }
  }

  /// Resolves name conflict(if any) and logs a warning.
  void _resolveIfNameConflicts(UniqueNamer namer, Binding b) {
    // Print warning if name was conflicting and has been changed.
    if (namer.isUsed(b.name)) {
      final oldName = b.name;
      b.name = namer.makeUnique(b.name);

      _logger.warning("Resolved name conflict: Declaration '$oldName' "
          "and has been renamed to '${b.name}'.");
    } else {
      namer.markUsed(b.name);
    }
  }

  /// Generates [file] by generating C bindings.
  void generateFile(File file, {bool format = true}) {
    if (!file.existsSync()) file.createSync(recursive: true);
    var content = generate();
    if (format) {
      content = _formatter.format(content);
    }
    file.writeAsStringSync(content);
  }

  /// Generates [file] with the Objective C code needed for the bindings, if
  /// any.
  ///
  /// Returns whether bindings were generated.
  bool generateObjCFile(File file) {
    final bindings = writer.generateObjC(file.path);

    if (bindings == null) {
      // No ObjC code needed. If there's already a file (eg from an earlier
      // run), delete it so it's not accidentally included in the build.
      if (file.existsSync()) file.deleteSync();
      return false;
    }

    if (!file.existsSync()) file.createSync(recursive: true);
    file.writeAsStringSync(bindings);
    return true;
  }

  /// Generates [file] with symbol output yaml.
  void generateSymbolOutputFile(File file, String importPath) {
    if (!file.existsSync()) file.createSync(recursive: true);
    final symbolFileYamlMap = writer.generateSymbolOutputYamlMap(importPath);
    final yamlEditor = YamlEditor('');
    yamlEditor.update([], wrapAsYamlNode(symbolFileYamlMap));
    var yamlString = yamlEditor.toString();
    if (!yamlString.endsWith('\n')) {
      yamlString += '\n';
    }
    file.writeAsStringSync(yamlString);
  }

  /// Generates the bindings.
  String generate() {
    return writer.generate();
  }

  @override
  bool operator ==(Object other) =>
      other is Library && other.generate() == generate();

  @override
  int get hashCode => bindings.hashCode;
}
