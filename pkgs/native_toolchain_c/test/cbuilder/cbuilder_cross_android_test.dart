// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  const targets = [
    Architecture.arm,
    Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
    // TODO(rmacnak): Enable when stable NDK 27 is available.
    // Architecture.riscv64,
  ];

  const readElfMachine = {
    Architecture.arm: 'ARM',
    Architecture.arm64: 'AArch64',
    Architecture.ia32: 'Intel 80386',
    Architecture.x64: 'Advanced Micro Devices X86-64',
    Architecture.riscv64: 'RISC-V',
  };

  const objdumpFileFormat = {
    Architecture.arm: 'elf32-littlearm',
    Architecture.arm64: 'elf64-littleaarch64',
    Architecture.ia32: 'elf32-i386',
    Architecture.x64: 'elf64-x86-64',
    Architecture.riscv64: 'elf64-littleriscv',
  };

  /// From https://docs.flutter.dev/reference/supported-platforms.
  const flutterAndroidNdkVersionLowestBestEffort = 19;

  /// From https://docs.flutter.dev/reference/supported-platforms.
  const flutterAndroidNdkVersionLowestSupported = 21;

  /// From https://docs.flutter.dev/reference/supported-platforms.
  const flutterAndroidNdkVersionHighestSupported = 34;

  for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
    for (final target in targets) {
      for (final apiLevel in [
        flutterAndroidNdkVersionLowestBestEffort,
        flutterAndroidNdkVersionLowestSupported,
        flutterAndroidNdkVersionHighestSupported,
      ]) {
        test('CBuilder $linkMode library $target minSdkVersion $apiLevel',
            () async {
          final tempUri = await tempDirForTest();
          final libUri = await buildLib(
            tempUri,
            target,
            apiLevel,
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
      }
    }
  }

  test('CBuilder API levels binary difference', () async {
    const target = Architecture.arm64;
    final linkMode = DynamicLoadingBundled();
    const apiLevel1 = flutterAndroidNdkVersionLowestSupported;
    const apiLevel2 = flutterAndroidNdkVersionHighestSupported;
    final tempUri = await tempDirForTest();
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
}

Future<Uri> buildLib(
  Uri tempUri,
  Architecture targetArchitecture,
  int androidNdkApi,
  LinkMode linkMode,
) async {
  final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
  const name = 'add';

  final buildConfig = BuildConfig.build(
    outputDirectory: tempUri,
    packageName: name,
    packageRoot: tempUri,
    targetArchitecture: targetArchitecture,
    targetOS: OS.android,
    targetAndroidNdkApi: androidNdkApi,
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

  final libUri = tempUri.resolve(OS.android.libraryFileName(name, linkMode));
  return libUri;
}
