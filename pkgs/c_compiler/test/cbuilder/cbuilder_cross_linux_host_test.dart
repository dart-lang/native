// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:c_compiler/c_compiler.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  final logger = Logger('')..level = Level.ALL;

  const targets = [
    Target.linuxArm,
    Target.linuxArm64,
    Target.linuxIA32,
    Target.linuxX64
  ];

  const readElfMachine = {
    Target.linuxArm: 'ARM',
    Target.linuxArm64: 'AArch64',
    Target.linuxIA32: 'Intel 80386',
    Target.linuxX64: 'Advanced Micro Devices X86-64',
  };

  for (final packaging in Packaging.values) {
    for (final target in targets) {
      test('Cbuilder $packaging library linux $target', () async {
        await inTempDir((tempUri) async {
          final packageUri = Directory.current.uri;
          final addCUri =
              packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
          const name = 'add';

          final buildConfig = BuildConfig(
            outDir: tempUri,
            packageRoot: tempUri,
            target: target,
            packaging: packaging == Packaging.dynamic
                ? PackagingPreference.dynamic
                : PackagingPreference.static,
          );
          final buildOutput = BuildOutput();

          final cbuilder = CBuilder.library(
            name: 'add',
            assetName: 'add',
            sources: [addCUri.toFilePath()],
          );
          await cbuilder.run(
            buildConfig: buildConfig,
            buildOutput: buildOutput,
            logger: logger,
          );

          final libUri =
              tempUri.resolve(target.os.libraryFileName(name, packaging));
          final result = await Process.run('readelf', ['-h', libUri.path]);
          expect(result.exitCode, 0);
          final machine = (result.stdout as String)
              .split('\n')
              .firstWhere((e) => e.contains('Machine:'));
          expect(machine, contains(readElfMachine[target]));
          expect(result.exitCode, 0);
        });
      });
    }
  }
}
