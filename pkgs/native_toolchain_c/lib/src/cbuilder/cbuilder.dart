// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import 'run_cbuilder.dart';

/// A programming language that can be selected for compilation of source files.
///
/// See [CBuilder.language] for more information.
class Language {
  /// The name of the language.
  final String name;

  const Language._(this.name);

  static const Language c = Language._('c');

  static const Language cpp = Language._('c++');

  static const Language objectiveC = Language._('objective c');

  /// Known values for [Language].
  static const List<Language> values = [
    c,
    cpp,
    objectiveC,
  ];

  @override
  String toString() => name;
}

/// Specification for building an artifact with a C compiler.
class CBuilder implements Builder {
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
    this.frameworks = _defaultFrameworks,
    @Deprecated(
      'Newer Dart and Flutter SDKs automatically add the Dart hook '
      'sources as dependencies.',
    )
    this.dartBuildFiles = const [],
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
  }) : _type = CBuilderType.library;

  CBuilder.executable({
    required this.name,
    this.sources = const [],
    this.includes = const [],
    this.frameworks = _defaultFrameworks,
    @Deprecated(
      'Newer Dart and Flutter SDKs automatically add the Dart hook '
      'sources as dependencies.',
    )
    this.dartBuildFiles = const [],
    this.flags = const [],
    this.defines = const {},
    this.buildModeDefine = true,
    this.ndebugDefine = true,
    bool? pie = false,
    this.std,
    this.language = Language.c,
    this.cppLinkStdLib,
  })  : _type = CBuilderType.executable,
        assetName = null,
        installName = null,
        pic = pie,
        linkModePreference = null;

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
    final linkMode = _linkMode(linkModePreference ?? config.linkModePreference);
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
            _type == CBuilderType.library && linkMode == DynamicLoadingBundled()
                ? libUri
                : null,
        staticLibrary:
            _type == CBuilderType.library && linkMode == StaticLinking()
                ? libUri
                : null,
        executable: _type == CBuilderType.executable ? exeUri : null,
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
            package: config.packageName,
            name: assetName!,
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

enum CBuilderType {
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
