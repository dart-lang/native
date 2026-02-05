// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:yaml_edit/yaml_edit.dart';

import '../code_generator.dart';
import '../code_generator/utils.dart';
import '../config_provider/config.dart';
import '../context.dart';

import 'writer.dart';

/// Container for all Bindings.
class Library {
  /// List of bindings in this library.
  final List<Binding> bindings;

  final Writer writer;
  final Context context;

  Library._(this.bindings, this.writer, this.context);

  static Library fromContext({
    required List<Binding> bindings,
    required Context context,
  }) => Library(
    description: switch (context.config.output.style) {
      final DynamicLibraryBindings e => e.wrapperDocComment,
      _ => null,
    },
    bindings: bindings,
    header: context.config.output.preamble,
    generateForPackageObjectiveC:
        // ignore: deprecated_member_use_from_same_package
        context.config.objectiveC?.generateForPackageObjectiveC ?? false,
    // ignore: deprecated_member_use_from_same_package
    libraryImports: context.config.libraryImports,
    silenceEnumWarning: context.config.enums.silenceWarning,
    nativeEntryPoints: context.config.headers.entryPoints
        .map((uri) => uri.toFilePath())
        .toList(),
    context: context,
  );

  factory Library({
    String? description,
    required List<Binding> bindings,
    String? header,
    bool generateForPackageObjectiveC = false,
    List<LibraryImport> libraryImports = const <LibraryImport>[],
    bool silenceEnumWarning = false,
    List<String> nativeEntryPoints = const <String>[],
    required Context context,
  }) {
    // Seperate bindings which require lookup.
    final lookupBindings = <LookUpBinding>[];
    final nativeBindings = <LookUpBinding>[];
    String? nativeAssetId;

    final outputStyle = context.config.output.style;
    final outputStyleAssetId = outputStyle is NativeExternalBindings
        ? outputStyle.assetId
        : null;

    for (final binding in bindings.whereType<LookUpBinding>()) {
      final loadFromNativeAsset = binding.loadFromNativeAsset;

      // At the moment, all bindings share their native config.
      if (loadFromNativeAsset) nativeAssetId = outputStyleAssetId;

      (loadFromNativeAsset ? nativeBindings : lookupBindings).add(binding);
    }
    final noLookUpBindings = bindings.whereType<NoLookUpBinding>().toList();

    final writer = Writer(
      lookUpBindings: lookupBindings,
      ffiNativeBindings: nativeBindings,
      nativeAssetId: nativeAssetId,
      noLookUpBindings: noLookUpBindings,
      classDocComment: description,
      header: header,
      additionalImports: libraryImports.map(context.libs.canonicalize).toList(),
      generateForPackageObjectiveC: generateForPackageObjectiveC,
      silenceEnumWarning: silenceEnumWarning,
      nativeEntryPoints: nativeEntryPoints,
      context: context,
    );

    return Library._(bindings, writer, context);
  }

  /// Generates [file] by generating C bindings.
  ///
  /// If format is true(default), the formatter will be called to format the
  /// generated file.
  void generateFile(File file, {bool format = true}) {
    if (!file.existsSync()) file.createSync(recursive: true);
    file.writeAsStringSync(generate());
    if (format) {
      final result = Process.runSync(dartExecutable, [
        'format',
        file.absolute.path,
      ], workingDirectory: file.parent.absolute.path);
      if (result.exitCode != 0) {
        context.logger.severe(
          'Formatting failed\n${result.stdout}\n${result.stderr}',
        );
      }
    }
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
