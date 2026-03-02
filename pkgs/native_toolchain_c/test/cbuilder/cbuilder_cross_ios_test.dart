// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
@OnPlatform({'mac-os': Timeout.factor(2)})
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/utils/run_process.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const name = 'add';

  // These configurations are a selection of combinations of architectures,
  // link modes, and optimization levels.
  // We don't test the full cartesian product to keep the CI time manageable.
  // When adding a new configuration, consider if it tests a new combination
  // that is not yet covered by the existing tests.
  final configurations = [
    (
      language: Language.c,
      linkMode: DynamicLoadingBundled(),
      targetIOSSdk: IOSSdk.iPhoneOS,
      target: Architecture.arm64,
      hasInstallName: false,
      optimizationLevel: OptimizationLevel.o0,
    ),
    (
      language: Language.objectiveC,
      linkMode: StaticLinking(),
      targetIOSSdk: IOSSdk.iPhoneSimulator,
      target: Architecture.x64,
      hasInstallName: false,
      optimizationLevel: OptimizationLevel.o1,
    ),
    (
      language: Language.c,
      linkMode: StaticLinking(),
      targetIOSSdk: IOSSdk.iPhoneSimulator,
      target: Architecture.arm64,
      hasInstallName: false,
      optimizationLevel: OptimizationLevel.o2,
    ),
    (
      language: Language.objectiveC,
      linkMode: DynamicLoadingBundled(),
      targetIOSSdk: IOSSdk.iPhoneOS,
      target: Architecture.arm64,
      hasInstallName: true,
      optimizationLevel: OptimizationLevel.o3,
    ),
    (
      language: Language.c,
      linkMode: DynamicLoadingBundled(),
      targetIOSSdk: IOSSdk.iPhoneSimulator,
      target: Architecture.x64,
      hasInstallName: true,
      optimizationLevel: OptimizationLevel.oS,
    ),
    (
      language: Language.objectiveC,
      linkMode: StaticLinking(),
      targetIOSSdk: IOSSdk.iPhoneOS,
      target: Architecture.arm64,
      hasInstallName: false,
      optimizationLevel: OptimizationLevel.unspecified,
    ),
  ];

  for (final (
        :language,
        :linkMode,
        :targetIOSSdk,
        :target,
        :hasInstallName,
        :optimizationLevel,
      )
      in configurations) {
    final libName = OS.iOS.libraryFileName(name, linkMode);
    final installName = hasInstallName
        ? Uri.file('@executable_path/Frameworks/$libName')
        : null;
    test(
      'CBuilder $linkMode $language library $targetIOSSdk $target'
              ' ${installName ?? ''} $optimizationLevel'
          .trim(),
      () async {
        final tempUri = await tempDirForTest();
        final tempUri2 = await tempDirForTest();
        final sourceUri = switch (language) {
          .c => packageUri.resolve('test/cbuilder/testfiles/add/src/add.c'),
          .objectiveC => packageUri.resolve(
            'test/cbuilder/testfiles/add_objective_c/src/add.m',
          ),
          Language() => throw UnimplementedError(),
        };

        final buildInputBuilder = BuildInputBuilder()
          ..setupShared(
            packageName: name,
            packageRoot: tempUri,
            outputFile: tempUri.resolve('output.json'),
            outputDirectoryShared: tempUri2,
          )
          ..config.setupBuild(linkingEnabled: false)
          ..addExtension(
            CodeAssetExtension(
              targetOS: .iOS,
              targetArchitecture: target,
              linkModePreference: linkMode == DynamicLoadingBundled()
                  ? .dynamic
                  : .static,
              iOS: IOSCodeConfig(
                targetSdk: targetIOSSdk,
                targetVersion: flutteriOSHighestBestEffort,
              ),
              cCompiler: cCompiler,
            ),
          );

        final buildInput = buildInputBuilder.build();
        final buildOutput = BuildOutputBuilder();

        final cbuilder = CBuilder.library(
          name: name,
          assetName: name,
          sources: [sourceUri.toFilePath()],
          installName: installName,
          language: language,
          optimizationLevel: optimizationLevel,
          buildMode: .release,
        );
        await cbuilder.run(
          input: buildInput,
          output: buildOutput,
          logger: logger,
        );

        final libUri = buildInput.outputDirectory.resolve(libName);
        final objdumpResult = await runProcess(
          executable: Uri.file('objdump'),
          arguments: ['-t', libUri.path],
          logger: logger,
        );
        expect(objdumpResult.exitCode, 0);
        final machine = objdumpResult.stdout
            .split('\n')
            .firstWhere((e) => e.contains('file format'));
        expect(machine, contains(objdumpFileFormatIOS[target]));

        final otoolResult = await runProcess(
          executable: Uri.file('otool'),
          arguments: ['-l', libUri.path],
          logger: logger,
        );
        expect(otoolResult.exitCode, 0);
        // As of native_assets_cli 0.10.0, the min target OS version is
        // always being passed in.
        expect(otoolResult.stdout, isNot(contains('LC_VERSION_MIN_IPHONEOS')));
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
          final libInstallName = await runOtoolInstallName(libUri, libName);
          if (installName == null) {
            // If no install path is passed, we have an absolute path.
            final tempName = buildInput.outputDirectory.pathSegments.lastWhere(
              (e) => e != '',
            );
            final pathEnding = Uri.directory(
              tempName,
            ).resolve(libName).toFilePath();
            expect(Uri.file(libInstallName).isAbsolute, true);
            expect(libInstallName, contains(pathEnding));
            final targetInstallName = '@executable_path/Frameworks/$libName';
            await runProcess(
              executable: Uri.file('install_name_tool'),
              arguments: ['-id', targetInstallName, libUri.toFilePath()],
              logger: logger,
            );
            final libInstallName2 = await runOtoolInstallName(libUri, libName);
            expect(libInstallName2, targetInstallName);
          } else {
            expect(libInstallName, installName.toFilePath());
          }
        }
      },
    );
  }

  for (final iosVersion in [
    flutteriOSHighestBestEffort,
    flutteriOSHighestSupported,
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

  final buildInputBuilder = BuildInputBuilder()
    ..setupShared(
      packageName: name,
      packageRoot: tempUri,
      outputFile: tempUri.resolve('output.json'),
      outputDirectoryShared: tempUri2,
    )
    ..config.setupBuild(linkingEnabled: false)
    ..addExtension(
      CodeAssetExtension(
        targetOS: .iOS,
        targetArchitecture: targetArchitecture,
        linkModePreference: linkMode == DynamicLoadingBundled()
            ? .dynamic
            : .static,
        iOS: IOSCodeConfig(
          targetSdk: IOSSdk.iPhoneOS,
          targetVersion: targetIOSVersion,
        ),
        cCompiler: cCompiler,
      ),
    );

  final buildInput = buildInputBuilder.build();
  final buildOutput = BuildOutputBuilder();

  final cbuilder = CBuilder.library(
    name: name,
    assetName: name,
    sources: [addCUri.toFilePath()],
    buildMode: .release,
  );
  await cbuilder.run(input: buildInput, output: buildOutput, logger: logger);

  final libUri = buildInput.outputDirectory.resolve(
    OS.iOS.libraryFileName(name, linkMode),
  );
  return libUri;
}
