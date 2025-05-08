// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import 'config.dart';
import 'encoded_asset.dart';
import 'extension.dart';
import 'user_defines.dart';
import 'validation.dart';

/// Tests the main function of a `hook/build.dart`.
///
/// This method will throw an exception on validation errors.
///
/// This is intended to be used from tests, e.g.:
///
/// ```
/// test('test my build hook', () async {
///   await testBuildHook(
///     ...
///   );
/// });
/// ```
///
/// The hook is run in isolation. No user-defines are read from the pubspec,
/// they must be provided via [userDefines]. No other hooks are run, if the hook
/// requires assets from other build hooks, the must be provided in [assets].
Future<void> testBuildHook({
  required FutureOr<void> Function(List<String> arguments) mainMethod,
  required FutureOr<void> Function(BuildInput input, BuildOutput output) check,
  bool? linkingEnabled,
  required List<ProtocolExtension> extensions,
  // TODO(https://github.com/dart-lang/native/issues/2241): Cleanup how the
  // following parameters are passed in.
  PackageUserDefines? userDefines,
  Map<String, List<EncodedAsset>>? assets,
}) async {
  linkingEnabled ??= false;
  const keepTempKey = 'KEEP_TEMPORARY_DIRECTORIES';

  final tempDir = await Directory.systemTemp.createTemp();

  try {
    // Deal with Windows temp folder aliases.
    final tempUri = Directory(
      await tempDir.resolveSymbolicLinks(),
    ).uri.normalizePath();
    final outputDirectoryShared = tempUri.resolve('output_shared/');
    final outputFile = tempUri.resolve('output.json');

    await Directory.fromUri(outputDirectoryShared).create();

    final inputBuilder = BuildInputBuilder();
    inputBuilder
      ..setupShared(
        packageRoot: Directory.current.uri,
        packageName: _readPackageNameFromPubspec(),
        outputFile: outputFile,
        outputDirectoryShared: outputDirectoryShared,
        userDefines: userDefines,
      )
      ..setupBuildInput(assets: assets)
      ..config.setupBuild(linkingEnabled: linkingEnabled);
    for (final extension in extensions) {
      extension.setupBuildInput(inputBuilder);
    }
    final input = inputBuilder.build();

    final inputErrors = [
      for (final extension in extensions)
        ...await extension.validateBuildInput(input),
    ];
    if (inputErrors.isNotEmpty) {
      throw ValidationFailure(
        'Encountered build input validation issues: $inputErrors',
      );
    }

    final inputUri = tempUri.resolve('input.json');
    _writeJsonTo(inputUri, input.json);
    await mainMethod(['--config=${inputUri.toFilePath()}']);
    final output = BuildOutput(_readJsonFrom(input.outputFile));

    final outputErrors = [
      ...await ProtocolBase.validateBuildOutput(input, output),
      for (final extension in extensions) ...[
        ...await extension.validateBuildOutput(input, output),
        ...await extension.validateApplicationAssets(
          output.assets.encodedAssets,
        ),
      ],
    ];
    if (outputErrors.isNotEmpty) {
      throw ValidationFailure(
        'Encountered build output validation issues: $inputErrors',
      );
    }

    await check(input, output);
  } finally {
    final keepTempDir = (Platform.environment[keepTempKey] ?? '').isNotEmpty;
    if (!keepTempDir) {
      tempDir.deleteSync(recursive: true);
    } else {
      print('$keepTempKey ${tempDir.uri}');
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
