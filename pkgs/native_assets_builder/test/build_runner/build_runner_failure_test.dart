// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('break build', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      {
        final result = await build(packageUri, logger, dartExecutable);
        expect(result.assets.length, 1);
        await expectSymbols(asset: result.assets.single, symbols: ['add']);
        expect(
          result.dependencies,
          [
            packageUri.resolve('build.dart'),
            packageUri.resolve('src/native_add.c'),
          ],
        );
      }

      await copyTestProjects(
        sourceUri: testDataUri.resolve('native_add_break_build/'),
        targetUri: packageUri,
      );

      {
        var buildFailed = false;
        try {
          await build(packageUri, logger, dartExecutable);
        } catch (error) {
          buildFailed = true;
        }
        expect(buildFailed, true);
      }

      await copyTestProjects(
        sourceUri: testDataUri.resolve('native_add_fix_build/'),
        targetUri: packageUri,
      );

      {
        final result = await build(packageUri, logger, dartExecutable);
        expect(result.assets.length, 1);
        await expectSymbols(asset: result.assets.single, symbols: ['add']);
        expect(
          result.dependencies,
          [
            packageUri.resolve('build.dart'),
            packageUri.resolve('src/native_add.c'),
          ],
        );
      }
    });
  });
}
