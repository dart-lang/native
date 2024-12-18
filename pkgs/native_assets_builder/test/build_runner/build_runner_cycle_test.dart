// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('cycle', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('cyclic_package_1/');

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
          buildAssetTypes: [],
          configValidator: (config) async => [],
          buildValidator: (config, output) async => [],
          applicationAssetValidator: (_) async => [],
        );
        final fullLog = logMessages.join('\n');
        expect(result, isNull);
        expect(
          fullLog,
          contains(
            'Cyclic dependency for native asset builds in the following '
            'packages: [cyclic_package_1, cyclic_package_2]',
          ),
        );
      }
    });
  });
}
