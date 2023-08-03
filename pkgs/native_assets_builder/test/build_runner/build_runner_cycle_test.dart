// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
        final result = await dryRun(packageUri, logger, dartExecutable);
        expect(result.success, false);
      }

      {
        final result = await build(packageUri, logger, dartExecutable);
        expect(result.success, false);
      }
    });
  });
}
