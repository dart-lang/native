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
    Target.windowsIA32,
    Target.windowsX64,
  ];

  late Uri dumpbinUri;

  setUp(() async {
    dumpbinUri =
        (await dumpbin.defaultResolver!.resolve(logger: logger)).first.uri;
  });

  const dumpbinMachine = {
    Target.windowsIA32: 'x86',
    Target.windowsX64: 'x64',
  };

  const dumpbinFileType = {
    LinkMode.dynamic: 'DLL',
    LinkMode.static: 'LIBRARY',
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
          targetOs: target.os,
          targetArchitecture: target.architecture,
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
