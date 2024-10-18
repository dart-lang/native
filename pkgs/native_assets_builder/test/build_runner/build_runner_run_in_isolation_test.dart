// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  final env = Platform.environment;
  final cc = env['DART_HOOK_TESTING_C_COMPILER__CC'];
  final ar = env['DART_HOOK_TESTING_C_COMPILER__AR'];
  final ld = env['DART_HOOK_TESTING_C_COMPILER__LD'];
  final envScript = env['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT'];
  final envScriptArgs =
      env['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT_ARGUMENTS']
          ?.split(' ')
          .map((arg) => arg.trim())
          .where((arg) => arg.isNotEmpty)
          .toList();

  if (cc == null) {
    // We don't set any compiler paths on the GitHub CI.
    // We neither set compiler paths on MacOS on the Dart SDK CI
    // in pkg/test_runner/lib/src/configuration.dart
    // nativeCompilerEnvironmentVariables.
    //
    // We could potentially run this test if we default to some compilers
    // we find on the path before running the test. However, the logic for
    // discovering compilers is currently hidden inside
    // package:native_toolchain_c.
    return;
  }

  test('run in isolation', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      printOnFailure('cc: $cc');

      final result = (await build(
        packageUri,
        logger,
        dartExecutable,
        // Manually pass in a compiler.
        cCompilerConfig: CCompilerConfig(
          archiver: ar?.fileUri,
          compiler: cc.fileUri,
          envScript: envScript?.fileUri,
          envScriptArgs: envScriptArgs,
          linker: ld?.fileUri,
        ),
        // Prevent any other environment variables.
        includeParentEnvironment: false,
        supportedAssetTypes: [CodeAsset.type],
        configValidator: validateCodeAssetBuildConfig,
        buildValidator: validateCodeAssetBuildOutput,
        applicationAssetValidator: validateCodeAssetInApplication,
      ))!;
      expect(result.encodedAssets.length, 1);
    });
  });
}

extension on String {
  Uri get fileUri => Uri.file(this);
}
