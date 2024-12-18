// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('cached build', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      {
        final logMessages = <String>[];
        final result = (await build(
          packageUri,
          logger,
          dartExecutable,
          capturedLogs: logMessages,
          buildAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        ))!;
        expect(
          logMessages.join('\n'),
          contains(
            'native_add${Platform.pathSeparator}hook'
            '${Platform.pathSeparator}build.dart',
          ),
        );
        expect(
          result.dependencies,
          contains(
            packageUri.resolve('src/native_add.c'),
          ),
        );
      }

      {
        final logMessages = <String>[];
        final result = (await build(
          packageUri,
          logger,
          dartExecutable,
          capturedLogs: logMessages,
          buildAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        ))!;
        final hookUri = packageUri.resolve('hook/build.dart');
        expect(
          logMessages.join('\n'),
          isNot(contains('Recompiling ${hookUri.toFilePath()}')),
        );
        expect(
          logMessages.join('\n'),
          contains('Skipping build for native_add'),
        );
        expect(
          logMessages.join('\n'),
          isNot(contains(
            'native_add${Platform.pathSeparator}hook'
            '${Platform.pathSeparator}build.dart',
          )),
        );
        expect(
          result.dependencies,
          contains(
            packageUri.resolve('src/native_add.c'),
          ),
        );
      }
    });
  });

  test('modify C file', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      final logMessages = <String>[];
      final logger = createCapturingLogger(logMessages);

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );
      logMessages.clear();

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
        await expectSymbols(
            asset: CodeAsset.fromEncoded(result.encodedAssets.single),
            symbols: ['add']);
        logMessages.clear();
      }

      await copyTestProjects(
        sourceUri: testDataUri.resolve('native_add_add_symbol/'),
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

        final cUri = packageUri.resolve('src/').resolve('native_add.c');
        expect(
          logMessages.join('\n'),
          stringContainsInOrder(
            [
              'Rerunning build for native_add in',
              'File contents changed: ${cUri.toFilePath()}.'
            ],
          ),
        );

        await expectSymbols(
          asset: CodeAsset.fromEncoded(result.encodedAssets.single),
          symbols: ['add', 'subtract'],
        );
      }
    });
  });

  test(
    'add C file, modify hook',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('native_add/');

        final logMessages = <String>[];
        final logger = createCapturingLogger(logMessages);

        await runPubGet(workingDirectory: packageUri, logger: logger);
        logMessages.clear();

        final result = (await build(
          packageUri,
          logger,
          dartExecutable,
          buildAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        ))!;
        {
          final compiledHook = logMessages
              .where((m) =>
                  m.contains('dart compile kernel') ||
                  m.contains('dart.exe compile kernel'))
              .isNotEmpty;
          expect(compiledHook, isTrue);
        }
        logMessages.clear();
        await expectSymbols(
          asset: CodeAsset.fromEncoded(result.encodedAssets.single),
          symbols: ['add'],
        );

        await copyTestProjects(
            sourceUri: testDataUri.resolve('native_add_add_source/'),
            targetUri: packageUri);

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

          final hookUri = packageUri.resolve('hook/build.dart');
          expect(
            logMessages.join('\n'),
            contains('Recompiling ${hookUri.toFilePath()}'),
          );

          logMessages.clear();
          await expectSymbols(
            asset: CodeAsset.fromEncoded(result.encodedAssets.single),
            symbols: ['add', 'multiply'],
          );
        }
      });
    },
  );

  test(
    'change environment',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('native_add/');

        final logMessages = <String>[];
        final logger = createCapturingLogger(logMessages);

        await runPubGet(workingDirectory: packageUri, logger: logger);
        logMessages.clear();

        final result = (await build(
          packageUri,
          logger,
          dartExecutable,
          buildAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        ))!;
        logMessages.clear();

        // Simulate that the environment variables changed by augmenting the
        // persisted environment from the last invocation.
        final dependenciesHashFile = File.fromUri(
          CodeAsset.fromEncoded(result.encodedAssets.single)
              .file!
              .parent
              .parent
              .resolve('dependencies.dependencies_hash_file.json'),
        );
        expect(await dependenciesHashFile.exists(), true);
        final dependenciesContent =
            jsonDecode(await dependenciesHashFile.readAsString())
                as Map<Object, Object?>;
        const modifiedEnvKey = 'PATH';
        (dependenciesContent['environment'] as List<dynamic>).add({
          'key': modifiedEnvKey,
          'hash': 123456789,
        });
        await dependenciesHashFile
            .writeAsString(jsonEncode(dependenciesContent));

        (await build(
          packageUri,
          logger,
          dartExecutable,
          buildAssetTypes: [CodeAsset.type],
          configValidator: validateCodeAssetBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetInApplication,
        ))!;
        expect(
          logMessages.join('\n'),
          contains('hook.dill'),
        );
        expect(
          logMessages.join('\n'),
          isNot(contains('Skipping build for native_add')),
        );
        expect(
          logMessages.join('\n'),
          contains('Environment variable changed: $modifiedEnvKey.'),
        );
        logMessages.clear();
      });
    },
  );
}
