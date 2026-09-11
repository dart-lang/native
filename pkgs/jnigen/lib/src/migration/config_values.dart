// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Configuration values extracted from a jnigen YAML configuration file.
library;

enum OutputStructureConfig {
  singleFile,
  packageStructure,
}

enum SummarizerBackendConfig {
  asm,
  doclet,
}

class DartOutputConfig {
  final String path;
  final OutputStructureConfig structure;
  final bool explicitlySpecifiedStructure;

  const DartOutputConfig({
    required this.path,
    this.structure = OutputStructureConfig.packageStructure,
    this.explicitlySpecifiedStructure = false,
  });
}

class MavenDownloadsConfig {
  final List<String> sourceDeps;
  final List<String> jarOnlyDeps;
  final String? sourceDir;
  final String? jarDir;

  const MavenDownloadsConfig({
    this.sourceDeps = const [],
    this.jarOnlyDeps = const [],
    this.sourceDir,
    this.jarDir,
  });
}

class AndroidSdkConfig {
  final bool addGradleDeps;
  final bool addGradleSources;
  final String? androidExample;
  final List<int>? versions;
  final String? sdkRoot;

  const AndroidSdkConfig({
    this.addGradleDeps = false,
    this.addGradleSources = false,
    this.androidExample,
    this.versions,
    this.sdkRoot,
  });
}

class JnigenMigrationConfig {
  final String defaultPackageRoot;
  final String? preamble;
  final DartOutputConfig dartOutput;
  final List<String> sourcePaths;
  final List<String> classPaths;
  final List<String> classes;
  final SummarizerBackendConfig? summarizerBackend;
  final MavenDownloadsConfig? mavenDownloads;
  final AndroidSdkConfig? androidSdk;
  final List<String> hide;
  final List<String> symbolFiles;

  const JnigenMigrationConfig({
    required this.defaultPackageRoot,
    this.preamble,
    required this.dartOutput,
    this.sourcePaths = const [],
    this.classPaths = const [],
    required this.classes,
    this.summarizerBackend,
    this.mavenDownloads,
    this.androidSdk,
    this.hide = const [],
    this.symbolFiles = const [],
  });
}
