// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import 'ctool.dart';
import 'language.dart';
import 'linker_options.dart';
import 'linkmode.dart';
import 'output_type.dart';
import 'run_cbuilder.dart';

export 'linker_options.dart';

/// Specification for linking an artifact with a C linker.
//TODO(mosuem): This is currently only implemented for linux.
// See also https://github.com/dart-lang/native/issues/1376
class CLinker extends CTool implements Linker {
  final LinkerOptions linkerOptions;

  CLinker.library({
    required super.name,
    super.assetName,
    required this.linkerOptions,
    super.sources = const [],
    super.includes = const [],
    super.frameworks = CTool.defaultFrameworks,
    @visibleForTesting super.installName,
    super.flags = const [],
    super.defines = const {},
    super.pic = true,
    super.std,
    super.language = Language.c,
    super.cppLinkStdLib,
    super.linkModePreference,
  }) : super(type: OutputType.library);

  /// Runs the C Linker with on this C build spec.
  ///
  /// Completes with an error if the linking fails.
  @override
  Future<void> run({
    required LinkConfig config,
    required LinkOutput output,
    required Logger? logger,
  }) async {
    if (OS.current != OS.linux || config.targetOS != OS.linux) {
      throw UnsupportedError('Currently, only linux is supported for this '
          'feature. See also https://github.com/dart-lang/native/issues/1376');
    }
    final outDir = config.outputDirectory;
    final packageRoot = config.packageRoot;
    await Directory.fromUri(outDir).create(recursive: true);
    final linkMode =
        getLinkMode(linkModePreference ?? config.linkModePreference);
    final libUri =
        outDir.resolve(config.targetOS.libraryFileName(name, linkMode));
    final sources = [
      for (final source in this.sources)
        packageRoot.resolveUri(Uri.file(source)),
    ];
    final includes = [
      for (final directory in this.includes)
        packageRoot.resolveUri(Uri.file(directory)),
    ];
    if (!config.dryRun) {
      final task = RunCBuilder(
        config: config,
        linkerOptions: linkerOptions,
        logger: logger,
        sources: sources,
        includes: includes,
        frameworks: frameworks,
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
      );
      await task.run();
    }

    if (assetName != null) {
      output.addAssets(
        [
          NativeCodeAsset(
            id: AssetId(config.packageName, assetName!),
            file: libUri,
            linkMode: linkMode,
            os: config.targetOS,
            architecture: config.dryRun ? null : config.targetArchitecture,
          )
        ],
      );
    }
    if (!config.dryRun) {
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
}
