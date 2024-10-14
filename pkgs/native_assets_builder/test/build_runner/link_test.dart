// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

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

        final buildResult = (await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: true,
          supportedAssetTypes: [DataAsset.type],
          configValidator: validateDataAssetBuildConfig,
          buildValidator: validateDataAssetBuildOutput,
          applicationAssetValidator: (_) async => [],
        ))!;
        expect(buildResult.encodedAssets.length, 0);

        final linkResult = (await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          supportedAssetTypes: [DataAsset.type],
          configValidator: validateDataAssetLinkConfig,
          linkValidator: validateDataAssetLinkOutput,
          applicationAssetValidator: (_) async => [],
        ))!;
        expect(linkResult.encodedAssets.length, 2);

        final buildNoLinkResult = (await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: false,
          supportedAssetTypes: [DataAsset.type],
          configValidator: validateDataAssetBuildConfig,
          buildValidator: validateDataAssetBuildOutput,
          applicationAssetValidator: (_) async => [],
        ))!;
        expect(buildNoLinkResult.encodedAssets.length, 4);
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
        final encodedAssetsForLinking = [
          ...helperAssetsForLinking,
          ...mainAssetsForLinking,
        ];
        final linkedAssets = encodedAssetsForLinking.skip(1);

        await copyTestProjects(targetUri: tempUri);
        final packageUri = tempUri.resolve('complex_link/');

        // First, run `pub get`, we need pub to resolve our dependencies.
        await runPubGet(workingDirectory: packageUri, logger: logger);

        final buildResult = await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: true,
          supportedAssetTypes: [DataAsset.type],
          configValidator: validateDataAssetBuildConfig,
          buildValidator: validateDataAssetBuildOutput,
          applicationAssetValidator: (_) async => [],
        );
        expect(buildResult, isNotNull);
        expect(_getNames(buildResult!.encodedAssets),
            unorderedEquals(builtHelperAssets));
        expect(
          _getNames(buildResult.encodedAssetsForLinking['complex_link']!),
          unorderedEquals(encodedAssetsForLinking),
        );

        final linkResult = await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          supportedAssetTypes: [DataAsset.type],
          configValidator: validateDataAssetLinkConfig,
          linkValidator: validateDataAssetLinkOutput,
          applicationAssetValidator: (_) async => [],
        );
        expect(linkResult, isNotNull);

        expect(_getNames(linkResult!.encodedAssets),
            unorderedEquals([...builtHelperAssets, ...linkedAssets]));
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

      final buildResult = (await build(
        packageUri,
        logger,
        dartExecutable,
        linkingEnabled: true,
        supportedAssetTypes: [DataAsset.type],
        configValidator: validateDataAssetBuildConfig,
        buildValidator: validateDataAssetBuildOutput,
        applicationAssetValidator: (_) async => [],
      ))!;
      expect(buildResult.encodedAssets.length, 0);
      expect(buildResult.encodedAssetsForLinking.length, 0);

      final logMessages = <String>[];
      final linkResult = (await link(
        packageUri,
        logger,
        dartExecutable,
        buildResult: buildResult,
        capturedLogs: logMessages,
        supportedAssetTypes: [DataAsset.type],
        configValidator: validateDataAssetLinkConfig,
        linkValidator: validateDataAssetLinkOutput,
        applicationAssetValidator: (_) async => [],
      ))!;
      expect(linkResult.encodedAssets.length, 0);
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

        final buildResult = (await build(
          packageUri,
          logger,
          dartExecutable,
          linkingEnabled: true,
          supportedAssetTypes: [CodeAsset.type],
          configValidator: validateCodeBuildConfig,
          buildValidator: validateCodeAssetBuildOutput,
          applicationAssetValidator: validateCodeAssetsInApplication,
        ))!;
        expect(buildResult.encodedAssets.length, 0);
        expect(buildResult.encodedAssetsForLinking.length, 1);

        final logMessages = <String>[];
        final linkResult = (await link(
          packageUri,
          logger,
          dartExecutable,
          buildResult: buildResult,
          capturedLogs: logMessages,
          supportedAssetTypes: [CodeAsset.type],
          configValidator: validateCodeLinkConfig,
          linkValidator: validateCodeAssetLinkOutput,
          applicationAssetValidator: validateCodeAssetsInApplication,
        ))!;
        expect(linkResult.encodedAssets.length, 1);
        expect(linkResult.encodedAssets.first.type, CodeAsset.type);
      });
    },
  );
}

Iterable<String> _getNames(List<EncodedAsset> assets) => assets
    .where((e) => e.type == DataAsset.type)
    .map((e) => DataAsset.fromEncoded(e).name);
