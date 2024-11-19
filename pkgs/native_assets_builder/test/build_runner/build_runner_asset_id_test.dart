// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('wrong asset id', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('wrong_namespace_asset/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      {
        final logMessages = <String>[];
        final result = await build(
          packageUri,
          createCapturingLogger(logMessages, level: Level.SEVERE),
          dartExecutable,
          supportedAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        );
        final fullLog = logMessages.join('\n');
        expect(result, isNull);
        expect(
          fullLog,
          contains('does not start with "package:wrong_namespace_asset/"'),
        );
      }
    });
  });

  test('right asset id but other directory', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      final packageUri = tempUri.resolve('different_root_dir/');
      await copyTestProjects(
        targetUri: tempUri,
      );
      await copyTestProjects(
        sourceUri: testDataUri.resolve('native_add/'),
        targetUri: packageUri,
      );

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      {
        final result = await build(
          packageUri,
          logger,
          dartExecutable,
          supportedAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        );
        expect(result, isNotNull);
      }
    });
  });
}
