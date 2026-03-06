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
import '../utils/test_configuration_generator.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const name = 'add';

  final configurations =
      TestConfigurationGenerator(
        dimensions: {
          Architecture: [Architecture.arm64, Architecture.x64],
          IOSSdk: [IOSSdk.iPhoneOS, IOSSdk.iPhoneSimulator],
          IOSVersion: [
            IOSVersion.flutterHighestBestEffort,
            IOSVersion.flutterHighestSupported,
          ],
          LinkMode: [DynamicLoadingBundled(), StaticLinking()],
          Language: [Language.c, Language.objectiveC],
          OptimizationLevel: OptimizationLevel.values,
        },
        interactionGroups: [
          {Architecture, IOSSdk},
          {IOSSdk, IOSVersion},
          {Architecture, LinkMode},
          {Architecture, Language},
          {Language, LinkMode},
          {IOSSdk, LinkMode},
          {IOSVersion, LinkMode},
          {Language, IOSVersion},
        ],
        isValid: (config) {
          if (config.get<IOSSdk>() == IOSSdk.iPhoneOS &&
              config.get<Architecture>() == Architecture.x64) {
            return false;
          }
          return true;
        },
      ).generateAndValidate(
        tableUri: packageUri.resolve(
          'test/cbuilder/cbuilder_cross_ios_test.md',
        ),
      );

  for (final config in configurations) {
    final architecture = config.get<Architecture>();
    final linkMode = config.get<LinkMode>();
    final language = config.get<Language>();
    final targetIOSSdk = config.get<IOSSdk>();
    final iOSVersion = config.get<IOSVersion>();
    final optimizationLevel = config.get<OptimizationLevel>();

    final hasInstallName =
        linkMode == DynamicLoadingBundled() &&
        architecture == Architecture.arm64;

    final libName = OS.iOS.libraryFileName(name, linkMode);
    final installName = hasInstallName
        ? Uri.file('@executable_path/Frameworks/$libName')
        : null;
    test(
      'CBuilder $targetIOSSdk $architecture $iOSVersion $linkMode $language'
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
              targetArchitecture: architecture,
              linkModePreference: linkMode == DynamicLoadingBundled()
                  ? .dynamic
                  : .static,
              iOS: IOSCodeConfig(
                targetSdk: targetIOSSdk,
                targetVersion: iOSVersion.value,
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
        expect(machine, contains(objdumpFileFormatIOS[architecture]));

        final otoolResult = await runProcess(
          executable: Uri.file('otool'),
          arguments: ['-l', libUri.path],
          logger: logger,
        );
        expect(otoolResult.exitCode, 0);
        expect(otoolResult.stdout, contains('minos $iOSVersion.0'));
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
}
