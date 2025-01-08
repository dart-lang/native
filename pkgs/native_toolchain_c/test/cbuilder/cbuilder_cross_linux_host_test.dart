// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
library;

import 'dart:io';

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

  const optimizationLevels = OptimizationLevel.values;
  var selectOptimizationLevel = 0;

  for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
    for (final target in targets) {
      // Cycle through all optimization levels.
      final optimizationLevel = optimizationLevels[selectOptimizationLevel];
      selectOptimizationLevel =
          (selectOptimizationLevel + 1) % optimizationLevels.length;
      test('CBuilder $linkMode library $target $optimizationLevel', () async {
        final tempUri = await tempDirForTest();
        final tempUri2 = await tempDirForTest();
        final addCUri =
            packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
        const name = 'add';

        final buildInputBuilder = BuildInputBuilder()
          ..setupHook(
            packageName: name,
            packageRoot: tempUri,
            outputDirectory: tempUri,
            outputDirectoryShared: tempUri2,
          )
          ..config.setupBuild(
            linkingEnabled: false,
            dryRun: false,
          )
          ..config.setup(buildAssetTypes: [CodeAsset.type])
          ..config.setupCode(
            targetOS: OS.linux,
            targetArchitecture: target,
            linkModePreference: linkMode == DynamicLoadingBundled()
                ? LinkModePreference.dynamic
                : LinkModePreference.static,
            cCompilerConfig: cCompiler,
          );

        final buildInput = BuildInput(buildInputBuilder.json);
        final buildOutput = BuildOutputBuilder();

        final cbuilder = CBuilder.library(
          name: name,
          assetName: name,
          sources: [addCUri.toFilePath()],
          optimizationLevel: optimizationLevel,
          buildMode: BuildMode.release,
        );
        await cbuilder.run(
          input: buildInput,
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
