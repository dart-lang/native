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
    Target.iOSX64,
  ];

  // Dont include 'mach-o' or 'Mach-O', different spelling is used.
  const objdumpFileFormat = {
    Target.iOSArm64: 'arm64',
    Target.iOSX64: '64-bit x86-64',
  };

  const name = 'add';

  for (final linkMode in LinkMode.values) {
    for (final targetIOSSdk in IOSSdk.values) {
      for (final target in targets) {
        if (target == Target.iOSX64 && targetIOSSdk == IOSSdk.iPhoneOs) {
          continue;
        }

        final libName = target.os.libraryFileName(name, linkMode);
        for (final installName in [
          null,
          if (linkMode == LinkMode.dynamic)
            Uri.file('@executable_path/Frameworks/$libName'),
        ]) {
          test(
              'Cbuilder $linkMode library $targetIOSSdk $target'
                      ' ${installName ?? ''}'
                  .trim(), () async {
            await inTempDir((tempUri) async {
              final addCUri =
                  packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
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
                installName: installName,
              );
              await cbuilder.run(
                buildConfig: buildConfig,
                buildOutput: buildOutput,
                logger: logger,
              );

              final libUri = tempUri.resolve(libName);
              final objdumpResult = await runProcess(
                executable: Uri.file('objdump'),
                arguments: ['-t', libUri.path],
                logger: logger,
              );
              expect(objdumpResult.exitCode, 0);
              final machine = objdumpResult.stdout
                  .split('\n')
                  .firstWhere((e) => e.contains('file format'));
              expect(machine, contains(objdumpFileFormat[target]));

              if (linkMode == LinkMode.dynamic) {
                final libInstallName =
                    await runOtoolInstallName(libUri, libName);
                if (installName == null) {
                  // If no install path is passed, we have an absolute path.
                  final tempName =
                      tempUri.pathSegments.lastWhere((e) => e != '');
                  final pathEnding =
                      Uri.directory(tempName).resolve(libName).toFilePath();
                  expect(Uri.file(libInstallName).isAbsolute, true);
                  expect(libInstallName, contains(pathEnding));
                } else {
                  expect(libInstallName, installName.toFilePath());
                }
              }
            });
          });
        }
      }
    }
  }
}
