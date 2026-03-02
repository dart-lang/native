// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import '../utils/test_configuration_generator.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() {
  final configurations =
      TestConfigurationGenerator(
        dimensions: {
          Architecture: [
            Architecture.arm,
            Architecture.arm64,
            Architecture.ia32,
            Architecture.x64,
            Architecture.riscv64,
          ],
          LinkMode: [DynamicLoadingBundled(), StaticLinking()],
          OptimizationLevel: OptimizationLevel.values,
          AndroidApiLevel: [
            AndroidApiLevel.flutterLowestSupported,
            AndroidApiLevel.flutterHighestSupported,
          ],
        },
        interactionGroups: [
          {Architecture, LinkMode},
          {Architecture, AndroidApiLevel},
        ],
      ).generateAndValidate(
        tableUri: packageUri.resolve(
          'test/cbuilder/cbuilder_cross_android_test.md',
        ),
      );

  for (final config in configurations) {
    final architecture = config.get<Architecture>();
    final linkMode = config.get<LinkMode>();
    final optimizationLevel = config.get<OptimizationLevel>();
    final apiLevel = config.get<AndroidApiLevel>().value;

    test(
      'CBuilder $linkMode library $architecture minSdkVersion $apiLevel '
      '$optimizationLevel',
      timeout: longTimeout,
      () async {
        final tempUri = await tempDirForTest();
        final libUri = await buildLib(
          tempUri,
          architecture,
          apiLevel,
          linkMode,
          optimizationLevel: optimizationLevel,
        );
        await expectMachineArchitecture(libUri, architecture, OS.android);
        if (linkMode == DynamicLoadingBundled()) {
          await expectPageSize(libUri, 16 * 1024);
        }
      },
    );
  }

  test('CBuilder API levels binary difference', timeout: longTimeout, () async {
    const target = Architecture.arm64;
    final linkMode = DynamicLoadingBundled();
    final apiLevel1 = AndroidApiLevel.flutterLowestSupported.value;
    final apiLevel2 = AndroidApiLevel.flutterHighestSupported.value;
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

  test('page size override', timeout: longTimeout, () async {
    const target = Architecture.arm64;
    final linkMode = DynamicLoadingBundled();
    final apiLevel1 = AndroidApiLevel.flutterLowestSupported.value;
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
        targetOS: .android,
        targetArchitecture: targetArchitecture,
        cCompiler: cCompiler,
        android: AndroidCodeConfig(targetNdkApi: androidNdkApi),
        linkModePreference: linkMode == DynamicLoadingBundled()
            ? .dynamic
            : .static,
      ),
    );

  final buildInput = buildInputBuilder.build();
  final buildOutput = BuildOutputBuilder();

  final cbuilder = CBuilder.library(
    name: name,
    assetName: name,
    sources: [addCUri.toFilePath()],
    flags: flags,
    buildMode: .release,
  );
  await cbuilder.run(input: buildInput, output: buildOutput, logger: logger);

  final libUri = buildInput.outputDirectory.resolve(
    OS.android.libraryFileName(name, linkMode),
  );
  return libUri;
}
