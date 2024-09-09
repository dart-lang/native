// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart' as cli;
import 'package:native_assets_cli/src/api/asset.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  const supportedAssetTypes = [DataAsset.type];

  test(
    'simple_link linking',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('simple_link/');

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(
          workingDirectory: packageUri,
          logger: logger,
        );

        final buildResult = await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: true,
          supportedAssetTypes: supportedAssetTypes,
        );
        expect(buildResult.assets.length, 0);

        final linkResult = await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          supportedAssetTypes: supportedAssetTypes,
        );
        expect(linkResult.assets.length, 2);

        final buildNoLinkResult = await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: false,
          supportedAssetTypes: supportedAssetTypes,
        );
        expect(buildNoLinkResult.assets.length, 4);
      });
    },
  );

  test(
    'complex_link linking',
    timeout: longTimeout,
    () async {
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
        const mainAssetsForLinking = [
          'assets/data_0.json',
          'assets/data_1.json',
        ];
        final assetsForLinking = [
          ...helperAssetsForLinking,
          ...mainAssetsForLinking,
        ];
        final linkedAssets = assetsForLinking.skip(1);

        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('complex_link/');

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(workingDirectory: packageUri, logger: logger);

        final buildResult = await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: true,
          supportedAssetTypes: supportedAssetTypes,
        );
        expect(buildResult.success, true);
        expect(
            _getNames(buildResult.assets), unorderedEquals(builtHelperAssets));
        expect(
          _getNames(buildResult.assetsForLinking['complex_link']!),
          unorderedEquals(assetsForLinking),
        );

        final linkResult = await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          supportedAssetTypes: supportedAssetTypes,
        );
        expect(linkResult.success, true);

        expect(_getNames(linkResult.assets), unorderedEquals(linkedAssets));
      });
    },
  );

  test('no_asset_for_link', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('no_asset_for_link/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      final buildResult = await build(
        packageUri,
        logger,
        dartExecutable,
        linkingEnabled: true,
        supportedAssetTypes: supportedAssetTypes,
      );
      expect(buildResult.assets.length, 0);
      expect(buildResult.assetsForLinking.length, 0);

      final logMessages = <String>[];
      final linkResult = await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        capturedLogs: logMessages,
        supportedAssetTypes: supportedAssetTypes,
      );
      expect(linkResult.assets.length, 0);
      expect(
        logMessages,
        contains(
          'Skipping link hooks from no_asset_for_link due to '
          'no assets provided to link for these link hooks.',
        ),
      );
    });
  });

  if (Platform.isMacOS || Platform.isWindows) {
    // https://github.com/dart-lang/native/issues/1376.
    return;
  }

  test(
    'treeshaking assets using CLinker',
    timeout: longTimeout,
    () async {
      await inTempDir((tempUri) async {
        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('treeshaking_native_libs/');

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(
          workingDirectory: packageUri,
          logger: logger,
        );

        final buildResult = await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: true,
        );
        expect(buildResult.assets.length, 0);
        expect(buildResult.assetsForLinking.length, 1);

        final logMessages = <String>[];
        final linkResult = await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          capturedLogs: logMessages,
        );
        expect(linkResult.assets.length, 1);
        expect(linkResult.assets.first, isA<NativeCodeAsset>());
      });
    },
  );
}

Iterable<String> _getNames(List<AssetImpl> assets) =>
    assets.whereType<cli.DataAsset>().map((asset) => asset.id.name);
