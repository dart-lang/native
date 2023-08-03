// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  for (final package in [
    'wrong_build_output',
    'wrong_build_output_2',
  ]) {
    test('wrong version $package', timeout: longTimeout, () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('$package/');

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
          );
          final fullLog = logMessages.join('\n');
          expect(result.success, false);
          expect(
            fullLog,
            contains('build_output.yaml contained a format error.'),
          );
        }
      });
    });
  }
}
