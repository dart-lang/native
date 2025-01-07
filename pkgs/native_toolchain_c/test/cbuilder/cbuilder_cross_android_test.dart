// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

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
    Architecture.riscv64,
  ];

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

  const optimizationLevels = OptimizationLevel.values;
  var selectOptimizationLevel = 0;

  for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
    for (final target in targets) {
      for (final apiLevel in [
        flutterAndroidNdkVersionLowestBestEffort,
        flutterAndroidNdkVersionLowestSupported,
        flutterAndroidNdkVersionHighestSupported,
      ]) {
        // Cycle through all optimization levels.
        final optimizationLevel = optimizationLevels[selectOptimizationLevel];
        selectOptimizationLevel =
            (selectOptimizationLevel + 1) % optimizationLevels.length;
        test(
            'CBuilder $linkMode library $target minSdkVersion $apiLevel '
            '$optimizationLevel', () async {
          final tempUri = await tempDirForTest();
          final libUri = await buildLib(
            tempUri,
            target,
            apiLevel,
            linkMode,
            optimizationLevel: optimizationLevel,
          );
          if (Platform.isLinux) {
            final machine = await readelfMachine(libUri.path);
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
          if (linkMode == DynamicLoadingBundled()) {
            await expectPageSize(libUri, 16 * 1024);
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

  test('page size override', () async {
    const target = Architecture.arm64;
    final linkMode = DynamicLoadingBundled();
    const apiLevel1 = flutterAndroidNdkVersionLowestSupported;
    final tempUri = await tempDirForTest();
    final outUri = tempUri.resolve('out1/');
    await Directory.fromUri(outUri).create();
    const pageSize = 4 * 1024;
    final libUri = await buildLib(
      outUri,
      target,
      apiLevel1,
      linkMode,
      flags: ['-Wl,-z,max-page-size=$pageSize'],
    );
    if (Platform.isMacOS || Platform.isLinux) {
      final address = await textSectionAddress(libUri);
      expect(address, greaterThanOrEqualTo(pageSize));
      expect(address, isNot(greaterThanOrEqualTo(pageSize * 4)));
    }
  });
}

Future<Uri> buildLib(
  Uri tempUri,
  Architecture targetArchitecture,
  int androidNdkApi,
  LinkMode linkMode, {
  List<String> flags = const [],
  OptimizationLevel optimizationLevel = OptimizationLevel.o3,
}) async {
  final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
  const name = 'add';

  final tempUriShared = tempUri.resolve('shared/');
  await Directory.fromUri(tempUriShared).create();
  final buildInputBuilder = BuildInputBuilder()
    ..setupHookInput(
      packageName: name,
      packageRoot: tempUri,
      outputDirectory: tempUri,
      outputDirectoryShared: tempUriShared,
    )
    ..setupBuildInput(
      linkingEnabled: false,
      dryRun: false,
    )
    ..setupCodeConfig(
      targetOS: OS.android,
      targetArchitecture: targetArchitecture,
      cCompilerConfig: cCompiler,
      androidConfig: AndroidConfig(targetNdkApi: androidNdkApi),
      linkModePreference: linkMode == DynamicLoadingBundled()
          ? LinkModePreference.dynamic
          : LinkModePreference.static,
    );

  final buildInput = BuildInput(buildInputBuilder.json);
  final buildOutput = BuildOutputBuilder();

  final cbuilder = CBuilder.library(
    name: name,
    assetName: name,
    sources: [addCUri.toFilePath()],
    flags: flags,
    buildMode: BuildMode.release,
  );
  await cbuilder.run(
    input: buildInput,
    output: buildOutput,
    logger: logger,
  );

  final libUri = tempUri.resolve(OS.android.libraryFileName(name, linkMode));
  return libUri;
}
