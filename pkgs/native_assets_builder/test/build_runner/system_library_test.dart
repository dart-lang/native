// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('system library', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('system_library/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      final logMessages = <String>[];
      final result = (await build(
        packageUri,
        logger,
        dartExecutable,
        capturedLogs: logMessages,
        inputValidator: validateCodeAssetBuildInput,
        buildAssetTypes: [CodeAsset.type],
        buildValidator: validateCodeAssetBuildOutput,
        applicationAssetValidator: validateCodeAssetInApplication,
      ))!;
      expect(result.encodedAssets.length, 3);
    });
  });
}
