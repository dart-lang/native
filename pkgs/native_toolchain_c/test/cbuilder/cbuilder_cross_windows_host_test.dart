// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('windows')
@OnPlatform({
  'windows': Timeout.factor(10),
})
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/native_toolchain/msvc.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isWindows) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targets = [
    Architecture.ia32,
    Architecture.x64,
  ];

  late Uri dumpbinUri;

  setUp(() async {
    dumpbinUri =
        (await dumpbin.defaultResolver!.resolve(logger: logger)).first.uri;
  });

  const dumpbinMachine = {
    Architecture.ia32: 'x86',
    Architecture.x64: 'x64',
  };

  final dumpbinFileType = {
    DynamicLoadingBundled(): 'DLL',
    StaticLinking(): 'LIBRARY',
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
          targetOS: OS.windows,
          targetArchitecture: target,
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
            tempUri.resolve(OS.windows.libraryFileName(name, linkMode));
        expect(await File.fromUri(libUri).exists(), true);
        final result = await runProcess(
          executable: dumpbinUri,
          arguments: ['/HEADERS', libUri.toFilePath()],
          logger: logger,
        );
        expect(result.exitCode, 0);
        final machine =
            result.stdout.split('\n').firstWhere((e) => e.contains('machine'));
        expect(machine, contains(dumpbinMachine[target]));
        final fileType = result.stdout
            .split('\n')
            .firstWhere((e) => e.contains('File Type'));
        expect(fileType, contains(dumpbinFileType[linkMode]));
      });
    }
  }
}
