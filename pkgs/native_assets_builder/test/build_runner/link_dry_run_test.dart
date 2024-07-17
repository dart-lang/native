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

        final buildResult = await buildDryRun(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: true,
        );
        expect(buildResult.assets.length, 0);

        final linkResult = await linkDryRun(
          packageUri,
          logger,
          dartExecutable,
          buildDryRunResult: buildResult,
        );
        expect(linkResult.assets.length, 2);
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

        final buildResult = await buildDryRun(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: true,
        );
        expect(buildResult.success, true);
        expect(
            _getNames(buildResult.assets), unorderedEquals(builtHelperAssets));
        expect(
          _getNames(buildResult.assetsForLinking['complex_link']!),
          unorderedEquals(assetsForLinking),
        );

        final linkResult = await linkDryRun(
          packageUri,
          logger,
          dartExecutable,
          buildDryRunResult: buildResult,
        );
        expect(linkResult.success, true);

        expect(_getNames(linkResult.assets), unorderedEquals(linkedAssets));
      });
    },
  );
}

Iterable<String> _getNames(List<AssetImpl> assets) =>
    assets.whereType<cli.DataAsset>().map((asset) => asset.name);
