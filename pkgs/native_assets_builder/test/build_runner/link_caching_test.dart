// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_builder/native_assets_builder.dart';
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
        buildResult =
            (await buildDataAssets(
              packageUri,
              linkingEnabled: true,
              capturedLogs: logMessages,
            ))!;
      }

      Future<void> runLink() async {
        logMessages.clear();
        linkResult =
            (await link(
              packageUri,
              logger,
              dartExecutable,
              buildResult: buildResult,
              buildAssetTypes: [DataAsset.type],
              capturedLogs: logMessages,
              inputValidator: validateDataAssetLinkInput,
              linkValidator: validateDataAssetLinkOutput,
              applicationAssetValidator: (_) async => [],
            ))!;
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
}
