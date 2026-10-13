// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isMacOS) return;

  for (final (os, sdk, architecture, version, target, minos) in [
    (
      OS.iOS,
      IOSSdk.iPhoneOS,
      Architecture.arm64,
      AppleVersion(16, minor: 4),
      '16.4',
      '16.4',
    ),
    (
      OS.iOS,
      IOSSdk.iPhoneOS,
      Architecture.arm64,
      AppleVersion(17, minor: 2, patch: 1),
      '17.2.1',
      '17.2.1',
    ),
    (
      OS.iOS,
      IOSSdk.iPhoneSimulator,
      Architecture.arm64,
      AppleVersion(16, minor: 4),
      '16.4',
      '16.4',
    ),
    (
      OS.iOS,
      IOSSdk.iPhoneSimulator,
      Architecture.x64,
      AppleVersion(17, minor: 2, patch: 1),
      '17.2.1',
      '17.2.1',
    ),
    (
      OS.macOS,
      null,
      Architecture.arm64,
      AppleVersion(14, minor: 4),
      '14.4',
      '14.4',
    ),
    (
      OS.macOS,
      null,
      Architecture.x64,
      AppleVersion(14, minor: 4, patch: 1),
      '14.4.1',
      '14.4.1',
    ),
    (OS.macOS, null, Architecture.arm64, AppleVersion(13), '13', '13.0'),
    (
      OS.iOS,
      IOSSdk.iPhoneOS,
      Architecture.arm64,
      AppleVersion(17),
      '17',
      '17.0',
    ),
    (
      OS.iOS,
      IOSSdk.iPhoneSimulator,
      Architecture.arm64,
      AppleVersion(17),
      '17',
      '17.0',
    ),
    (
      OS.macOS,
      null,
      Architecture.arm64,
      AppleVersion(14, patch: 1),
      '14.0.1',
      '14.0.1',
    ),
  ]) {
    test('$os $sdk $architecture preserves minos $version', () async {
      final tempUri = await tempDirForTest();
      final sharedUri = await tempDirForTest();
      final builder = BuildInputBuilder()
        ..setupShared(
          packageName: 'add',
          packageRoot: tempUri,
          outputFile: tempUri.resolve('output.json'),
          outputDirectoryShared: sharedUri,
        )
        ..config.setupBuild(linkingEnabled: false)
        ..addExtension(
          CodeAssetExtension(
            targetOS: os,
            targetArchitecture: architecture,
            linkModePreference: LinkModePreference.dynamic,
            cCompiler: cCompiler,
            iOS: os == OS.iOS
                ? IOSCodeConfig(targetSdk: sdk!, targetVersion2: version)
                : null,
            macOS: os == OS.macOS
                ? MacOSCodeConfig(targetVersion2: version)
                : null,
          ),
        );
      final input = builder.build();
      final messages = <String>[];
      await CBuilder.library(
        name: 'add',
        assetName: 'add',
        sources: [
          packageUri
              .resolve('test/cbuilder/testfiles/add/src/add.c')
              .toFilePath(),
        ],
      ).run(
        input: input,
        output: BuildOutputBuilder(),
        logger: createCapturingLogger(messages),
      );
      final file = input.outputDirectory.resolve(
        os.libraryFileName('add', DynamicLoadingBundled()),
      );
      final result = await Process.run('otool', ['-l', file.toFilePath()]);
      expect(result.exitCode, 0, reason: '${result.stderr}');
      expect(
        RegExp(r'\bminos (\S+)').firstMatch(result.stdout as String)?.group(1),
        minos,
      );
      final flag = os == OS.iOS ? '-mios-version-min' : '-mmacos-version-min';
      expect(messages.join('\n'), contains('$flag=$target'));
    });
  }

  for (final (os, version, target) in [
    (OS.iOS, AppleVersion(17, minor: 2, patch: 1), '17.2.1'),
    (OS.macOS, AppleVersion(14, minor: 4, patch: 1), '14.4.1'),
  ]) {
    test(
      '$os CLinker preserves minos $version from a static archive',
      () async {
        final tempUri = await tempDirForTest();
        final sharedUri = await tempDirForTest();
        final extension = CodeAssetExtension(
          targetOS: os,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
          iOS: os == OS.iOS
              ? IOSCodeConfig(
                  targetSdk: IOSSdk.iPhoneOS,
                  targetVersion2: version,
                )
              : null,
          macOS: os == OS.macOS
              ? MacOSCodeConfig(
                  targetVersion2: version,
                )
              : null,
        );
        final buildBuilder = BuildInputBuilder()
          ..setupShared(
            packageName: 'add',
            packageRoot: tempUri,
            outputFile: tempUri.resolve('build.json'),
            outputDirectoryShared: sharedUri,
          )
          ..config.setupBuild(linkingEnabled: true)
          ..addExtension(extension);
        final buildInput = buildBuilder.build();
        final messages = <String>[];
        final logger = createCapturingLogger(messages);
        await CBuilder.library(
          name: 'add',
          assetName: 'add',
          sources: [
            packageUri
                .resolve('test/cbuilder/testfiles/add/src/add.c')
                .toFilePath(),
          ],
        ).run(
          input: buildInput,
          output: BuildOutputBuilder(),
          linkModePreference: LinkModePreference.static,
          logger: logger,
        );
        final archive = buildInput.outputDirectory.resolve(
          os.libraryFileName('add', StaticLinking()),
        );
        final linkBuilder = LinkInputBuilder()
          ..setupShared(
            packageName: 'add',
            packageRoot: tempUri,
            outputFile: tempUri.resolve('link.json'),
            outputDirectoryShared: sharedUri,
          )
          ..setupLink(assets: [], recordedUsesFile: null, assetsFromLinking: [])
          ..addExtension(extension);
        final linkInput = linkBuilder.build();
        await CLinker.library(
          name: 'linked',
          assetName: 'linked',
          sources: [archive.toFilePath()],
        ).run(input: linkInput, output: LinkOutputBuilder(), logger: logger);
        final file = linkInput.outputDirectory.resolve(
          os.libraryFileName('linked', DynamicLoadingBundled()),
        );
        final result = await Process.run('otool', ['-l', file.toFilePath()]);
        expect(result.exitCode, 0, reason: '${result.stderr}');
        expect(
          RegExp(
            r'\bminos (\S+)',
          ).firstMatch(result.stdout as String)?.group(1),
          target,
        );
        final flag = os == OS.iOS ? '-mios-version-min' : '-mmacos-version-min';
        expect(
          messages.where((message) => message.contains('$flag=$target')),
          hasLength(2),
        );
      },
    );
  }
}
