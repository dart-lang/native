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

  for (final (os, sdk, architecture, major, minor, patch) in [
    (OS.iOS, IOSSdk.iPhoneOS, Architecture.arm64, 16, 4, 0),
    (OS.iOS, IOSSdk.iPhoneOS, Architecture.arm64, 17, 2, 1),
    (OS.iOS, IOSSdk.iPhoneSimulator, Architecture.arm64, 16, 4, 0),
    (OS.iOS, IOSSdk.iPhoneSimulator, Architecture.x64, 17, 2, 1),
    (OS.macOS, null, Architecture.arm64, 14, 4, 0),
    (OS.macOS, null, Architecture.x64, 14, 4, 1),
    (OS.macOS, null, Architecture.arm64, 13, 0, 0),
  ]) {
    final version = patch == 0 ? '$major.$minor' : '$major.$minor.$patch';
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
                ? IOSCodeConfig(targetSdk: sdk!, targetVersion: major)
                : null,
            macOS: os == OS.macOS
                ? MacOSCodeConfig(targetVersion: major)
                : null,
          ),
        );
      final input = builder.build();
      final config = input.json['config']! as Map<String, Object?>;
      final extensions = config['extensions']! as Map<String, Object?>;
      final code = extensions['code_assets']! as Map<String, Object?>;
      final apple =
          code[os == OS.iOS ? 'ios' : 'macos']! as Map<String, Object?>;
      if (minor != 0 || patch != 0) {
        apple['target_version_minor'] = minor;
        apple['target_version_patch'] = patch;
      }

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
        version,
      );
      if (minor != 0 || patch != 0) {
        final flag = os == OS.iOS ? '-mios-version-min' : '-mmacos-version-min';
        expect(messages.join('\n'), contains('$flag=$version'));
      }
    });
  }

  for (final (os, major, minor, patch) in [
    (OS.iOS, 17, 2, 1),
    (OS.macOS, 14, 4, 1),
  ]) {
    final version = '$major.$minor.$patch';
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
                  targetVersion: major,
                  targetVersionMinor: minor,
                  targetVersionPatch: patch,
                )
              : null,
          macOS: os == OS.macOS
              ? MacOSCodeConfig(
                  targetVersion: major,
                  targetVersionMinor: minor,
                  targetVersionPatch: patch,
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
          version,
        );
        final flag = os == OS.iOS ? '-mios-version-min' : '-mmacos-version-min';
        expect(
          messages.where((message) => message.contains('$flag=$version')),
          hasLength(2),
        );
      },
    );
  }
}
