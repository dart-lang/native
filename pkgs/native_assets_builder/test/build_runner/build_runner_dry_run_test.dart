// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:file_testing/file_testing.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
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

      final dryRunResult = await dryRun(
        packageUri,
        logger,
        dartExecutable,
      );
      final dryRunAssets = dryRunResult.assets.toList();
      final result = await build(
        packageUri,
        logger,
        dartExecutable,
      );

      // Every OS has more than one architecture.
      expect(dryRunAssets.length, greaterThan(result.assets.length));
      for (var i = 0; i < dryRunAssets.length; i++) {
        final dryRunAsset = dryRunAssets[i];
        final buildAsset = result.assets[0];
        expect(dryRunAsset.id, buildAsset.id);
        // The build runner expands NativeCodeAssets to all architectures.
        expect(buildAsset.file, isNotNull);
        if (dryRunAsset is NativeCodeAssetImpl &&
            buildAsset is NativeCodeAssetImpl) {
          expect(dryRunAsset.architecture, isNotNull);
          expect(buildAsset.architecture, isNotNull);
          expect(dryRunAsset.os, buildAsset.os);
          expect(dryRunAsset.linkMode, buildAsset.linkMode);
        }
      }

      final dryRunDir = packageUri.resolve(
          '.dart_tool/native_assets_builder/dry_run_${Target.current.os}_dynamic/');
      expect(File.fromUri(dryRunDir.resolve('config.json')), exists);
      expect(File.fromUri(dryRunDir.resolve('out/build_output.json')), exists);
      //
    });
  });
}
