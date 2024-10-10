// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targets = [
    Architecture.arm,
    Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
    Architecture.riscv64,
  ];

  for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
    for (final target in targets) {
      test('CBuilder $linkMode library $target', () async {
        final tempUri = await tempDirForTest();
        final tempUri2 = await tempDirForTest();
        final addCUri =
            packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
        const name = 'add';

        final buildConfigBuilder = BuildConfigBuilder()
          ..setupHookConfig(
            supportedAssetTypes: [CodeAsset.type],
            packageName: name,
            packageRoot: tempUri,
            targetOS: OS.linux,
            buildMode: BuildMode.release,
          )
          ..setupBuildConfig(
            linkingEnabled: false,
            dryRun: false,
          )
          ..setupCodeConfig(
            targetArchitecture: target,
            linkModePreference: linkMode == DynamicLoadingBundled()
                ? LinkModePreference.dynamic
                : LinkModePreference.static,
            cCompilerConfig: cCompiler,
          );
        buildConfigBuilder.setupBuildRunConfig(
          outputDirectory: tempUri,
          outputDirectoryShared: tempUri2,
        );

        final buildConfig = BuildConfig(buildConfigBuilder.json);
        final buildOutput = BuildOutputBuilder();

        final cbuilder = CBuilder.library(
          name: name,
          assetName: name,
          sources: [addCUri.toFilePath()],
        );
        await cbuilder.run(
          config: buildConfig,
          output: buildOutput,
          logger: logger,
        );

        final libUri =
            tempUri.resolve(OS.linux.libraryFileName(name, linkMode));
        final machine = await readelfMachine(libUri.path);
        expect(machine, contains(readElfMachine[target]));
      });
    }
  }
}
