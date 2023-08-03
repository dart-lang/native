// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:file_testing/file_testing.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
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

      final dryRunAssets = (await dryRun(packageUri, logger, dartExecutable))
          .assets
          .where((element) => element.target == Target.current)
          .toList();
      final result = await build(packageUri, logger, dartExecutable);

      expect(dryRunAssets.length, result.assets.length);
      for (var i = 0; i < dryRunAssets.length; i++) {
        final dryRunAsset = dryRunAssets[0];
        final buildAsset = result.assets[0];
        expect(dryRunAsset.linkMode, buildAsset.linkMode);
        expect(dryRunAsset.name, buildAsset.name);
        expect(dryRunAsset.target, buildAsset.target);
        // The target folders are different, so the paths are different.
      }

      final dryRunDir = packageUri.resolve(
          '.dart_tool/native_assets_builder/dry_run_${Target.current.os}_dynamic/');
      expect(File.fromUri(dryRunDir.resolve('config.yaml')), exists);
      expect(File.fromUri(dryRunDir.resolve('out/build_output.yaml')), exists);
      //
    });
  });
}
