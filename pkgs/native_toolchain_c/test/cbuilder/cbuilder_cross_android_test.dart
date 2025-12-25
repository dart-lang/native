// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Timeout.factor(4)
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
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

  const optimizationLevels = OptimizationLevel.values;
  var selectOptimizationLevel = 0;

  for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
    for (final target in targets) {
      for (final apiLevel in [
        flutterAndroidNdkVersionLowestSupported,
        flutterAndroidNdkVersionHighestSupported,
      ]) {
        // Cycle through all optimization levels.
        final optimizationLevel = optimizationLevels[selectOptimizationLevel];
        selectOptimizationLevel =
            (selectOptimizationLevel + 1) % optimizationLevels.length;
        test('CBuilder $linkMode library $target minSdkVersion $apiLevel '
            '$optimizationLevel', () async {
          final tempUri = await tempDirForTest();
          final libUri = await buildLib(
            tempUri,
            target,
            apiLevel,
            linkMode,
            optimizationLevel: optimizationLevel,
          );
          await expectMachineArchitecture(libUri, target, OS.android);
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
    await expectPageSize(libUri, pageSize);
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
    ..setupShared(
      packageName: name,
      packageRoot: tempUri,
      outputFile: tempUri.resolve('output.json'),
      outputDirectoryShared: tempUriShared,
    )
    ..config.setupBuild(linkingEnabled: false)
    ..addExtension(
      CodeAssetExtension(
        targetOS: OS.android,
        targetArchitecture: targetArchitecture,
        cCompiler: cCompiler,
        android: AndroidCodeConfig(targetNdkApi: androidNdkApi),
        linkModePreference: linkMode == DynamicLoadingBundled()
            ? LinkModePreference.dynamic
            : LinkModePreference.static,
      ),
    );

  final buildInput = buildInputBuilder.build();
  final buildOutput = BuildOutputBuilder();

  final cbuilder = CBuilder.library(
    name: name,
    assetName: name,
    sources: [addCUri.toFilePath()],
    flags: flags,
    buildMode: BuildMode.release,
  );
  await cbuilder.run(input: buildInput, output: buildOutput, logger: logger);

  final libUri = buildInput.outputDirectory.resolve(
    OS.android.libraryFileName(name, linkMode),
  );
  return libUri;
}
