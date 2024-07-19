// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import 'cbuilder.dart';
import 'linker_options.dart';
import 'run_cbuilder.dart';

export 'linker_options.dart';

/// Specification for building an artifact with a C compiler.
class CLinker implements Linker {
  /// What kind of artifact to build.
  final CBuilderType _type;

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

  /// Frameworks to link.
  ///
  /// Only effective if [language] is [Language.objectiveC].
  ///
  /// Defaults to `['Foundation']`.
  ///
  /// Not used to output the [BuildOutput.dependencies], frameworks can be
  /// mentioned by name if they are available on the system, so the file path
  /// is not known. If you're depending on your own frameworks add them to
  /// [BuildOutput.dependencies] manually.
  final List<String> frameworks;

  static const List<String> _defaultFrameworks = ['Foundation'];

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

  /// If the code asset should be a dynamic or static library.
  ///
  /// This determines whether to produce a dynamic or static library. If null,
  /// the value is instead retrieved from the [BuildConfig].
  final LinkModePreference? linkModePreference;

  final LinkerOptions linkerOptions;

  CLinker.library({
    required this.name,
    required this.assetName,
    this.sources = const [],
    this.includes = const [],
    this.frameworks = _defaultFrameworks,
    @visibleForTesting this.installName,
    this.flags = const [],
    this.defines = const {},
    this.pic = true,
    this.std,
    this.language = Language.c,
    this.cppLinkStdLib,
    this.linkModePreference,
    required this.linkerOptions,
  }) : _type = CBuilderType.library;

  /// Runs the C Compiler with on this C build spec.
  ///
  /// Completes with an error if the build fails.
  @override
  Future<void> run({
    required LinkConfig config,
    required LinkOutput output,
    required Logger? logger,
  }) async {
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
        dynamicLibrary:
            _type == CBuilderType.library && linkMode == DynamicLoadingBundled()
                ? libUri
                : null,
        staticLibrary:
            _type == CBuilderType.library && linkMode == StaticLinking()
                ? libUri
                : null,
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
            package: config.packageName,
            name: assetName!,
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
