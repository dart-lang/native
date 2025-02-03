// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

void main() async {
  test('relative path', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('relative_path/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      {
        final logMessages = <String>[];
        final result = await buildDataAssets(
          packageUri,
          capturedLogs: logMessages,
        );
        final fullLog = logMessages.join('\n');
        expect(result, isNull);
        expect(
          fullLog,
          contains('must be an absolute path'),
        );
      }
    });
  });
}
