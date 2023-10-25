// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targets = [
    Target.linuxArm,
    Target.linuxArm64,
    Target.linuxIA32,
    Target.linuxX64,
    Target.linuxRiscv64,
  ];

  const readElfMachine = {
    Target.linuxArm: 'ARM',
    Target.linuxArm64: 'AArch64',
    Target.linuxIA32: 'Intel 80386',
    Target.linuxX64: 'Advanced Micro Devices X86-64',
    Target.linuxRiscv64: 'RISC-V',
  };

  for (final linkMode in LinkMode.values) {
    for (final target in targets) {
      test('CBuilder $linkMode library $target', () async {
        final tempUri = await tempDirForTest();
        final addCUri =
            packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
        const name = 'add';

        final buildConfig = BuildConfig(
          outDir: tempUri,
          packageName: name,
          packageRoot: tempUri,
          targetArchitecture: target.architecture,
          targetOs: target.os,
          buildMode: BuildMode.release,
          linkModePreference: linkMode == LinkMode.dynamic
              ? LinkModePreference.dynamic
              : LinkModePreference.static,
        );
        final buildOutput = BuildOutput();

        final cbuilder = CBuilder.library(
          name: name,
          assetId: name,
          sources: [addCUri.toFilePath()],
        );
        await cbuilder.run(
          buildConfig: buildConfig,
          buildOutput: buildOutput,
          logger: logger,
        );

        final libUri =
            tempUri.resolve(target.os.libraryFileName(name, linkMode));
        final result = await runProcess(
          executable: Uri.file('readelf'),
          arguments: ['-h', libUri.path],
          logger: logger,
        );
        expect(result.exitCode, 0);
        final machine =
            result.stdout.split('\n').firstWhere((e) => e.contains('Machine:'));
        expect(machine, contains(readElfMachine[target]));
        expect(result.exitCode, 0);
      });
    }
  }
}
