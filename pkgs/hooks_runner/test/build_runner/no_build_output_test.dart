// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('no build output', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('no_build_output/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      final logMessages = <String>[];
      final result = await build(
        packageUri,
        createCapturingLogger(logMessages, level: Level.SEVERE),
        dartExecutable,
        buildAssetTypes: [],
      );
      expect(result.isFailure, isTrue);
      final fullLog = logMessages.join('\n');
      expect(fullLog, contains('Error reading'));
      expect(fullLog, contains('output.json'));
    });
  });
}
