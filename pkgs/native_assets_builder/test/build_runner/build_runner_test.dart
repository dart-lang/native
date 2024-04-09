// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_builder/native_assets_builder.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('native_add build', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      // Trigger a build, should invoke build for libraries with native assets.
      {
        final logMessages = <String>[];
        final result = await build(packageUri, logger, dartExecutable,
            capturedLogs: logMessages);
        expect(
            logMessages.join('\n'),
            stringContainsInOrder([
              'native_add${Platform.pathSeparator}hook'
                  '${Platform.pathSeparator}build.dart',
            ]));
        expect(result.assets.length, 1);
      }

      // Trigger a build, should not invoke anything.
      for (final passPackageLayout in [true, false]) {
        PackageLayout? packageLayout;
        if (passPackageLayout) {
          packageLayout = await PackageLayout.fromRootPackageRoot(packageUri);
        }
        final logMessages = <String>[];
        final result = await build(
          packageUri,
          logger,
          dartExecutable,
          capturedLogs: logMessages,
          packageLayout: packageLayout,
        );
        expect(
          false,
          logMessages.join('\n').contains(
                'native_add${Platform.pathSeparator}hook'
                '${Platform.pathSeparator}build.dart',
              ),
        );
        expect(result.assets.length, 1);
      }
    });
  });
}
