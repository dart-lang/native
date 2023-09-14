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
              'CBuilder $linkMode library $targetIOSSdk $target'
                      ' ${installName ?? ''}'
                  .trim(), () async {
            final tempUri = await tempDirForTest();
            final addCUri =
                packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
            final buildConfig = BuildConfig(
              outDir: tempUri,
              packageRoot: tempUri,
              targetArchitecture: target.architecture,
              targetOs: target.os,
              buildMode: BuildMode.release,
              linkModePreference: linkMode == LinkMode.dynamic
                  ? LinkModePreference.dynamic
                  : LinkModePreference.static,
              targetIOSSdk: targetIOSSdk,
            );
            final buildOutput = BuildOutput();

            final cbuilder = CBuilder.library(
              name: name,
              assetId: name,
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

            final otoolResult = await runProcess(
              executable: Uri.file('otool'),
              arguments: ['-l', libUri.path],
              logger: logger,
            );
            expect(otoolResult.exitCode, 0);
            if (targetIOSSdk == IOSSdk.iPhoneOs || target == Target.iOSX64) {
              // The x64 simulator behaves as device, presumably because the
              // devices are never x64.
              expect(otoolResult.stdout, contains('LC_VERSION_MIN_IPHONEOS'));
              expect(otoolResult.stdout, isNot(contains('LC_BUILD_VERSION')));
            } else {
              expect(otoolResult.stdout,
                  isNot(contains('LC_VERSION_MIN_IPHONEOS')));
              expect(otoolResult.stdout, contains('LC_BUILD_VERSION'));
              final platform = otoolResult.stdout
                  .split('\n')
                  .firstWhere((e) => e.contains('platform'));
              const platformIosSimulator = 7;
              expect(platform, contains(platformIosSimulator.toString()));
            }

            if (linkMode == LinkMode.dynamic) {
              final libInstallName = await runOtoolInstallName(libUri, libName);
              if (installName == null) {
                // If no install path is passed, we have an absolute path.
                final tempName = tempUri.pathSegments.lastWhere((e) => e != '');
                final pathEnding =
                    Uri.directory(tempName).resolve(libName).toFilePath();
                expect(Uri.file(libInstallName).isAbsolute, true);
                expect(libInstallName, contains(pathEnding));
                final targetInstallName =
                    '@executable_path/Frameworks/$libName';
                await runProcess(
                  executable: Uri.file('install_name_tool'),
                  arguments: [
                    '-id',
                    targetInstallName,
                    libUri.toFilePath(),
                  ],
                  logger: logger,
                );
                final libInstallName2 =
                    await runOtoolInstallName(libUri, libName);
                expect(libInstallName2, targetInstallName);
              } else {
                expect(libInstallName, installName.toFilePath());
              }
            }
          });
        }
      }
    }
  }
}
