// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart' hide build, link;
import 'package:hooks_runner/hooks_runner.dart';
import 'package:hooks_runner/src/model/hook_result.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('simple_link linking', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('simple_link/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: true,
      )).success;
      expect(buildResult.encodedAssets.length, 0);

      final linkResult = (await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        buildAssetTypes: [BuildAssetType.data],
      )).success;
      expect(linkResult.encodedAssets.length, 2);

      final buildNoLinkResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: false,
      )).success;
      expect(buildNoLinkResult.encodedAssets.length, 4);
    });
  });

  test('complex_link linking', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      // From package:complex_link_helper.
      const builtHelperAssets = [
        'assets/data_helper_0.json',
        'assets/data_helper_1.json',
      ];
      const helperAssetsForLinking = [
        'assets/data_helper_2.json',
        'assets/data_helper_3.json',
      ];
      // From package:complex_link.
      const mainAssetsForLinking = ['assets/data_0.json', 'assets/data_1.json'];
      final encodedAssetsForLinking = [
        ...helperAssetsForLinking,
        ...mainAssetsForLinking,
      ];
      final linkedAssets = encodedAssetsForLinking.skip(1);

      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('complex_link/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: true,
      )).success;
      expect(
        _getNames(buildResult.encodedAssets),
        unorderedEquals(builtHelperAssets),
      );
      expect(
        _getNames(buildResult.encodedAssetsForLinking['complex_link']!),
        unorderedEquals(encodedAssetsForLinking),
      );

      final linkResult = (await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        buildAssetTypes: [BuildAssetType.data],
      )).success;

      expect(
        _getNames(buildResult.encodedAssets),
        unorderedEquals(builtHelperAssets),
      );
      expect(
        _getNames(linkResult.encodedAssets),
        unorderedEquals(linkedAssets),
      );
    });
  });

  test('link metadata', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('flag_app/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await buildDataAssets(
        packageUri,
        linkingEnabled: true,
      )).success;
      expect(
        _getNames(buildResult.encodedAssetsForLinking['fun_with_flags']!),
        unorderedEquals(['assets/ca.txt', 'assets/fr.txt', 'assets/de.txt']),
      );

      final linkResult = (await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        buildAssetTypes: [BuildAssetType.data],
      )).success;

      expect(
        _getNames(linkResult.encodedAssets),
        unorderedEquals(['assets/fr.txt', 'assets/de.txt']),
      );
    });
  });

  /// Check that the metadata can't be passed from dependency upwards, so in the
  /// wrong direction. This shouldn't work, as there is an ordering to the link
  /// hooks.
  test('link inverse order', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('link_inverse_app/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final logMessages = <String>[];
      final linkResult = await link(
        packageUri,
        logger,
        dartExecutable,
        capturedLogs: logMessages,
        buildResult: HookResult(),
        buildAssetTypes: [BuildAssetType.data],
      );
      final fullLog = logMessages.join('\n');

      expect(linkResult.isFailure, isTrue);
      expect(linkResult.asFailure.failure, HooksRunnerFailure.hookRun);
      expect(
        fullLog,
        contains('All good, the metadata cant swim against the current'),
      );
    });
  });

  if (Platform.isMacOS || Platform.isWindows) {
    // https://github.com/dart-lang/native/issues/1376.
    return;
  }

  test('treeshaking assets using CLinker', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('treeshaking_native_libs/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final buildResult = (await build(
        packageUri,
        logger,
        dartExecutable,
        linkingEnabled: true,
        buildAssetTypes: [BuildAssetType.code],
      )).success;
      expect(buildResult.encodedAssets.length, 0);
      expect(buildResult.encodedAssetsForLinking.length, 1);

      final logMessages = <String>[];
      final linkResult = (await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        capturedLogs: logMessages,
        buildAssetTypes: [BuildAssetType.code],
      )).success;
      expect(linkResult.encodedAssets.length, 1);
      expect(linkResult.encodedAssets.first.isCodeAsset, isTrue);
    });
  });
}

Iterable<String> _getNames(List<EncodedAsset> assets) =>
    assets.where((e) => e.isDataAsset).map((e) => e.asDataAsset.name);
