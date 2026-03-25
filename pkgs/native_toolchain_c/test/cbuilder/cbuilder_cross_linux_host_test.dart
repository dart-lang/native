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
import 'package:test_case_selector/test_case_selector.dart';

import '../helpers.dart';

/// This comment is generated. To regenerate, run:
/// `REGENERATE_TEST_CONFIGS=true dart test`
///
/// | #   | Architecture | Link Mode | Optimization Level |
/// |-----|--------------|-----------|--------------------|
/// | 1   | arm          | bundled   | unspecified        |
/// | 2   | arm          | static    | O0                 |
/// | 3   | arm64        | bundled   | O2                 |
/// | 4   | arm64        | static    | unspecified        |
/// | 5   | ia32         | bundled   | O3                 |
/// | 6   | ia32         | static    | Os                 |
/// | 7   | riscv64      | bundled   | O0                 |
/// | 8   | riscv64      | static    | O2                 |
/// | 9   | x64          | bundled   | O1                 |
/// | 10  | x64          | static    | O2                 |
final configurations =
    TestCaseSelector(
      dimensions: {
        Architecture: [
          Architecture.arm,
          Architecture.arm64,
          Architecture.ia32,
          Architecture.x64,
          Architecture.riscv64,
        ],
        LinkMode: [DynamicLoadingBundled(), StaticLinking()],
        OptimizationLevel: OptimizationLevel.values,
      },
      interactionGroups: [
        {Architecture, LinkMode},
      ],
    ).selectAndValidate(
      tableUri: packageUri.resolve(
        'test/cbuilder/cbuilder_cross_linux_host_test.dart',
      ),
    );

void main() {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  for (final config in configurations) {
    final linkMode = config.get<LinkMode>();
    final target = config.get<Architecture>();
    final optimizationLevel = config.get<OptimizationLevel>();

    test('CBuilder $target $linkMode $optimizationLevel', () async {
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
