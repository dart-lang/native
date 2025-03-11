// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/local.dart';
import 'package:native_assets_builder/src/build_runner/build_runner.dart';
import 'package:native_assets_builder/src/package_layout/package_layout.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() async {
  test('multiple  build invocations', timeout: longTimeout, () async {
    await inTempDir((tempUri) async {
      await copyTestProjects(targetUri: tempUri);
      const packageName = 'package_reading_metadata';
      final packageUri = tempUri.resolve('$packageName/');

      // First, run `pub get`, we need pub to resolve our dependencies.
      await runPubGet(workingDirectory: packageUri, logger: logger);

      final packageLayout = await PackageLayout.fromWorkingDirectory(
        const LocalFileSystem(),
        packageUri,
        packageName,
      );
      final buildRunner = NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        fileSystem: const LocalFileSystem(),
        packageLayout: packageLayout,
      );

      final targetOS = OS.current;
      const defaultMacOSVersion = 13;
      final extension = CodeAssetExtension(
        targetArchitecture: Architecture.current,
        targetOS: OS.current,
        macOS:
            targetOS == OS.macOS
                ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
                : null,
        linkModePreference: LinkModePreference.dynamic,
      );

      await buildRunner.build(extensions: [extension], linkingEnabled: false);
      await buildRunner.build(extensions: [extension], linkingEnabled: false);
    });
  });
}
