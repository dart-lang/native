// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'ctool.dart';
import 'language.dart';
import 'linker_options.dart';
import 'linkmode.dart';
import 'optimization_level.dart';
import 'output_type.dart';
import 'run_cbuilder.dart';

/// Specification for linking an artifact with a C linker.
class CLinker extends CTool implements Linker {
  final LinkerOptions linkerOptions;

  CLinker.library({
    required super.name,
    super.packageName,
    super.assetName,
    required this.linkerOptions,
    super.sources = const [],
    super.includes = const [],
    super.forcedIncludes = const [],
    super.frameworks = CTool.defaultFrameworks,
    super.libraries = const [],
    super.libraryDirectories = CTool.defaultLibraryDirectories,
    @visibleForTesting super.installName,
    super.flags = const [],
    super.defines = const {},
    super.pic = true,
    super.std,
    super.language = Language.c,
    super.cppLinkStdLib,
    super.linkModePreference,
    super.optimizationLevel = OptimizationLevel.o3,
  }) : super(type: OutputType.library);

  /// Runs the C Linker with on this C build spec.
  ///
  /// Completes with an error if the linking fails.
  @override
  Future<void> run({
    required LinkInput input,
    required LinkOutputBuilder output,
    required Logger? logger,
  }) async {
    final outDir = input.outputDirectory;
    final packageRoot = input.packageRoot;
    await Directory.fromUri(outDir).create(recursive: true);
    final linkMode = getLinkMode(
      linkModePreference ?? input.config.code.linkModePreference,
    );
    final libUri = outDir.resolve(
      input.config.code.targetOS.libraryFileName(name, linkMode),
    );
    final sources = [
      for (final source in this.sources)
        packageRoot.resolveUri(Uri.file(source)),
    ];
    final includes = [
      for (final directory in this.includes)
        packageRoot.resolveUri(Uri.file(directory)),
    ];
    final libraryDirectories = [
      for (final directory in this.libraryDirectories)
        outDir.resolveUri(Uri.file(directory)),
    ];
    final task = RunCBuilder(
      input: input,
      codeConfig: input.config.code,
      linkerOptions: linkerOptions,
      logger: logger,
      sources: sources,
      includes: includes,
      frameworks: frameworks,
      libraries: libraries,
      libraryDirectories: libraryDirectories,
      dynamicLibrary: linkMode == DynamicLoadingBundled() ? libUri : null,
      staticLibrary: linkMode == StaticLinking() ? libUri : null,
      // ignore: invalid_use_of_visible_for_testing_member
      installName: installName,
      flags: flags,
      defines: defines,
      pic: pic,
      std: std,
      language: language,
      cppLinkStdLib: cppLinkStdLib,
      optimizationLevel: optimizationLevel,
    );
    await task.run();

    if (assetName != null) {
      output.assets.code.add(
        CodeAsset(
          package: packageName ?? input.packageName,
          name: assetName!,
          file: libUri,
          linkMode: linkMode,
        ),
      );
    }
    final includeFiles = await Stream.fromIterable(includes)
        .asyncExpand(
          (include) => Directory(include.toFilePath())
              .list(recursive: true)
              .where((entry) => entry is File)
              .map((file) => file.uri),
        )
        .toList();

    output.addDependencies({
      // Note: We use a Set here to deduplicate the dependencies.
      ...sources,
      ...includeFiles,
    });
  }
}
