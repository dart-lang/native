// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_builder/src/build_runner/build_runner.dart';
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

      BuildConfigBuilder configCreator() => BuildConfigBuilder()
        ..setupCodeConfig(
          targetArchitecture: Architecture.current,
          linkModePreference: LinkModePreference.dynamic,
        );

      await buildRunner.buildDryRun(
        configCreator: configCreator,
        targetOS: Target.current.os,
        workingDirectory: packageUri,
        linkingEnabled: false,
        supportedAssetTypes: [],
        buildValidator: (config, output) async => [],
      );
      await buildRunner.buildDryRun(
        configCreator: configCreator,
        targetOS: Target.current.os,
        workingDirectory: packageUri,
        linkingEnabled: false,
        supportedAssetTypes: [],
        buildValidator: (config, output) async => [],
      );
      await buildRunner.build(
        configCreator: configCreator,
        targetOS: OS.current,
        buildMode: BuildMode.release,
        workingDirectory: packageUri,
        linkingEnabled: false,
        supportedAssetTypes: [],
        configValidator: (config) async => [],
        buildValidator: (config, output) async => [],
        applicationAssetValidator: (_) async => [],
      );
      await buildRunner.build(
        configCreator: configCreator,
        buildMode: BuildMode.release,
        targetOS: OS.current,
        workingDirectory: packageUri,
        linkingEnabled: false,
        supportedAssetTypes: [],
        configValidator: (config) async => [],
        buildValidator: (config, output) async => [],
        applicationAssetValidator: (_) async => [],
      );
    });
  });
}
