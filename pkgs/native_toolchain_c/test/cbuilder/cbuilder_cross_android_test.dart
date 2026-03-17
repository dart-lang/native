// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() {
  // These configurations are a selection of combinations of architectures,
  // link modes, and optimization levels.
  // We don't test the full cartesian product to keep the CI time manageable.
  // When adding a new configuration, consider if it tests a new combination
  // that is not yet covered by the existing tests.
  final configurations = [
    (
      architecture: Architecture.arm,
      apiLevel: flutterAndroidNdkVersionLowestSupported,
      linkMode: DynamicLoadingBundled(),
      optimizationLevel: OptimizationLevel.o0,
    ),
    (
      architecture: Architecture.arm64,
      apiLevel: flutterAndroidNdkVersionHighestSupported,
      linkMode: StaticLinking(),
      optimizationLevel: OptimizationLevel.o1,
    ),
    (
      architecture: Architecture.ia32,
      apiLevel: flutterAndroidNdkVersionLowestSupported,
      linkMode: StaticLinking(),
      optimizationLevel: OptimizationLevel.o2,
    ),
    (
      architecture: Architecture.x64,
      apiLevel: flutterAndroidNdkVersionHighestSupported,
      linkMode: DynamicLoadingBundled(),
      optimizationLevel: OptimizationLevel.o3,
    ),
    (
      architecture: Architecture.riscv64,
      apiLevel: flutterAndroidNdkVersionLowestSupported,
      linkMode: DynamicLoadingBundled(),
      optimizationLevel: OptimizationLevel.oS,
    ),
    (
      architecture: Architecture.arm64,
      apiLevel: flutterAndroidNdkVersionLowestSupported,
      linkMode: StaticLinking(),
      optimizationLevel: OptimizationLevel.unspecified,
    ),
    (
      architecture: Architecture.arm,
      apiLevel: flutterAndroidNdkVersionHighestSupported,
      linkMode: DynamicLoadingBundled(),
      optimizationLevel: OptimizationLevel.o2,
    ),
  ];

  for (final (:architecture, :apiLevel, :linkMode, :optimizationLevel)
      in configurations) {
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

  test(
    'CBuilder c++_static links libc++abi on Android',
    timeout: longTimeout,
    () async {
      final tempUri = await tempDirForTest();
      final cxxabiUri = packageUri.resolve(
        'test/cbuilder/testfiles/cxxabi/src/cxxabi.cc',
      );
      const name = 'cxxabi';

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
            targetArchitecture: Architecture.arm64,
            cCompiler: cCompiler,
            android: AndroidCodeConfig(
              targetNdkApi: flutterAndroidNdkVersionLowestSupported,
            ),
            linkModePreference: .dynamic,
          ),
        );

      final buildInput = buildInputBuilder.build();
      final buildOutput = BuildOutputBuilder();

      final cbuilder = CBuilder.library(
        name: name,
        assetName: name,
        sources: [cxxabiUri.toFilePath()],
        language: .cpp,
        cppLinkStdLib: 'c++_static',
        buildMode: .release,
      );
      await cbuilder.run(
        input: buildInput,
        output: buildOutput,
        logger: logger,
      );

      final asset = BuildOutput(buildOutput.json).assets.code.first;

      // Without linking libc++abi, typeinfo for std::runtime_error
      // would be an undefined dynamic symbol, causing dlopen to fail
      // on newer Android versions.
      await expectSymbolNotUndefined(
        asset,
        OS.android,
        '_ZTISt13runtime_error',
      );
    },
  );

  test('page size override', timeout: longTimeout, () async {
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
