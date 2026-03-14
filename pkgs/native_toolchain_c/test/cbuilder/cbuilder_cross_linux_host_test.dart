// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  // These configurations are a selection of combinations of architectures,
  // link modes, and optimization levels.
  // We don't test the full cartesian product to keep the CI time manageable.
  // When adding a new configuration, consider if it tests a new combination
  // that is not yet covered by the existing tests.
  final configurations = [
    (
      linkMode: DynamicLoadingBundled(),
      target: Architecture.arm,
      optimizationLevel: OptimizationLevel.o0,
    ),
    (
      linkMode: StaticLinking(),
      target: Architecture.arm64,
      optimizationLevel: OptimizationLevel.o1,
    ),
    (
      linkMode: DynamicLoadingBundled(),
      target: Architecture.ia32,
      optimizationLevel: OptimizationLevel.o2,
    ),
    (
      linkMode: StaticLinking(),
      target: Architecture.x64,
      optimizationLevel: OptimizationLevel.o3,
    ),
    (
      linkMode: DynamicLoadingBundled(),
      target: Architecture.riscv64,
      optimizationLevel: OptimizationLevel.oS,
    ),
    (
      linkMode: StaticLinking(),
      target: Architecture.arm,
      optimizationLevel: OptimizationLevel.unspecified,
    ),
  ];

  for (final (:linkMode, :target, :optimizationLevel) in configurations) {
    test('CBuilder $linkMode library $target $optimizationLevel', () async {
      final tempUri = await tempDirForTest();
      final tempUri2 = await tempDirForTest();
      final addCUri = packageUri.resolve(
        'test/cbuilder/testfiles/add/src/add.c',
      );
      const name = 'add';

      final buildInputBuilder = BuildInputBuilder()
        ..setupShared(
          packageName: name,
          packageRoot: tempUri,
          outputFile: tempUri.resolve('output.json'),
          outputDirectoryShared: tempUri2,
        )
        ..config.setupBuild(linkingEnabled: false)
        ..addExtension(
          CodeAssetExtension(
            targetOS: .linux,
            targetArchitecture: target,
            linkModePreference: linkMode == DynamicLoadingBundled()
                ? .dynamic
                : .static,
            cCompiler: cCompiler,
          ),
        );

      final buildInput = buildInputBuilder.build();
      final buildOutput = BuildOutputBuilder();

      final cbuilder = CBuilder.library(
        name: name,
        assetName: name,
        sources: [addCUri.toFilePath()],
        optimizationLevel: optimizationLevel,
        buildMode: .release,
      );
      await cbuilder.run(
        input: buildInput,
        output: buildOutput,
        logger: logger,
      );

      final libUri = buildInput.outputDirectory.resolve(
        OS.linux.libraryFileName(name, linkMode),
      );
      final machine = await readelfMachine(libUri.path);
      expect(machine, contains(readElfMachine[target]));
    });
  }
}
