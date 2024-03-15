// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('run ffigen first', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      {
        final logMessages = <String>[];
        final result = await build(
          packageUri,
          logger,
          dartExecutable,
          capturedLogs: logMessages,
          runPackageName: 'some_dev_dep',
        );
        expect(result.assets, isEmpty);
        expect(result.dependencies, isEmpty);
      }

      {
        final logMessages = <String>[];
        final result = await build(
          packageUri,
          logger,
          dartExecutable,
          capturedLogs: logMessages,
          runPackageName: 'native_add',
        );
        expect(result.assets, isNotEmpty);
        expect(
          result.dependencies,
          [
            packageUri.resolve('hook/build.dart'),
            packageUri.resolve('src/native_add.c'),
          ],
        );
        expect(
          logMessages.join('\n'),
          contains(
            'native_add${Platform.pathSeparator}hook'
            '${Platform.pathSeparator}build.dart',
          ),
        );
      }
    });
  });
}
