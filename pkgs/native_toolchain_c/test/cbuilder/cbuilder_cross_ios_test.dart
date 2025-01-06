// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
@OnPlatform({
  'mac-os': Timeout.factor(2),
})
library;

import 'dart:io';

import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

const flutteriOSHighestBestEffort = 16;
const flutteriOSHighestSupported = 17;

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targets = [
    Architecture.arm64,
    Architecture.x64,
  ];

  // Dont include 'mach-o' or 'Mach-O', different spelling is used.
  const objdumpFileFormat = {
    Architecture.arm64: 'arm64',
    Architecture.x64: '64-bit x86-64',
  };

  const name = 'add';

  const optimizationLevels = OptimizationLevel.values;
  var selectOptimizationLevel = 0;

  for (final language in [Language.c, Language.objectiveC]) {
    for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
      for (final targetIOSSdk in IOSSdk.values) {
        for (final target in targets) {
          if (target == Architecture.x64 && targetIOSSdk == IOSSdk.iPhoneOS) {
            continue;
          }
          final libName = OS.iOS.libraryFileName(name, linkMode);
          for (final installName in [
            null,
            if (linkMode == DynamicLoadingBundled())
              Uri.file('@executable_path/Frameworks/$libName'),
          ]) {
            // Cycle through all optimization levels.
            final optimizationLevel =
                optimizationLevels[selectOptimizationLevel];
            selectOptimizationLevel =
                (selectOptimizationLevel + 1) % optimizationLevels.length;
            test(
                'CBuilder $linkMode $language library $targetIOSSdk $target'
                        ' ${installName ?? ''} $optimizationLevel'
                    .trim(), () async {
              final tempUri = await tempDirForTest();
              final tempUri2 = await tempDirForTest();
              final sourceUri = switch (language) {
                Language.c =>
                  packageUri.resolve('test/cbuilder/testfiles/add/src/add.c'),
                Language.objectiveC => packageUri.resolve(
                    'test/cbuilder/testfiles/add_objective_c/src/add.m'),
                Language() => throw UnimplementedError(),
              };

              final buildConfigBuilder = BuildConfigBuilder()
                ..setupHookConfig(
                  buildAssetTypes: [CodeAsset.type],
                  packageName: name,
                  packageRoot: tempUri,
                )
                ..setupBuildConfig(
                  linkingEnabled: false,
                  dryRun: false,
                )
                ..setupCodeConfig(CodeConfig(
                  targetOS: OS.iOS,
                  targetArchitecture: target,
                  linkModePreference: linkMode == DynamicLoadingBundled()
                      ? LinkModePreference.dynamic
                      : LinkModePreference.static,
                  iOSConfig: IOSConfig(
                    targetSdk: targetIOSSdk,
                    targetVersion: flutteriOSHighestBestEffort,
                  ),
                  cCompilerConfig: cCompiler,
                ));
              buildConfigBuilder.setupBuildRunConfig(
                outputDirectory: tempUri,
                outputDirectoryShared: tempUri2,
              );

              final buildConfig = BuildConfig(buildConfigBuilder.json);
              final buildOutput = BuildOutputBuilder();

              final cbuilder = CBuilder.library(
                name: name,
                assetName: name,
                sources: [sourceUri.toFilePath()],
                installName: installName,
                language: language,
                optimizationLevel: optimizationLevel,
                buildMode: BuildMode.release,
              );
              await cbuilder.run(
                config: buildConfig,
                output: buildOutput,
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
              // As of native_assets_cli 0.10.0, the min target OS version is
              // always being passed in.
              expect(otoolResult.stdout,
                  isNot(contains('LC_VERSION_MIN_IPHONEOS')));
              expect(otoolResult.stdout, contains('LC_BUILD_VERSION'));
              final platform = otoolResult.stdout
                  .split('\n')
                  .firstWhere((e) => e.contains('platform'));
              if (targetIOSSdk == IOSSdk.iPhoneOS) {
                const platformIosDevice = 2;
                expect(platform, contains(platformIosDevice.toString()));
              } else {
                const platformIosSimulator = 7;
                expect(platform, contains(platformIosSimulator.toString()));
              }

              if (linkMode == DynamicLoadingBundled()) {
                final libInstallName =
                    await runOtoolInstallName(libUri, libName);
                if (installName == null) {
                  // If no install path is passed, we have an absolute path.
                  final tempName =
                      tempUri.pathSegments.lastWhere((e) => e != '');
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

  for (final iosVersion in [
    flutteriOSHighestBestEffort,
    flutteriOSHighestSupported
  ]) {
    for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
      test('$linkMode ios min version $iosVersion', () async {
        const target = Architecture.arm64;
        final tempUri = await tempDirForTest();
        final out1Uri = tempUri.resolve('out1/');
        await Directory.fromUri(out1Uri).create();
        final out2Uri = tempUri.resolve('out1/');
        await Directory.fromUri(out2Uri).create();
        final lib1Uri = await buildLib(
          out1Uri,
          out2Uri,
          target,
          iosVersion,
          linkMode,
        );

        final otoolResult = await runProcess(
          executable: Uri.file('otool'),
          arguments: ['-l', lib1Uri.path],
          logger: logger,
        );
        expect(otoolResult.exitCode, 0);
        expect(otoolResult.stdout, contains('minos $iosVersion.0'));
      });
    }
  }
}

Future<Uri> buildLib(
  Uri tempUri,
  Uri tempUri2,
  Architecture targetArchitecture,
  int targetIOSVersion,
  LinkMode linkMode,
) async {
  final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
  const name = 'add';

  final buildConfigBuilder = BuildConfigBuilder()
    ..setupHookConfig(
      buildAssetTypes: [CodeAsset.type],
      packageName: name,
      packageRoot: tempUri,
    )
    ..setupBuildConfig(
      linkingEnabled: false,
      dryRun: false,
    )
    ..setupCodeConfig(CodeConfig(
      targetOS: OS.iOS,
      targetArchitecture: targetArchitecture,
      linkModePreference: linkMode == DynamicLoadingBundled()
          ? LinkModePreference.dynamic
          : LinkModePreference.static,
      iOSConfig: IOSConfig(
        targetSdk: IOSSdk.iPhoneOS,
        targetVersion: targetIOSVersion,
      ),
      cCompilerConfig: cCompiler,
    ));
  buildConfigBuilder.setupBuildRunConfig(
    outputDirectory: tempUri,
    outputDirectoryShared: tempUri2,
  );

  final buildConfig = BuildConfig(buildConfigBuilder.json);
  final buildOutput = BuildOutputBuilder();

  final cbuilder = CBuilder.library(
    name: name,
    assetName: name,
    sources: [addCUri.toFilePath()],
    buildMode: BuildMode.release,
  );
  await cbuilder.run(
    config: buildConfig,
    output: buildOutput,
    logger: logger,
  );

  final libUri = tempUri.resolve(OS.iOS.libraryFileName(name, linkMode));
  return libUri;
}
