// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart' show isTest;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import '../architecture.dart';
import '../asset.dart';
import '../build_mode.dart';
import '../c_compiler_config.dart';
import '../ios_sdk.dart';
import '../link_mode_preference.dart';
import '../os.dart';
import 'build_config.dart';
import 'build_output.dart';

@isTest
Future<void> testBuildHook({
  required String description,
  // ignore: inference_failure_on_function_return_type
  required Function(List<String> arguments) mainMethod,
  required void Function(BuildConfig config, BuildOutput output) check,
  BuildMode? buildMode,
  Architecture? targetArchitecture,
  OS? targetOS,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  CCompilerConfig? cCompiler,
  LinkModePreference? linkModePreference,
  Iterable<String>? supportedAssetTypes,
  bool? linkingEnabled,
}) async {
  test(
    description,
    () async {
      final tempDir = await _tempDirForTest();

      final outputDirectory = tempDir.resolve('output/');
      await Directory.fromUri(outputDirectory).create();
      final outputDirectoryShared = tempDir.resolve('output_shared/');
      await Directory.fromUri(outputDirectory).create();

      final buildConfig = BuildConfig.build(
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared,
        packageName: await _packageName(),
        packageRoot: Directory.current.uri,
        buildMode: buildMode ?? BuildMode.release,
        targetArchitecture: targetArchitecture ?? Architecture.current,
        targetOS: targetOS ?? OS.current,
        linkModePreference: linkModePreference ?? LinkModePreference.dynamic,
        linkingEnabled: linkingEnabled ?? true,
        cCompiler: cCompiler,
        supportedAssetTypes: supportedAssetTypes,
        targetAndroidNdkApi: targetAndroidNdkApi,
        targetIOSSdk: targetIOSSdk,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
      ) as BuildConfigImpl;
      final buildConfigUri = tempDir.resolve('build_config.json');

      await _writeBuildConfig(buildConfigUri, buildConfig);

      await mainMethod(['--config=${buildConfigUri.toFilePath()}']);

      final hookOutput = await _readOutput(buildConfig);

      check(buildConfig, hookOutput);

      final allAssets = [
        ...hookOutput.assets,
        ...hookOutput.assetsForLinking.values.expand((e) => e)
      ];
      for (final asset in allAssets.where((asset) => asset.file != null)) {
        final file = File.fromUri(asset.file!);
        expect(await file.exists(), true);
      }
      if (allAssets.any((asset) => asset is CodeAsset)) {
        expect(buildConfig.supportedAssetTypes, CodeAsset.type);
      }
      if (allAssets.any((asset) => asset is DataAsset)) {
        expect(buildConfig.supportedAssetTypes, DataAsset.type);
      }
    },
  );
}

Future<void> _writeBuildConfig(
  Uri buildConfigUri,
  BuildConfigImpl buildConfig,
) async {
  final file = File.fromUri(buildConfigUri);
  await file.create();
  file.writeAsStringSync(buildConfig.toJsonString());
}

Future<HookOutputImpl> _readOutput(BuildConfigImpl buildConfig) async {
  final hookOutput = HookOutputImpl.fromJsonString(
      await File.fromUri(buildConfig.outputFile).readAsString());
  return hookOutput;
}

Future<String> _packageName() async {
  final uri = Directory.current.uri.resolve('pubspec.yaml');
  final readAsString = await File.fromUri(uri).readAsString();
  final yaml = loadYaml(readAsString) as YamlMap;
  return yaml['name'] as String;
}

const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

Future<Uri> _tempDirForTest({String? prefix, bool keepTemp = false}) async {
  final tempDir = await Directory.systemTemp.createTemp(prefix);
  // Deal with Windows temp folder aliases.
  final tempUri =
      Directory(await tempDir.resolveSymbolicLinks()).uri.normalizePath();
  if ((!Platform.environment.containsKey(keepTempKey) ||
          Platform.environment[keepTempKey]!.isEmpty) &&
      !keepTemp) {
    addTearDown(() => tempDir.delete(recursive: true));
  }
  return tempUri;
}
