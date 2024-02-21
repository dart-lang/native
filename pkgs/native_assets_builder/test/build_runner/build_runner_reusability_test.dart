// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_builder/src/build_runner/build_runner.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('multiple dryRun and build invocations', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      final packageUri = tempUri.resolve('package_reading_metadata/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(
        workingDirectory: packageUri,
        logger: logger,
      );

      final buildRunner = NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
      );

      await buildRunner.dryRun(
        targetOS: Target.current.os,
        linkModePreference: LinkModePreferenceImpl.dynamic,
        workingDirectory: packageUri,
        includeParentEnvironment: true,
      );
      await buildRunner.dryRun(
        targetOS: Target.current.os,
        linkModePreference: LinkModePreferenceImpl.dynamic,
        workingDirectory: packageUri,
        includeParentEnvironment: true,
      );
      await buildRunner.build(
        buildMode: BuildModeImpl.release,
        linkModePreference: LinkModePreferenceImpl.dynamic,
        target: Target.current,
        workingDirectory: packageUri,
        includeParentEnvironment: true,
      );
      await buildRunner.build(
        buildMode: BuildModeImpl.release,
        linkModePreference: LinkModePreferenceImpl.dynamic,
        target: Target.current,
        workingDirectory: packageUri,
        includeParentEnvironment: true,
      );
    });
  });
}
