// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:code_assets/src/code_assets/config.dart';
import 'package:code_assets/src/code_assets/validation.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late Uri root;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('apple_version_');
    root = directory.uri;
  });
  tearDown(() async => directory.delete(recursive: true));
  for (final os in [OS.iOS, OS.macOS]) {
    for (final (major, minor, patch, expected) in [
      (16, null, null, '16'),
      (16, 0, 0, '16'),
      (16, 4, null, '16.4'),
      (17, 2, 1, '17.2.1'),
      (17, null, 1, '17.0.1'),
      (16, 10, 0, '16.10'),
    ]) {
      test('$os $expected round trips through build and link inputs', () {
        final extension = CodeAssetExtension(
          targetOS: os,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
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
        final build = BuildInputBuilder()
          ..setupShared(
            packageName: 'test',
            packageRoot: root,
            outputFile: root.resolve('output.json'),
            outputDirectoryShared: root,
          )
          ..addExtension(extension);
        final link = LinkInputBuilder()
          ..setupShared(
            packageName: 'test',
            packageRoot: root,
            outputFile: root.resolve('output.json'),
            outputDirectoryShared: root,
          )
          ..addExtension(extension);
        for (final config in [
          BuildInput(
            jsonDecode(jsonEncode(build.json)) as Map<String, Object?>,
          ).config,
          LinkInput(
            jsonDecode(jsonEncode(link.json)) as Map<String, Object?>,
          ).config,
        ]) {
          final apple = os == OS.iOS
              ? config.code.iOS.toSyntax().json
              : config.code.macOS.toSyntax().json;
          expect(apple, {
            if (os == OS.iOS) 'target_sdk': 'iphoneos',
            'target_version': major,
            'target_version_minor': ?minor,
            'target_version_patch': ?patch,
          });
          if (os == OS.iOS) {
            expect(config.code.iOS.targetVersion, major);
            expect(config.code.iOS.targetVersionMinor, minor ?? 0);
            expect(config.code.iOS.targetVersionPatch, patch ?? 0);
            expect(config.code.iOS.targetVersionString, expected);
          } else {
            expect(config.code.macOS.targetVersion, major);
            expect(config.code.macOS.targetVersionMinor, minor ?? 0);
            expect(config.code.macOS.targetVersionPatch, patch ?? 0);
            expect(config.code.macOS.targetVersionString, expected);
          }
        }
      });
    }

    for (final component in ['minor', 'patch']) {
      test('$os constructor rejects negative $component', () {
        expect(
          () => os == OS.iOS
              ? IOSCodeConfig(
                  targetSdk: IOSSdk.iPhoneOS,
                  targetVersion: 16,
                  targetVersionMinor: component == 'minor' ? -1 : null,
                  targetVersionPatch: component == 'patch' ? -1 : null,
                )
              : MacOSCodeConfig(
                  targetVersion: 16,
                  targetVersionMinor: component == 'minor' ? -1 : null,
                  targetVersionPatch: component == 'patch' ? -1 : null,
                ),
          throwsArgumentError,
        );
      });
      for (final value in [-1, '4', 4.5]) {
        test('$os reader rejects $component=$value', () {
          final input = BuildInput({
            'out_dir_shared': root.toFilePath(),
            'config': {
              'build_asset_types': ['code_assets/code'],
              'extensions': {
                'code_assets': {
                  'target_os': os.name,
                  os == OS.iOS ? 'ios' : 'macos': {
                    if (os == OS.iOS) 'target_sdk': 'iphoneos',
                    'target_version': 16,
                    'target_version_$component': value,
                  },
                },
              },
            },
          });
          expect(
            () => os == OS.iOS
                ? input.config.code.iOS.targetVersionString
                : input.config.code.macOS.targetVersionString,
            value is int ? throwsArgumentError : throwsFormatException,
          );
        });
        test('$os input validation rejects $component=$value', () async {
          final builder = BuildInputBuilder()
            ..setupShared(
              packageName: 'test',
              packageRoot: root,
              outputFile: root.resolve('output.json'),
              outputDirectoryShared: root,
            )
            ..config.setupBuild(linkingEnabled: false)
            ..addExtension(
              CodeAssetExtension(
                targetOS: os,
                targetArchitecture: Architecture.arm64,
                linkModePreference: LinkModePreference.dynamic,
                iOS: os == OS.iOS
                    ? IOSCodeConfig(
                        targetSdk: IOSSdk.iPhoneOS,
                        targetVersion: 16,
                      )
                    : null,
                macOS: os == OS.macOS
                    ? MacOSCodeConfig(targetVersion: 16)
                    : null,
              ),
            );
          final json =
              jsonDecode(jsonEncode(builder.json)) as Map<String, Object?>;
          final config = json['config']! as Map<String, Object?>;
          final extensions = config['extensions']! as Map<String, Object?>;
          final code = extensions['code_assets']! as Map<String, Object?>;
          final apple =
              code[os == OS.iOS ? 'ios' : 'macos']! as Map<String, Object?>;
          apple['target_version_$component'] = value;
          expect(
            await validateCodeAssetBuildInput(BuildInput(json)),
            isNotEmpty,
          );
          json['assets'] = <Object?>[];
          expect(await validateCodeAssetLinkInput(LinkInput(json)), isNotEmpty);
        });
      }
    }
  }

  for (final os in [OS.iOS, OS.macOS]) {
    test('$os minor and patch changes invalidate the input cache', () {
      final checksums = <String>{};
      for (final (minor, patch) in [(4, 0), (5, 0), (4, 1)]) {
        final builder = BuildInputBuilder()
          ..addExtension(
            CodeAssetExtension(
              targetOS: os,
              targetArchitecture: Architecture.arm64,
              linkModePreference: LinkModePreference.dynamic,
              iOS: os == OS.iOS
                  ? IOSCodeConfig(
                      targetSdk: IOSSdk.iPhoneOS,
                      targetVersion: 16,
                      targetVersionMinor: minor,
                      targetVersionPatch: patch,
                    )
                  : null,
              macOS: os == OS.macOS
                  ? MacOSCodeConfig(
                      targetVersion: 16,
                      targetVersionMinor: minor,
                      targetVersionPatch: patch,
                    )
                  : null,
            ),
          );
        checksums.add(builder.computeChecksum());
      }
      expect(checksums, hasLength(3));
    });
  }

  for (final os in [OS.iOS, OS.macOS]) {
    test('testCodeBuildHook carries full $os version', () async {
      await testCodeBuildHook(
        targetOS: os,
        targetIOSVersion: 17,
        targetIOSVersionMinor: 2,
        targetIOSVersionPatch: 1,
        targetMacOSVersion: 14,
        targetMacOSVersionMinor: 4,
        targetMacOSVersionPatch: 1,
        mainMethod: (args) async => build(args, (input, output) async {}),
        check: (input, output) {
          expect(
            os == OS.iOS
                ? input.config.code.iOS.targetVersionString
                : input.config.code.macOS.targetVersionString,
            os == OS.iOS ? '17.2.1' : '14.4.1',
          );
        },
      );
    });
  }
}
