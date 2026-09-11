// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'code_emitter.dart';
import 'config_values.dart';

/// Migrates a jnigen YAML configuration file to a Dart generator script.
class YamlMigrator {
  final File yamlConfig;
  final File outputDart;

  YamlMigrator({required this.yamlConfig, required this.outputDart});

  static const _testPackageRoots = {
    'example_in_app_java.yaml': 'example/in_app_java/',
    'example_kotlin_plugin.yaml': 'example/kotlin_plugin/',
    'example_notification_plugin.yaml': 'example/notification_plugin/',
    'example_pdfbox_plugin.yaml': 'example/pdfbox_plugin/',
    'test_jackson_core.yaml': 'test/jackson_core_test/',
    'test_dartify_simple_cases.yaml': 'test/simple_package_test/',
  };

  void migrate() {
    final yamlContent = yamlConfig.readAsStringSync();
    final loaded = loadYaml(yamlContent);
    final yamlMap = loaded is YamlMap ? loaded : const <dynamic, dynamic>{};

    final baseName = p.basename(yamlConfig.path);
    final defaultPackageRoot = _testPackageRoots[baseName] ?? '.';

    final config = _extractConfig(yamlMap, defaultPackageRoot);
    final code = CodeEmitter(config).emit();

    final parentDir = outputDart.parent;
    if (!parentDir.existsSync()) {
      parentDir.createSync(recursive: true);
    }
    outputDart.writeAsStringSync(code);

    Process.runSync(
      Platform.resolvedExecutable,
      ['format', outputDart.absolute.path],
      workingDirectory: outputDart.parent.absolute.path,
    );
  }

  JnigenMigrationConfig _extractConfig(
    Map<dynamic, dynamic> yamlMap,
    String defaultPackageRoot,
  ) {
    final preamble = yamlMap['preamble'] as String?;
    final dartOutput = _extractDartOutput(yamlMap['output']);
    final sourcePaths = _extractStringList(yamlMap['source_path']);
    final classPaths = _extractStringList(yamlMap['class_path']);
    final classes = _extractStringList(yamlMap['classes']);
    final summarizerBackend = _extractSummarizerBackend(yamlMap['summarizer']);
    final mavenDownloads = _extractMavenDownloads(yamlMap['maven_downloads']);
    final androidSdk = _extractAndroidSdk(yamlMap['android_sdk_config']);
    final hide = _extractStringList(yamlMap['hide']);
    final symbolFiles = _extractStringList(yamlMap['import']);

    return JnigenMigrationConfig(
      defaultPackageRoot: defaultPackageRoot,
      preamble: preamble,
      dartOutput: dartOutput,
      sourcePaths: sourcePaths,
      classPaths: classPaths,
      classes: classes,
      summarizerBackend: summarizerBackend,
      mavenDownloads: mavenDownloads,
      androidSdk: androidSdk,
      hide: hide,
      symbolFiles: symbolFiles,
    );
  }

  DartOutputConfig _extractDartOutput(dynamic outputYaml) {
    if (outputYaml is Map) {
      final dart = outputYaml['dart'];
      if (dart is Map) {
        final path = dart['path'] as String? ?? 'lib/bindings.dart';
        final structStr = dart['structure'] as String?;
        if (structStr == 'single_file') {
          return DartOutputConfig(
            path: path,
            structure: OutputStructureConfig.singleFile,
            explicitlySpecifiedStructure: true,
          );
        } else if (structStr == 'package_structure') {
          return DartOutputConfig(
            path: path,
            structure: OutputStructureConfig.packageStructure,
            explicitlySpecifiedStructure: true,
          );
        }
        return DartOutputConfig(path: path);
      } else if (dart is String) {
        return DartOutputConfig(path: dart);
      }
    }
    return const DartOutputConfig(path: 'lib/bindings.dart');
  }

  List<String> _extractStringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    } else if (value is String) {
      return [value];
    }
    return const [];
  }

  SummarizerBackendConfig? _extractSummarizerBackend(dynamic summarizerYaml) {
    if (summarizerYaml is Map) {
      final backend = summarizerYaml['backend'] as String?;
      if (backend == 'asm') {
        return SummarizerBackendConfig.asm;
      } else if (backend == 'doclet') {
        return SummarizerBackendConfig.doclet;
      }
    }
    return null;
  }

  MavenDownloadsConfig? _extractMavenDownloads(dynamic mavenDlYaml) {
    if (mavenDlYaml is! Map) return null;

    final sourceDeps = _extractStringList(mavenDlYaml['source_deps']);
    final jarOnlyDeps = _extractStringList(mavenDlYaml['jar_only_deps']);
    final sourceDir = mavenDlYaml['source_dir'] as String?;
    final jarDir = mavenDlYaml['jar_dir'] as String?;

    return MavenDownloadsConfig(
      sourceDeps: sourceDeps,
      jarOnlyDeps: jarOnlyDeps,
      sourceDir: sourceDir,
      jarDir: jarDir,
    );
  }

  AndroidSdkConfig? _extractAndroidSdk(dynamic androidSdkYaml) {
    if (androidSdkYaml is! Map) return null;

    final addGradleDeps = androidSdkYaml['add_gradle_deps'] == true;
    final addGradleSources = androidSdkYaml['add_gradle_sources'] == true;
    final androidExample = androidSdkYaml['android_example'] as String?;
    final versionsList = androidSdkYaml['versions'];
    List<int>? versions;
    if (versionsList is List) {
      versions = versionsList.map((e) => int.parse(e.toString())).toList();
    }
    final sdkRoot = androidSdkYaml['sdk_root'] as String?;

    return AndroidSdkConfig(
      addGradleDeps: addGradleDeps,
      addGradleSources: addGradleSources,
      androidExample: androidExample,
      versions: versions,
      sdkRoot: sdkRoot,
    );
  }
}
