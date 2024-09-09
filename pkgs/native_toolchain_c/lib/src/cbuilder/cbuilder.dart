// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import 'ctool.dart';
import 'language.dart';
import 'linkmode.dart';
import 'output_type.dart';
import 'run_cbuilder.dart';

/// Specification for building an artifact with a C compiler.
class CBuilder extends CTool implements Builder {
  /// The dart files involved in building this artifact.
  ///
  /// Resolved against [BuildConfig.packageRoot].
  ///
  /// Used to output the [BuildOutput.dependencies].
  @Deprecated(
    'Newer Dart and Flutter SDKs automatically add the Dart hook '
    'sources as dependencies.',
  )
  final List<String> dartBuildFiles;

  /// Whether to define a macro for the current [BuildMode].
  ///
  /// The macro name is the uppercase name of the build mode and does not have a
  /// value.
  ///
  /// Defaults to `true`.
  final bool buildModeDefine;

  /// Whether to define the standard `NDEBUG` macro when _not_ building with
  /// [BuildMode.debug].
  ///
  /// When `NDEBUG` is defined, the C/C++ standard library
  /// [`assert` macro in `assert.h`](https://en.wikipedia.org/wiki/Assert.h)
  /// becomes a no-op. Other C/C++ code commonly use `NDEBUG` to disable debug
  /// features, as well.
  ///
  /// Defaults to `true`.
  final bool ndebugDefine;

  CBuilder.library({
    required super.name,
    super.assetName,
    super.sources = const [],
    super.includes = const [],
    super.frameworks = CTool.defaultFrameworks,
    @Deprecated(
      'Newer Dart and Flutter SDKs automatically add the Dart hook '
      'sources as dependencies.',
    )
    this.dartBuildFiles = const [],
    @visibleForTesting super.installName,
    super.flags = const [],
    super.defines = const {},
    this.buildModeDefine = true,
    this.ndebugDefine = true,
    super.pic = true,
    super.std,
    super.language = Language.c,
    super.cppLinkStdLib,
    super.linkModePreference,
  }) : super(type: OutputType.library);

  CBuilder.executable({
    required super.name,
    super.sources = const [],
    super.includes = const [],
    super.frameworks = CTool.defaultFrameworks,
    @Deprecated(
      'Newer Dart and Flutter SDKs automatically add the Dart hook '
      'sources as dependencies.',
    )
    this.dartBuildFiles = const [],
    super.flags = const [],
    super.defines = const {},
    this.buildModeDefine = true,
    this.ndebugDefine = true,
    bool? pie = false,
    super.std,
    super.language = Language.c,
    super.cppLinkStdLib,
  }) : super(
          type: OutputType.executable,
          assetName: null,
          installName: null,
          pic: pie,
          linkModePreference: null,
        );

  /// Runs the C Compiler with on this C build spec.
  ///
  /// Completes with an error if the build fails.
  @override
  Future<void> run({
    required BuildConfig config,
    required BuildOutput output,
    required Logger? logger,
    String? linkInPackage,
  }) async {
    assert(
      config.linkingEnabled || linkInPackage == null,
      'linkInPackage can only be provided if config.linkingEnabled is true.',
    );
    final outDir = config.outputDirectory;
    final packageRoot = config.packageRoot;
    await Directory.fromUri(outDir).create(recursive: true);
    final linkMode =
        getLinkMode(linkModePreference ?? config.linkModePreference);
    final libUri =
        outDir.resolve(config.targetOS.libraryFileName(name, linkMode));
    final exeUri = outDir.resolve(config.targetOS.executableFileName(name));
    final sources = [
      for (final source in this.sources)
        packageRoot.resolveUri(Uri.file(source)),
    ];
    final includes = [
      for (final directory in this.includes)
        packageRoot.resolveUri(Uri.file(directory)),
    ];
    final dartBuildFiles = [
      // ignore: deprecated_member_use_from_same_package
      for (final source in this.dartBuildFiles) packageRoot.resolve(source),
    ];
    if (!config.dryRun) {
      final task = RunCBuilder(
        config: config,
        logger: logger,
        sources: sources,
        includes: includes,
        frameworks: frameworks,
        dynamicLibrary:
            type == OutputType.library && linkMode == DynamicLoadingBundled()
                ? libUri
                : null,
        staticLibrary: type == OutputType.library && linkMode == StaticLinking()
            ? libUri
            : null,
        executable: type == OutputType.executable ? exeUri : null,
        // ignore: invalid_use_of_visible_for_testing_member
        installName: installName,
        flags: flags,
        defines: {
          ...defines,
          if (buildModeDefine) config.buildMode.name.toUpperCase(): null,
          if (ndebugDefine && config.buildMode != BuildMode.debug)
            'NDEBUG': null,
        },
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
            id: 'package:${config.packageName}/$assetName',
            file: libUri,
            linkMode: linkMode,
            os: config.targetOS,
            architecture: config.dryRun ? null : config.targetArchitecture,
          )
        ],
        linkInPackage: linkInPackage,
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
        ...dartBuildFiles,
      });
    }
  }
}
