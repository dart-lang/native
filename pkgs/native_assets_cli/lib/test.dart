// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'native_assets_cli_builder.dart';
import 'native_assets_cli_internal.dart' show Hook;
import 'src/validation.dart';

export 'native_assets_cli_builder.dart';

/// Validate a build hook; this will throw an exception on validation errors.
///
/// This is intended to be used from tests, e.g.:
///
/// ```
/// test('test my build hook', () async {
///   await testCodeBuildHook(
///     ...
///   );
/// });
/// ```
Future<void> testBuildHook({
  required void Function(BuildConfigBuilder) extraConfigSetup,
  required FutureOr<void> Function(List<String> arguments) mainMethod,
  required FutureOr<void> Function(BuildConfig config, BuildOutput output)
      check,
  List<String>? buildAssetTypes,
  bool? linkingEnabled,
}) async {
  const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

  final tempDir = await Directory.systemTemp.createTemp();

  try {
    // Deal with Windows temp folder aliases.
    final tempUri =
        Directory(await tempDir.resolveSymbolicLinks()).uri.normalizePath();
    final outputDirectory = tempUri.resolve('output/');
    final outputDirectoryShared = tempUri.resolve('output_shared/');

    await Directory.fromUri(outputDirectory).create();
    await Directory.fromUri(outputDirectoryShared).create();

    final configBuilder = BuildConfigBuilder();
    configBuilder
      ..setupHook(
        packageRoot: Directory.current.uri,
        packageName: _readPackageNameFromPubspec(),
        buildAssetTypes: buildAssetTypes ?? [],
      )
      ..setupBuild(
        dryRun: false,
        linkingEnabled: true,
      )
      ..setupBuildAfterChecksum(
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared,
      );
    extraConfigSetup(configBuilder);

    final config = BuildConfig(configBuilder.json);

    final configUri = tempUri.resolve(Hook.build.outputName);
    _writeJsonTo(configUri, config.json);
    await mainMethod(['--config=${configUri.toFilePath()}']);
    final output = BuildOutput(
        _readJsonFrom(config.outputDirectory.resolve(Hook.build.outputName)));

    // Test conformance of protocol invariants.
    final validationErrors = await validateBuildOutput(config, output);
    if (validationErrors.isNotEmpty) {
      throw ValidationFailure(
          'encountered build output validation issues: $validationErrors');
    }

    // Run user-defined tests.
    await check(config, output);
  } finally {
    final keepTempDir = (Platform.environment[keepTempKey] ?? '').isNotEmpty;
    if (!keepTempDir) {
      tempDir.deleteSync(recursive: true);
    }
  }
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
