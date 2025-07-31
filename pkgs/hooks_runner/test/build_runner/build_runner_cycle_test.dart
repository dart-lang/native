// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks_runner/src/model/hook_result.dart' show HookResult;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('build cycle', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('cyclic_package_1/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      {
        final logMessages = <String>[];
        final result = await build(
          packageUri,
          createCapturingLogger(logMessages, level: Level.SEVERE),
          dartExecutable,
          buildAssetTypes: [],
        );
        final fullLog = logMessages.join('\n');
        expect(result.isFailure, isTrue);
        expect(
          fullLog,
          contains(
            'Cyclic dependency for build hooks in the following '
            'packages: [cyclic_package_1, cyclic_package_2]',
          ),
        );
      }
    });
  });

  test('link cycle', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('cyclic_link_package_1/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      {
        final logMessages = <String>[];
        final result = await link(
          buildResult: HookResult(),
          packageUri,
          createCapturingLogger(logMessages, level: Level.SEVERE),
          dartExecutable,
          buildAssetTypes: [],
        );
        final fullLog = logMessages.join('\n');
        expect(result.isFailure, isTrue);
        expect(
          fullLog,
          contains(
            'Cyclic dependency for link hooks in the following '
            'packages: [cyclic_link_package_1, cyclic_link_package_2]',
          ),
        );
      }
    });
  });
}
