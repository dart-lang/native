// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import 'run_cbuilder.dart';

abstract class Builder {
  Future<void> run({
    required BuildConfig buildConfig,
    required BuildOutput buildOutput,
    required Logger? logger,
  });
}

/// Specification for building an artifact with a C compiler.
class CBuilder implements Builder {
  /// What kind of artifact to build.
  final _CBuilderType _type;

  /// Name of the library or executable to build.
  ///
  /// The filename will be decided by [BuildConfig.target] and
  /// [OS.libraryFileName] or [OS.executableFileName].
  ///
  /// File will be placed in [BuildConfig.outDir].
  final String name;

  /// Asset identifier.
  ///
  /// Used to output the [BuildOutput.assets].
  ///
  /// If omitted, no asset will be added to the build output.
  final String? assetId;

  /// Sources to build the library or executable.
  ///
  /// Resolved against [BuildConfig.packageRoot].
  ///
  /// Used to output the [BuildOutput.dependencies].
  final List<String> sources;

  /// The dart files involved in building this artifact.
  ///
  /// Resolved against [BuildConfig.packageRoot].
  ///
  /// Used to output the [BuildOutput.dependencies].
  final List<String> dartBuildFiles;

  /// TODO(https://github.com/dart-lang/native/issues/54): Move to [BuildConfig]
  /// or hide in public API.
  @visibleForTesting
  final Uri? installName;

  /// Definitions of preprocessor macros.
  ///
  /// When the value is `null`, the macro is defined without a value.
  final Map<String, String?> defines;

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

  /// Whether the compiler will emit position independent code.
  ///
  /// This option is set by the `pie` parameter for the [executable]
  /// constructor.
  ///
  /// When set to `true`, libraries will be compiled with `-fPIC` and
  /// executables with `-fPIE`.
  ///
  /// When set to `null`, the default behavior of the compiler will be used.
  ///
  /// Defaults to `true` for libraries and `false` for executables.
  final bool? pic;

  CBuilder.library({
    required this.name,
    required this.assetId,
    this.sources = const [],
    this.dartBuildFiles = const ['build.dart'],
    @visibleForTesting this.installName,
    this.defines = const {},
    this.buildModeDefine = true,
    this.ndebugDefine = true,
    this.pic = true,
  }) : _type = _CBuilderType.library;

  CBuilder.executable({
    required this.name,
    this.sources = const [],
    this.dartBuildFiles = const ['build.dart'],
    this.defines = const {},
    this.buildModeDefine = true,
    this.ndebugDefine = true,
    bool? pie = false,
  })  : _type = _CBuilderType.executable,
        assetId = null,
        installName = null,
        pic = pie;

  /// Runs the C Compiler with on this C build spec.
  ///
  /// Completes with an error if the build fails.
  @override
  Future<void> run({
    required BuildConfig buildConfig,
    required BuildOutput buildOutput,
    required Logger? logger,
  }) async {
    final outDir = buildConfig.outDir;
    final packageRoot = buildConfig.packageRoot;
    await Directory.fromUri(outDir).create(recursive: true);
    final linkMode = buildConfig.linkModePreference.preferredLinkMode;
    final libUri =
        outDir.resolve(buildConfig.targetOs.libraryFileName(name, linkMode));
    final exeUri =
        outDir.resolve(buildConfig.targetOs.executableFileName(name));
    final sources = [
      for (final source in this.sources)
        packageRoot.resolveUri(Uri.file(source)),
    ];
    final dartBuildFiles = [
      for (final source in this.dartBuildFiles) packageRoot.resolve(source),
    ];
    if (!buildConfig.dryRun) {
      final task = RunCBuilder(
        buildConfig: buildConfig,
        logger: logger,
        sources: sources,
        dynamicLibrary:
            _type == _CBuilderType.library && linkMode == LinkMode.dynamic
                ? libUri
                : null,
        staticLibrary:
            _type == _CBuilderType.library && linkMode == LinkMode.static
                ? libUri
                : null,
        executable: _type == _CBuilderType.executable ? exeUri : null,
        installName: installName,
        defines: {
          ...defines,
          if (buildModeDefine) buildConfig.buildMode.name.toUpperCase(): null,
          if (ndebugDefine && buildConfig.buildMode != BuildMode.debug)
            'NDEBUG': null,
        },
        pic: pic,
      );
      await task.run();
    }

    if (assetId != null) {
      final targets = [
        if (!buildConfig.dryRun)
          buildConfig.target
        else
          for (final target in Target.values)
            if (target.os == buildConfig.targetOs) target
      ];
      for (final target in targets) {
        buildOutput.assets.add(Asset(
          id: assetId!,
          linkMode: linkMode,
          target: target,
          path: AssetAbsolutePath(libUri),
        ));
      }
    }
    if (!buildConfig.dryRun) {
      buildOutput.dependencies.dependencies.addAll([
        ...sources,
        ...dartBuildFiles,
      ]);
    }
  }
}

enum _CBuilderType {
  executable,
  library,
}
