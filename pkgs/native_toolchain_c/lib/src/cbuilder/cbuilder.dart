// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import 'language.dart';
import 'linker_options.dart';
import 'run_cbuilder.dart';

part 'clinker.dart';

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
  /// The filename will be decided by [BuildConfig.targetOS] and
  /// [OS.libraryFileName] or [OS.executableFileName].
  ///
  /// File will be placed in [BuildConfig.outputDirectory].
  final String name;

  /// Asset identifier.
  ///
  /// Used to output the [BuildOutput.assets].
  ///
  /// If omitted, no asset will be added to the build output.
  final String? assetName;

  /// Sources to build the library or executable.
  ///
  /// Resolved against [BuildConfig.packageRoot].
  ///
  /// Used to output the [BuildOutput.dependencies].
  final List<String> sources;

  /// Include directories to pass to the compiler.
  ///
  /// Resolved against [BuildConfig.packageRoot].
  ///
  /// Used to output the [BuildOutput.dependencies].
  final List<String> includes;

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

  /// Flags to pass to the compiler.
  final List<String> flags;

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
  /// When set to `true`, libraries will be compiled with `-fPIC` and
  /// executables with `-fPIE`. Accordingly the corresponding parameter of the
  /// [CBuilder.executable] constructor is named `pie`.
  ///
  /// When set to `null`, the default behavior of the compiler will be used.
  ///
  /// This option has no effect when building for Windows, where generation of
  /// position independent code is not configurable.
  ///
  /// Defaults to `true` for libraries and `false` for executables.
  final bool? pic;

  /// The language standard to use.
  ///
  /// When set to `null`, the default behavior of the compiler will be used.
  final String? std;

  /// The language to compile [sources] as.
  ///
  /// [cppLinkStdLib] only has an effect when this option is set to
  /// [Language.cpp].
  final Language language;

  /// The C++ standard library to link against.
  ///
  /// This option has no effect when [language] is not set to [Language.cpp] or
  /// when compiling for Windows.
  ///
  /// When set to `null`, the following defaults will be used, based on the
  /// target OS:
  ///
  /// | OS      | Library      |
  /// | :------ | :----------- |
  /// | Android | `c++_shared` |
  /// | iOS     | `c++`        |
  /// | Linux   | `stdc++`     |
  /// | macOS   | `c++`        |
  /// | Fuchsia | `c++`        |
  final String? cppLinkStdLib;

  final LinkerOptions? linkerOptions;

  /// If the code asset should be a dynamic or static library.
  ///
  /// This determines whether to produce a dynamic or static library. If null,
  /// the value is instead retrieved from the [BuildConfig].
  final LinkModePreference? linkModePreference;

  CBuilder.library({
    required this.name,
    required this.assetName,
    this.sources = const [],
    this.includes = const [],
    required this.dartBuildFiles,
    @visibleForTesting this.installName,
    this.flags = const [],
    this.defines = const {},
    this.buildModeDefine = true,
    this.ndebugDefine = true,
    this.pic = true,
    this.std,
    this.language = Language.c,
    this.cppLinkStdLib,
    this.linkModePreference,
  })  : _type = _CBuilderType.library,
        linkerOptions = null;

  CBuilder._({
    required this.name,
    this.assetName,
    this.sources = const [],
    this.includes = const [],
    required this.dartBuildFiles,
    @visibleForTesting this.installName,
    this.flags = const [],
    this.defines = const {},
    this.buildModeDefine = true,
    this.ndebugDefine = true,
    this.pic = true,
    this.std,
    this.language = Language.c,
    this.cppLinkStdLib,
    this.linkModePreference,
    required _CBuilderType type,
    this.linkerOptions,
  }) : _type = type;

  CBuilder.executable({
    required this.name,
    this.sources = const [],
    this.includes = const [],
    required this.dartBuildFiles,
    this.flags = const [],
    this.defines = const {},
    this.buildModeDefine = true,
    this.ndebugDefine = true,
    bool? pie = false,
    this.std,
    this.language = Language.c,
    this.cppLinkStdLib,
  })  : _type = _CBuilderType.executable,
        assetName = null,
        installName = null,
        pic = pie,
        linkerOptions = null,
        linkModePreference = null;

  /// Runs the C Compiler with on this C build spec.
  ///
  /// Completes with an error if the build fails.
  @override
  Future<void> run({
    required BuildConfig buildConfig,
    required BuildOutput buildOutput,
    required Logger? logger,
    String? linkInPackage,
  }) async {
    final linkMode =
        _linkMode(linkModePreference ?? buildConfig.linkModePreference);
    final libUri = buildConfig.outputDirectory
        .resolve(buildConfig.targetOS.libraryFileName(name, linkMode));
    await _run(
      buildConfig,
      logger,
      buildOutput,
      linkMode,
      libUri,
    );
    if (assetName != null) {
      buildOutput.addAsset(
        NativeCodeAsset(
          package: buildConfig.packageName,
          name: assetName!,
          file: libUri,
          linkMode: linkMode,
          os: buildConfig.targetOS,
          architecture:
              buildConfig.dryRun ? null : buildConfig.targetArchitecture,
        ),
        linkInPackage: linkInPackage,
      );
    }
  }

  Future<void> _run(
    HookConfig buildConfig,
    Logger? logger,
    BuildOutput buildOutput,
    LinkMode linkMode,
    Uri libUri,
  ) async {
    final outDir = buildConfig.outputDirectory;
    final packageRoot = buildConfig.packageRoot;

    await Directory.fromUri(outDir).create(recursive: true);
    final exeUri =
        outDir.resolve(buildConfig.targetOS.executableFileName(name));
    final sources = [
      for (final source in this.sources)
        packageRoot.resolveUri(Uri.file(source)),
    ];
    final includes = [
      for (final directory in this.includes)
        packageRoot.resolveUri(Uri.file(directory)),
    ];
    final dartBuildFiles = [
      for (final source in this.dartBuildFiles) packageRoot.resolve(source),
    ];
    if (!buildConfig.dryRun) {
      final task = RunCBuilder(
        buildConfig: buildConfig,
        logger: logger,
        sources: sources,
        includes: includes,
        dynamicLibrary: _type == _CBuilderType.library &&
                linkMode == DynamicLoadingBundled()
            ? libUri
            : null,
        staticLibrary:
            _type == _CBuilderType.library && linkMode == StaticLinking()
                ? libUri
                : null,
        executable: _type == _CBuilderType.executable ? exeUri : null,
        installName: installName,
        flags: flags,
        defines: {
          ...defines,
          if (buildModeDefine) buildConfig.buildMode.name.toUpperCase(): null,
          if (ndebugDefine && buildConfig.buildMode != BuildMode.debug)
            'NDEBUG': null,
        },
        pic: pic,
        std: std,
        language: language,
        cppLinkStdLib: cppLinkStdLib,
        linkerOptions: linkerOptions,
      );
      await task.run();
    }

    if (!buildConfig.dryRun) {
      final includeFiles = await Stream.fromIterable(includes)
          .asyncExpand(
            (include) => Directory(include.toFilePath())
                .list(recursive: true)
                .where((entry) => entry is File)
                .map((file) => file.uri),
          )
          .toList();

      buildOutput.addDependencies({
        // Note: We use a Set here to deduplicate the dependencies.
        ...sources,
        ...includeFiles,
        ...dartBuildFiles,
      });
    }
  }
}

enum _CBuilderType {
  executable,
  library,
}

LinkMode _linkMode(LinkModePreference preference) {
  if (preference == LinkModePreference.dynamic ||
      preference == LinkModePreference.preferDynamic) {
    return DynamicLoadingBundled();
  }
  assert(preference == LinkModePreference.static ||
      preference == LinkModePreference.preferStatic);
  return StaticLinking();
}
