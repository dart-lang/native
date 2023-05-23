// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
@OnPlatform({
  'mac-os': Timeout.factor(2),
})
library;

import 'dart:io';

import 'package:c_compiler/c_compiler.dart';
import 'package:c_compiler/src/utils/run_process.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targets = [
    Target.iOSArm64,
  ];

  // Dont include 'mach-o' or 'Mach-O', different spelling is used.
  const objdumpFileFormat = {
    Target.iOSArm64: 'arm64',
  };

  for (final linkMode in LinkMode.values) {
    for (final targetIOSSdk in IOSSdk.values) {
      for (final target in targets) {
        test('Cbuilder $linkMode library $targetIOSSdk $target', () async {
          await inTempDir((tempUri) async {
            final addCUri =
                packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
            const name = 'add';

            final buildConfig = BuildConfig(
              outDir: tempUri,
              packageRoot: tempUri,
              target: target,
              linkModePreference: linkMode == LinkMode.dynamic
                  ? LinkModePreference.dynamic
                  : LinkModePreference.static,
              targetIOSSdk: targetIOSSdk,
            );
            final buildOutput = BuildOutput();

            final cbuilder = CBuilder.library(
              name: name,
              assetName: name,
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
        });
      }
    }
  }
}
