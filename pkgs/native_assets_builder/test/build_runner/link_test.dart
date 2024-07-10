// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart' as cli;
import 'package:native_assets_cli/src/api/asset.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
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
        );
        expect(buildResult.assets.length, 0);

        final linkResult = await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
        );
        expect(linkResult.assets.length, 2);

        final buildNoLinkResult = await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: false,
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
        // From package:complex_link_helper
        const builtHelperAssets = ['data_helper_0', 'data_helper_1'];
        const helperAssetsForLinking = ['data_helper_2', 'data_helper_3'];
        // From package:complex_link
        const mainAssetsForLinking = ['data_0', 'data_1'];
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
        );
        expect(buildResult.success, true);
        expect(_getNames(buildResult.assets), orderedEquals(builtHelperAssets));
        expect(
          _getNames(buildResult.assetsForLinking['complex_link']!),
          orderedEquals(assetsForLinking),
        );

        final linkResult = await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
        );
        expect(linkResult.success, true);

        expect(_getNames(linkResult.assets), orderedEquals(linkedAssets));
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
}

Iterable<String> _getNames(List<AssetImpl> assets) =>
    assets.whereType<cli.DataAsset>().map((asset) => asset.name);
