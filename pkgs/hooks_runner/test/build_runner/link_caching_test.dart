// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:hooks_runner/hooks_runner.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

void main() async {
  const packageName = 'simple_link';

  test('link hook caching', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('$packageName/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final logMessages = <String>[];
      late BuildResult buildResult;
      late LinkResult linkResult;
      Future<void> runBuild() async {
        logMessages.clear();
        buildResult = (await buildDataAssets(
          packageUri,
          linkingEnabled: true,
          capturedLogs: logMessages,
        )).success;
      }

      Future<void> runLink() async {
        logMessages.clear();
        linkResult = (await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          buildAssetTypes: [.data],
          capturedLogs: logMessages,
        )).success;
      }

      await runBuild();
      expect(buildResult, isNotNull);
      expect(
        logMessages.join('\n'),
        stringContainsInOrder([
          'Running',
          'compile kernel',
          '$packageName${Platform.pathSeparator}hook'
              '${Platform.pathSeparator}build.dart',
          'Running',
          'hook.dill',
        ]),
      );

      await runLink();
      expect(linkResult, isNotNull);
      expect(
        logMessages.join('\n'),
        stringContainsInOrder([
          'Running',
          'compile kernel',
          '$packageName${Platform.pathSeparator}hook'
              '${Platform.pathSeparator}link.dart',
          'Running',
          'hook.dill',
        ]),
      );

      await runBuild();
      expect(buildResult, isNotNull);
      expect(
        logMessages.join('\n'),
        contains('Skipping build for $packageName'),
      );

      await runLink();
      expect(linkResult, isNotNull);
      expect(
        logMessages.join('\n'),
        contains('Skipping link for $packageName'),
      );

      await copyTestProjects(
        sourceUri: testDataUri.resolve('simple_link_change_asset/'),
        targetUri: packageUri,
      );

      await runBuild();
      expect(buildResult, isNotNull);
      expect(
        logMessages.join('\n'),
        stringContainsInOrder(['Running', 'hook.dill']),
      );

      await runLink();
      expect(linkResult, isNotNull);
      expect(
        logMessages.join('\n'),
        stringContainsInOrder(['Running', 'hook.dill']),
      );

      await runBuild();
      expect(buildResult, isNotNull);
      expect(
        logMessages.join('\n'),
        contains('Skipping build for $packageName'),
      );

      await runLink();
      expect(linkResult, isNotNull);
      expect(
        logMessages.join('\n'),
        contains('Skipping link for $packageName'),
      );
    });
  });

  test('link hook cache isolate by entry-point and compiler', () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('$packageName/');

      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: true,
      )).success;

      final logMessages = <String>[];
      Future<void> runLink(Uri entryPoint, String compiler) async {
        logMessages.clear();
        final result = await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          recordUse: RecordUseConfig(
            file: tempUri.resolve('treeshaking.json'),
            entryPoints: [entryPoint],
            compiler: compiler,
          ),
          buildAssetTypes: [.data],
          capturedLogs: logMessages,
        );
        expect(result.isSuccess, true);
      }

      final entry1 = Uri.file('bin/simple_link.dart');
      final entry2 = Uri.file('bin/simple_link_helper.dart');

      final treeshakingFile = File.fromUri(tempUri.resolve('treeshaking.json'));
      await treeshakingFile.writeAsString('{}');

      // Run 1: (Entrypoint 1, compiler 'vm') -> Cache Miss (first compile)
      await runLink(entry1, 'vm');
      expect(logMessages.join('\n'), isNot(contains('Skipping link')));

      // Run 2: (Entrypoint 1, compiler 'dart2js') -> Cache Miss (different
      // compiler)
      await runLink(entry1, 'dart2js');
      expect(logMessages.join('\n'), isNot(contains('Skipping link')));

      // Run 3: (Entrypoint 2, compiler 'vm') -> Cache Miss (different
      // entrypoint)
      await runLink(entry2, 'vm');
      expect(logMessages.join('\n'), isNot(contains('Skipping link')));

      // Run 4: (Entrypoint 1, compiler 'vm') -> Cache Hit! (matches Run 1)
      await runLink(entry1, 'vm');
      expect(logMessages.join('\n'), contains('Skipping link for simple_link'));

      // Run 5: (Entrypoint 1, compiler 'dart2js') -> Cache Hit! (matches Run 2)
      await runLink(entry1, 'dart2js');
      expect(logMessages.join('\n'), contains('Skipping link for simple_link'));
    });
  });
}
