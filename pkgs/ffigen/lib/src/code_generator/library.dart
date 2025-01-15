// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:yaml_edit/yaml_edit.dart';

import '../code_generator.dart';
import '../config_provider/config.dart' show Config;
import '../config_provider/config_types.dart';

import 'writer.dart';

/// Container for all Bindings.
class Library {
  /// List of bindings in this library.
  final List<Binding> bindings;

  final Writer writer;

  Library._(this.bindings, this.writer);

  static Library fromConfig({
    required Config config,
    required List<Binding> bindings,
  }) =>
      Library(
        name: config.wrapperName,
        description: config.wrapperDocComment,
        bindings: bindings,
        header: config.preamble,
        generateForPackageObjectiveC: config.generateForPackageObjectiveC,
        libraryImports: config.libraryImports.values.toList(),
        silenceEnumWarning: config.silenceEnumWarning,
        nativeEntryPoints:
            config.entryPoints.map((uri) => uri.toFilePath()).toList(),
      );

  factory Library({
    required String name,
    String? description,
    required List<Binding> bindings,
    String? header,
    bool generateForPackageObjectiveC = false,
    List<LibraryImport> libraryImports = const <LibraryImport>[],
    bool silenceEnumWarning = false,
    List<String> nativeEntryPoints = const <String>[],
  }) {
    // Seperate bindings which require lookup.
    final lookupBindings = <LookUpBinding>[];
    final nativeBindings = <LookUpBinding>[];
    FfiNativeConfig? nativeConfig;

    for (final binding in bindings.whereType<LookUpBinding>()) {
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
    final noLookUpBindings = bindings.whereType<NoLookUpBinding>().toList();

    final writer = Writer(
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

    return Library._(bindings, writer);
  }

  /// Generates [file] by generating C bindings.
  ///
  /// If format is true(default), the formatter will be called to format the
  /// generated file.
  void generateFile(File file, {bool format = true}) {
    if (!file.existsSync()) file.createSync(recursive: true);
    var bindings = generate();
    if (format) {
      final formatter =
          DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);
      bindings = formatter.format(bindings);
    }
    file.writeAsStringSync(bindings);
  }

  /// Generates [file] with the Objective C code needed for the bindings, if
  /// any.
  ///
  /// Returns whether bindings were generated.
  bool generateObjCFile(File file) {
    final objCString = writer.generateObjC(file.path);

    if (objCString == null) {
      // No ObjC code needed. If there's already a file (eg from an earlier
      // run), delete it so it's not accidentally included in the build.
      if (file.existsSync()) file.deleteSync();
      return false;
    }

    if (!file.existsSync()) file.createSync(recursive: true);
    file.writeAsStringSync(objCString);
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
  String generate() => writer.generate();

  @override
  bool operator ==(Object other) =>
      other is Library && other.generate() == generate();

  @override
  int get hashCode => generate().hashCode;
}
