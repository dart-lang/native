// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

import 'run_cbuilder.dart';

abstract class Builder {
  Future<void> run({
    required BuildConfig buildConfig,
    required BuildOutput buildOutput,
    Logger? logger,
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
  final String? assetName;

  /// Sources to build the library or executable.
  ///
  /// Resolved against [BuildConfig.packageRoot].
  ///
  /// Used to output the [BuildOutput.dependencies].
  final List<String> sources;

  /// Sources to build the library or executable.
  ///
  /// Resolved against [BuildConfig.packageRoot].
  ///
  /// Used to output the [BuildOutput.dependencies].
  final List<String> includePaths;

  /// The dart files involved in building this artifact.
  ///
  /// Resolved against [BuildConfig.packageRoot].
  ///
  /// Used to output the [BuildOutput.dependencies].
  final List<String> dartBuildFiles;

  CBuilder.library({
    required this.name,
    required this.assetName,
    this.sources = const [],
    this.includePaths = const [],
    this.dartBuildFiles = const ['build.dart'],
  }) : _type = _CBuilderType.library;

  CBuilder.executable({
    required this.name,
    this.sources = const [],
    this.includePaths = const [],
    this.dartBuildFiles = const ['build.dart'],
  })  : _type = _CBuilderType.executable,
        assetName = null;

  @override
  Future<void> run({
    required BuildConfig buildConfig,
    required BuildOutput buildOutput,
    Logger? logger,
  }) async {
    logger ??= Logger('');
    final outDir = buildConfig.outDir;
    final packageRoot = buildConfig.packageRoot;
    await Directory.fromUri(outDir).create(recursive: true);
    final packaging = buildConfig.packaging.preferredPackaging.first;
    final libUri =
        outDir.resolve(buildConfig.target.os.libraryFileName(name, packaging));
    final exeUri =
        outDir.resolve(buildConfig.target.os.executableFileName(name));
    final sources = [
      for (final source in this.sources) packageRoot.resolve(source),
    ];
    final dartBuildFiles = [
      for (final source in this.dartBuildFiles) packageRoot.resolve(source),
    ];

    final task = RunCBuilder(
      buildConfig: buildConfig,
      logger: logger,
      sources: sources,
      dynamicLibrary:
          _type == _CBuilderType.library && packaging == Packaging.dynamic
              ? libUri
              : null,
      staticLibrary:
          _type == _CBuilderType.library && packaging == Packaging.static
              ? libUri
              : null,
      executable: _type == _CBuilderType.executable ? exeUri : null,
    );
    await task.run();

    if (assetName != null) {
      buildOutput.assets.add(Asset(
        name: assetName!,
        packaging: packaging,
        target: buildConfig.target,
        path: AssetAbsolutePath(libUri),
      ));
    }
    buildOutput.dependencies.dependencies.addAll([
      ...sources,
      ...dartBuildFiles,
    ]);
  }
}

enum _CBuilderType {
  executable,
  library,
}
