// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart' show isTest;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

import 'native_assets_cli_internal.dart';

export 'native_assets_cli_internal.dart';
export 'src/code_assets/code_asset_bundling.dart';

@isTest
Future<void> testBuildHook({
  required String description,
  required void Function(BuildConfigBuilder) extraConfigSetup,
  required FutureOr<void> Function(List<String> arguments) mainMethod,
  required FutureOr<void> Function(BuildConfig config, BuildOutput output)
      check,
  BuildMode? buildMode,
  OS? targetOS,
  List<String>? supportedAssetTypes,
  bool? linkingEnabled,
}) async {
  test(
    description,
    () async {
      final tempDir = await _tempDirForTest();
      final outputDirectory = tempDir.resolve('output/');
      final outputDirectoryShared = tempDir.resolve('output_shared/');

      await Directory.fromUri(outputDirectory).create();
      await Directory.fromUri(outputDirectoryShared).create();

      final configBuilder = BuildConfigBuilder();
      configBuilder
        ..setupHookConfig(
          packageRoot: Directory.current.uri,
          packageName: _readPackageNameFromPubspec(),
          targetOS: targetOS ?? OS.current,
          supportedAssetTypes: supportedAssetTypes ?? [],
          buildMode: buildMode ?? BuildMode.release,
        )
        ..setupBuildConfig(
          dryRun: false,
          linkingEnabled: true,
        )
        ..setupBuildRunConfig(
          outputDirectory: outputDirectory,
          outputDirectoryShared: outputDirectoryShared,
        );
      extraConfigSetup(configBuilder);

      final config = BuildConfig(configBuilder.json);

      final configUri = tempDir.resolve(Hook.build.outputName);
      _writeJsonTo(configUri, config.json);
      await mainMethod(['--config=${configUri.toFilePath()}']);
      final output = BuildOutput(
          _readJsonFrom(config.outputDirectory.resolve(Hook.build.outputName)));

      // Test conformance of protocol invariants.
      expect(await validateBuildOutput(config, output), isEmpty);

      // Run user-defined tests.
      check(config, output);
    },
  );
}

void _writeJsonTo(Uri uri, Map<String, Object?> json) {
  final encoder = const JsonEncoder().fuse(const Utf8Encoder());
  File.fromUri(uri).writeAsBytesSync(encoder.convert(json));
}

Map<String, Object?> _readJsonFrom(Uri uri) {
  final decoder = const Utf8Decoder().fuse(const JsonDecoder());
  final bytes = File.fromUri(uri).readAsBytesSync();
  return decoder.convert(bytes) as Map<String, Object?>;
}

String _readPackageNameFromPubspec() {
  final uri = Directory.current.uri.resolve('pubspec.yaml');
  final readAsString = File.fromUri(uri).readAsStringSync();
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
