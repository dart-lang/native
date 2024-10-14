// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:file_testing/file_testing.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('dry_run', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('native_add/');

      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      final dryRunResult = (await buildDryRun(
        packageUri,
        logger,
        dartExecutable,
        linkingEnabled: false,
        supportedAssetTypes: [CodeAsset.type],
        buildValidator: validateCodeAssetBuildOutput,
      ))!;
      final buildResult = (await build(
        packageUri,
        logger,
        dartExecutable,
        supportedAssetTypes: [CodeAsset.type],
        configValidator: validateCodeBuildConfig,
        buildValidator: validateCodeAssetBuildOutput,
        applicationAssetValidator: validateCodeAssetsInApplication,
      ))!;

      expect(dryRunResult.encodedAssets.length, 1);
      expect(buildResult.encodedAssets.length, 1);

      final dryRunAsset = dryRunResult.encodedAssets[0];
      expect(dryRunAsset.type, CodeAsset.type);
      final dryRunCodeAsset = CodeAsset.fromEncoded(dryRunAsset);

      final buildAsset = buildResult.encodedAssets[0];
      final buildCodeAsset = CodeAsset.fromEncoded(buildAsset);
      expect(buildAsset.type, CodeAsset.type);

      // Common across dry-run & build
      expect(dryRunCodeAsset.id, buildCodeAsset.id);
      expect(dryRunCodeAsset.os, buildCodeAsset.os);
      expect(dryRunCodeAsset.linkMode, buildCodeAsset.linkMode);
      expect(dryRunCodeAsset.file?.pathSegments.last,
          buildCodeAsset.file?.pathSegments.last);

      // Different in dry-run: No architecture
      expect(dryRunCodeAsset.architecture, isNull);
      expect(buildCodeAsset.architecture, isNotNull);

      final nativeAssetsBuilderDirectory =
          packageUri.resolve('.dart_tool/native_assets_builder/');
      final buildDirectories =
          Directory.fromUri(nativeAssetsBuilderDirectory).list();
      await for (final directory in buildDirectories) {
        if (directory is! Directory) {
          expect(
            File.fromUri(directory.uri.resolve('config.json')),
            exists,
          );
          expect(
            File.fromUri(directory.uri.resolve('out/build_output.json')),
            exists,
          );
        }
      }
    });
  });
}
