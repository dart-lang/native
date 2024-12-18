// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
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
        final result = (await build(
          packageUri,
          logger,
          dartExecutable,
          buildAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        ))!;
        expect(result.encodedAssets.length, 1);
        await expectSymbols(
            asset: CodeAsset.fromEncoded(result.encodedAssets.single),
            symbols: ['add']);
        expect(
          result.dependencies,
          contains(
            packageUri.resolve('src/native_add.c'),
          ),
        );
      }

      await copyTestProjects(
        sourceUri: testDataUri.resolve('native_add_break_build/'),
        targetUri: packageUri,
      );

      {
        final logMessages = <String>[];
        final result = await build(
          packageUri,
          createCapturingLogger(logMessages, level: Level.SEVERE),
          dartExecutable,
          buildAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        );
        final fullLog = logMessages.join('\n');
        expect(result, isNull);
        expect(fullLog, contains('To reproduce run:'));
        final reproCommand = fullLog
            .split('\n')
            .skipWhile((l) => !l.contains('To reproduce run:'))
            .skip(1)
            .first;
        final reproResult =
            await Process.run(reproCommand, [], runInShell: true);
        expect(reproResult.exitCode, isNot(0));
      }

      await copyTestProjects(
        sourceUri: testDataUri.resolve('native_add_fix_build/'),
        targetUri: packageUri,
      );

      {
        final result = (await build(
          packageUri,
          logger,
          dartExecutable,
          buildAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        ))!;
        expect(result.encodedAssets.length, 1);
        await expectSymbols(
            asset: CodeAsset.fromEncoded(result.encodedAssets.single),
            symbols: ['add']);
        expect(
          result.dependencies,
          contains(
            packageUri.resolve('src/native_add.c'),
          ),
        );
      }
    });
  });

  test('do not build dependees after build failure', timeout: longTimeout,
      () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('depend_on_fail_build_app/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      final logMessages = <String>[];
      await build(
        packageUri,
        logger,
        capturedLogs: logMessages,
        dartExecutable,
        buildAssetTypes: [CodeAsset.type],
        configValidator: validateCodeAssetBuildConfig,
        buildValidator: validateCodeAssetBuildOutput,
        applicationAssetValidator: validateCodeAssetInApplication,
      );
      Matcher stringContainsBuildHookCompilation(String packageName) =>
          stringContainsInOrder([
            'Running',
            'hook.dill',
            '$packageName${Platform.pathSeparator}'
                'hook${Platform.pathSeparator}build.dart',
          ]);
      expect(
        logMessages.join('\n'),
        stringContainsBuildHookCompilation('fail_build'),
      );
      expect(
        logMessages.join('\n'),
        isNot(stringContainsBuildHookCompilation('depends_on_fail_build')),
      );
    });
  });
}
