// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:c_compiler/c_compiler.dart';
import 'package:c_compiler/src/utils/run_process.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  const targets = [
    Target.androidArm,
    Target.androidArm64,
    Target.androidIA32,
    Target.androidX64,
  ];

  const readElfMachine = {
    Target.androidArm: 'ARM',
    Target.androidArm64: 'AArch64',
    Target.androidIA32: 'Intel 80386',
    Target.androidX64: 'Advanced Micro Devices X86-64',
  };

  const objdumpFileFormat = {
    Target.androidArm: 'elf32-littlearm',
    Target.androidArm64: 'elf64-littleaarch64',
    Target.androidIA32: 'elf32-i386',
    Target.androidX64: 'elf64-x86-64',
  };

  /// From https://docs.flutter.dev/reference/supported-platforms.
  const flutterAndroidNdkVersionLowestSupported = 21;

  /// From https://docs.flutter.dev/reference/supported-platforms.
  const flutterAndroidNdkVersionHighestSupported = 30;

  for (final linkMode in LinkMode.values) {
    for (final target in targets) {
      test('Cbuilder $linkMode library $target', () async {
        await inTempDir((tempUri) async {
          final libUri = await buildLib(
            tempUri,
            target,
            flutterAndroidNdkVersionLowestSupported,
            linkMode,
          );
          if (Platform.isLinux) {
            final result = await runProcess(
              executable: Uri.file('readelf'),
              arguments: ['-h', libUri.path],
              logger: logger,
            );
            expect(result.exitCode, 0);
            final machine = result.stdout
                .split('\n')
                .firstWhere((e) => e.contains('Machine:'));
            expect(machine, contains(readElfMachine[target]));
          } else if (Platform.isMacOS) {
            final result = await runProcess(
              executable: Uri.file('objdump'),
              arguments: ['-T', libUri.path],
              logger: logger,
            );
            expect(result.exitCode, 0);
            final machine = result.stdout
                .split('\n')
                .firstWhere((e) => e.contains('file format'));
            expect(machine, contains(objdumpFileFormat[target]));
          }
        });
      });
    }
  }

  test('Cbuilder API levels binary difference', () async {
    const target = Target.androidArm64;
    const linkMode = LinkMode.dynamic;
    const apiLevel1 = flutterAndroidNdkVersionLowestSupported;
    const apiLevel2 = flutterAndroidNdkVersionHighestSupported;
    await inTempDir((tempUri) async {
      final out1Uri = tempUri.resolve('out1/');
      final out2Uri = tempUri.resolve('out2/');
      final out3Uri = tempUri.resolve('out3/');
      await Directory.fromUri(out1Uri).create();
      await Directory.fromUri(out2Uri).create();
      await Directory.fromUri(out3Uri).create();
      final lib1Uri = await buildLib(out1Uri, target, apiLevel1, linkMode);
      final lib2Uri = await buildLib(out2Uri, target, apiLevel2, linkMode);
      final lib3Uri = await buildLib(out3Uri, target, apiLevel2, linkMode);
      final bytes1 = await File.fromUri(lib1Uri).readAsBytes();
      final bytes2 = await File.fromUri(lib2Uri).readAsBytes();
      final bytes3 = await File.fromUri(lib3Uri).readAsBytes();
      // Different API levels should lead to a different binary.
      expect(bytes1, isNot(bytes2));
      // Identical API levels should lead to an identical binary.
      expect(bytes2, bytes3);
    });
  });
}

Future<Uri> buildLib(
  Uri tempUri,
  Target target,
  int androidNdkApi,
  LinkMode linkMode,
) async {
  final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
  const name = 'add';

  final buildConfig = BuildConfig(
    outDir: tempUri,
    packageRoot: tempUri,
    target: target,
    targetAndroidNdkApi: androidNdkApi,
    linkModePreference: linkMode == LinkMode.dynamic
        ? LinkModePreference.dynamic
        : LinkModePreference.static,
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

  final libUri = tempUri.resolve(target.os.libraryFileName(name, linkMode));
  return libUri;
}
