// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  String unparseKey(String key) => key.replaceAll('.', '__').toUpperCase();
  final arKey = unparseKey(CCompilerConfigImpl.arConfigKeyFull);
  final ccKey = unparseKey(CCompilerConfigImpl.ccConfigKeyFull);
  final ldKey = unparseKey(CCompilerConfigImpl.ldConfigKeyFull);
  final envScriptKey = unparseKey(CCompilerConfigImpl.envScriptConfigKeyFull);
  final envScriptArgsKey =
      unparseKey(CCompilerConfigImpl.envScriptArgsConfigKeyFull);

  final cc = Platform.environment[ccKey]?.fileUri;

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

      printOnFailure(
          'Platform.environment[ccKey]: ${Platform.environment[ccKey]}');
      printOnFailure('cc: $cc');

      final result = await build(
        packageUri,
        logger,
        dartExecutable,
        // Manually pass in a compiler.
        cCompilerConfig: CCompilerConfigImpl(
          archiver: Platform.environment[arKey]?.fileUri,
          compiler: cc,
          envScript: Platform.environment[envScriptKey]?.fileUri,
          envScriptArgs: Platform.environment[envScriptArgsKey]?.split(' '),
          linker: Platform.environment[ldKey]?.fileUri,
        ),
        // Prevent any other environment variables.
        includeParentEnvironment: false,
      );
      expect(result.assets.length, 1);
    });
  });
}

extension on String {
  Uri get fileUri => Uri.file(this);
}
