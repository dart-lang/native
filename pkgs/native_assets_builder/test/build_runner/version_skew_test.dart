// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test(
    'Test hook using an older version of native_assets_cli',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('native_add_version_skew/');

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(workingDirectory: packageUri, logger: logger);

        {
          final result = await build(
            packageUri,
            logger,
            dartExecutable,
            buildAssetTypes: [CodeAsset.type],
          );
          expect(result?.encodedAssets.length, 1);
        }
      });
    },
  );

  test(
    'Test hook using a too old version of native_assets_cli',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('native_add_version_skew_2/');

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(workingDirectory: packageUri, logger: logger);

        final logMessages = <String>[];
        final result = await buildCodeAssets(
          packageUri,
          capturedLogs: logMessages,
        );
        expect(result, isNull);
        expect(
          logMessages.join('\n'),
          stringContainsInOrder([
            'The protocol version of ',
            'native_assets_cli',
            ' is 1.3.0, which is no longer supported.',
            'Please update your dependencies.',
          ]),
        );
      });
    },
  );
}
