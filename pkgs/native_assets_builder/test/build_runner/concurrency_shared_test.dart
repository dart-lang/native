// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:native_assets_builder/src/utils/run_process.dart'
    show RunProcessResult;
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  const packageName = 'transformer';

  test('Concurrent invocations', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      final packageUri = tempUri.resolve('$packageName/');
      await copyTestProjects(
        sourceUri: testDataUri.resolve('$packageName/'),
        targetUri: packageUri,
      );

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      Future<RunProcessResult> runBuildInProcess(
        Target target,
      ) async {
        final result = await runProcess(
          executable: dartExecutable,
          arguments: [
            pkgNativeAssetsBuilderUri
                .resolve(
                  'test/build_runner/concurrency_shared_test_helper.dart',
                )
                .toFilePath(),
            packageUri.toFilePath(),
            target.toString(),
          ],
          workingDirectory: packageUri,
          logger: logger,
        );
        expect(result.exitCode, 0);
        return result;
      }

      // Simulate running `dart run` concurrently in 3 different terminals.
      // Twice for the same target and also for a different target.
      final results = await Future.wait([
        runBuildInProcess(Target.androidArm64),
        runBuildInProcess(Target.current),
        runBuildInProcess(Target.current),
      ]);
      final stdouts = results.map((e) => e.stdout).join('\n');
      // One run for the two targets wins in running first.
      expect(stdouts, stringContainsInOrder(['Reused 0 cached files.']));
      // The other run reuses the cached results.
      expect(stdouts, stringContainsInOrder(['Reused 10 cached files.']));
      // One of the two runs for the same target will not be invoked at all.
      expect(
        stdouts,
        stringContainsInOrder([
          'Waiting to be able to obtain lock of directory',
          'Skipping build for',
        ]),
      );
    });
  });
}
