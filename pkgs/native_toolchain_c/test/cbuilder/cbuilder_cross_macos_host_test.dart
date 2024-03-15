// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
@OnPlatform({
  'mac-os': Timeout.factor(2),
})
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targets = [
    Architecture.arm64,
    Architecture.x64,
  ];

  // Dont include 'mach-o' or 'Mach-O', different spelling is used.
  const objdumpFileFormat = {
    Architecture.arm64: 'arm64',
    Architecture.x64: '64-bit x86-64',
  };

  for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
    for (final target in targets) {
      test('CBuilder $linkMode library $target', () async {
        final tempUri = await tempDirForTest();
        final addCUri =
            packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
        const name = 'add';

        final buildConfig = BuildConfig.build(
          outputDirectory: tempUri,
          packageName: name,
          packageRoot: tempUri,
          targetArchitecture: target,
          targetOS: OS.macOS,
          buildMode: BuildMode.release,
          linkModePreference: linkMode == DynamicLoadingBundled()
              ? LinkModePreference.dynamic
              : LinkModePreference.static,
        );
        final buildOutput = BuildOutput();

        final cbuilder = CBuilder.library(
          name: name,
          assetName: name,
          sources: [addCUri.toFilePath()],
          dartBuildFiles: ['hook/build.dart'],
        );
        await cbuilder.run(
          buildConfig: buildConfig,
          buildOutput: buildOutput,
          logger: logger,
        );

        final libUri =
            tempUri.resolve(OS.macOS.libraryFileName(name, linkMode));
        final result = await runProcess(
          executable: Uri.file('objdump'),
          arguments: ['-t', libUri.path],
          logger: logger,
        );
        expect(result.exitCode, 0);
        final machine = result.stdout
            .split('\n')
            .firstWhere((e) => e.contains('file format'));
        expect(machine, contains(objdumpFileFormat[target]));
      });
    }
  }
}
