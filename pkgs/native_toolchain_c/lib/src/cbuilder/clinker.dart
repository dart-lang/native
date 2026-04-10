// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'cbuilder.dart';
import 'clibrary.dart';
import 'ctool.dart';
import 'linker_options.dart';
import 'linkmode.dart';
import 'logger.dart';
import 'output_type.dart';
import 'run_cbuilder.dart';

/// Specification for linking an artifact with a C linker.
class CLinker extends CTool implements Linker {
  final LinkerOptions? linkerOptions;

  CLinker.library({
    required super.name,
    super.packageName,
    super.assetName,
    this.linkerOptions,
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
    super.language = .c,
    super.cppLinkStdLib,
    super.linkModePreference,
    super.optimizationLevel = .o3,
  }) : super(type: OutputType.library);

  /// Runs the C Linker with on this C build spec.
  ///
  /// Completes with an error if the linking fails.
  ///
  /// If provided, uses [logger] to output logs. Otherwise, uses a default
  /// logger that streams [Level.WARNING] to stdout and higher levels to stderr.
  ///
  /// [linkerOptions] overrides the [CLinker.linkerOptions] of this [CLinker].
  /// See [CLinker.linkerOptions] for more documentation.
  ///
  /// [linkModePreference] overrides the [CTool.linkModePreference] of this
  /// [CLinker]. See [CTool.linkModePreference] for more documentation.
  ///
  /// [sources] overrides the [CTool.sources] of this [CLinker]. See
  /// [CTool.sources] for more documentation.
  ///
  /// [defines] are merged with the [CTool.defines] of this [CLinker]. See
  /// [CTool.defines] for more documentation.
  ///
  /// If you're using [CBuilder] in a build hook and [CLinker] in a link hook,
  /// see [CLibrary] to combine them.
  @override
  Future<void> run({
    required LinkInput input,
    required LinkOutputBuilder output,
    Logger? logger,
    LinkerOptions? linkerOptions,
    LinkModePreference? linkModePreference,
    List<String>? sources,
    Map<String, String?>? defines,
  }) async {
    logger ??= createDefaultLogger();
    final outDir = input.outputDirectory;
    final packageRoot = input.packageRoot;
    await Directory.fromUri(outDir).create(recursive: true);
    final linkMode = getLinkMode(
      linkModePreference ??
          this.linkModePreference ??
          input.config.code.linkModePreference,
    );
    final libUri = outDir.resolve(
      input.config.code.targetOS.libraryFileName(name, linkMode),
    );
    final resolvedSources = [
      for (final source in sources ?? this.sources)
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
      linkerOptions: linkerOptions ?? this.linkerOptions,
      logger: logger,
      sources: resolvedSources,
      includes: includes,
      frameworks: frameworks,
      libraries: libraries,
      libraryDirectories: libraryDirectories,
      dynamicLibrary: linkMode == DynamicLoadingBundled() ? libUri : null,
      staticLibrary: linkMode == StaticLinking() ? libUri : null,
      // ignore: invalid_use_of_visible_for_testing_member
      installName: installName,
      flags: flags,
      defines: {...this.defines, ...?defines},
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

    output.dependencies.addAll({
      // Note: We use a Set here to deduplicate the dependencies.
      ...resolvedSources,
      ...includeFiles,
    });
  }
}
