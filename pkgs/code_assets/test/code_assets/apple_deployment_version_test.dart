// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// These tests deliberately exercise the legacy API and wire format.
// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:code_assets/src/code_assets/config.dart';
import 'package:code_assets/src/code_assets/validation.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('apple_version_');
  });
  tearDown(() async => directory.delete(recursive: true));
  for (final os in [OS.iOS, OS.macOS]) {
    CodeAssetExtension extension({int? major, String? version}) =>
        CodeAssetExtension(
          targetOS: os,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
          iOS: os == OS.iOS
              ? IOSCodeConfig(
                  targetSdk: IOSSdk.iPhoneOS,
                  targetVersion: major,
                  targetVersionString: version,
                )
              : null,
          macOS: os == OS.macOS
              ? MacOSCodeConfig(
                  targetVersion: major,
                  targetVersionString: version,
                )
              : null,
        );
    BuildInputBuilder builder(CodeAssetExtension config) => BuildInputBuilder()
      ..setupShared(
        packageName: 'test',
        packageRoot: directory.uri,
        outputFile: directory.uri.resolve('output.json'),
        outputDirectoryShared: directory.uri,
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(config);
    Map<String, Object?> apple(Map<String, Object?> json) {
      final config = json['config']! as Map<String, Object?>;
      final extensions = config['extensions']! as Map<String, Object?>;
      final code = extensions['code_assets']! as Map<String, Object?>;
      return code[os == OS.iOS ? 'ios' : 'macos']! as Map<String, Object?>;
    }

    String version(HookConfig config) => os == OS.iOS
        ? config.code.iOS.targetVersionString
        : config.code.macOS.targetVersionString;

    for (final value in [
      '16',
      '16.0',
      '16.4',
      '17.2.1',
      '17.0.1',
      '16.10',
      '16.4.0',
    ]) {
      test('$os $value round trips through build and link inputs', () {
        final json = builder(extension(version: value)).json;
        final major = int.parse(value.split('.').first);
        for (final config in [
          BuildInput(
            jsonDecode(jsonEncode(json)) as Map<String, Object?>,
          ).config,
          LinkInput(
            jsonDecode(jsonEncode(json)) as Map<String, Object?>,
          ).config,
        ]) {
          final syntax = os == OS.iOS
              ? config.code.iOS.toSyntax().json
              : config.code.macOS.toSyntax().json;
          expect(syntax, {
            if (os == OS.iOS) 'target_sdk': 'iphoneos',
            'target_version': major,
            'target_version_string': value,
          });
          expect(version(config), value);
          expect(
            os == OS.iOS
                ? config.code.iOS.targetVersion
                : config.code.macOS.targetVersion,
            major,
          );
        }
      });
    }
    test('$os legacy constructor populates both fields', () {
      final json = builder(extension(major: 16)).json;
      expect(apple(json)['target_version'], 16);
      expect(apple(json)['target_version_string'], '16');
      expect(version(BuildInput(json).config), '16');
    });
    test(
      '$os old SDK input falls back to integer version without changing JSON',
      () async {
        final json = builder(extension(version: '16')).json;
        apple(json).remove('target_version_string');
        for (final config in [
          BuildInput(json).config,
          LinkInput(json).config,
        ]) {
          expect(version(config), '16');
          final syntax = os == OS.iOS
              ? config.code.iOS.toSyntax().json
              : config.code.macOS.toSyntax().json;
          expect(syntax.containsKey('target_version_string'), isFalse);
        }
        expect(await validateCodeAssetBuildInput(BuildInput(json)), isEmpty);
        json['assets'] = <Object?>[];
        expect(await validateCodeAssetLinkInput(LinkInput(json)), isEmpty);
      },
    );
    test('$os constructor rejects neither version', () {
      expect(extension, throwsArgumentError);
    });
    test('$os constructor rejects both versions', () {
      expect(() => extension(major: 16, version: '16.4'), throwsArgumentError);
    });
    test('$os legacy constructor rejects a negative version', () {
      expect(() => extension(major: -1), throwsArgumentError);
    });
    for (final value in [
      '',
      '-1',
      '16.',
      '16..4',
      'v16.4',
      ' 16.4',
      '16.4 ',
      '16.4\n',
      '16.4.1-beta.1',
      '16.4.1+build.1',
      '16.4.1.2',
    ]) {
      test('$os constructor rejects invalid version ${jsonEncode(value)}', () {
        expect(() => extension(version: value), throwsArgumentError);
      });
    }
    for (final value in <Object>[
      '',
      '-1',
      '16.',
      '16..4',
      'v16.4',
      ' 16.4',
      '16.4 ',
      '16.4\n',
      '16.4.1-beta.1',
      '16.4.1+build.1',
      '16.4.1.2',
      16,
      16.4,
      true,
    ]) {
      test(
        '$os reader and build/link validation reject ${jsonEncode(value)}',
        () async {
          final json = builder(extension(version: '16.4')).json;
          apple(json)['target_version_string'] = value;
          expect(() => version(BuildInput(json).config), throwsFormatException);
          expect(
            await validateCodeAssetBuildInput(BuildInput(json)),
            isNotEmpty,
          );
          json['assets'] = <Object?>[];
          expect(await validateCodeAssetLinkInput(LinkInput(json)), isNotEmpty);
        },
      );
    }
    test('$os reader and validation reject negative legacy input', () async {
      final json = builder(extension(version: '16')).json;
      apple(json)
        ..remove('target_version_string')
        ..['target_version'] = -1;
      expect(() => version(BuildInput(json).config), throwsFormatException);
      expect(await validateCodeAssetBuildInput(BuildInput(json)), isNotEmpty);
      json['assets'] = <Object?>[];
      expect(await validateCodeAssetLinkInput(LinkInput(json)), isNotEmpty);
    });
    test(
      '$os reader and validation reject conflicting major versions',
      () async {
        final json = builder(extension(version: '16.4')).json;
        apple(json)['target_version'] = 17;
        expect(() => version(BuildInput(json).config), throwsFormatException);
        expect(await validateCodeAssetBuildInput(BuildInput(json)), isNotEmpty);
        json['assets'] = <Object?>[];
        expect(await validateCodeAssetLinkInput(LinkInput(json)), isNotEmpty);
      },
    );
    test('$os minor and patch changes invalidate the input cache', () {
      final checksums = {
        for (final value in ['16.4', '16.5', '16.4.1'])
          builder(extension(version: value)).computeChecksum(),
      };
      expect(checksums, hasLength(3));
    });
    test('$os testing helper forwards the full version', () async {
      await testCodeBuildHook(
        targetOS: os,
        targetIOSVersionString: os == OS.iOS ? '17.2.1' : null,
        targetMacOSVersionString: os == OS.macOS ? '14.4.1' : null,
        mainMethod: (args) => build(args, (input, output) async {}),
        check: (input, output) =>
            expect(version(input.config), os == OS.iOS ? '17.2.1' : '14.4.1'),
      );
    });
    test('$os testing helper rejects both version arguments', () async {
      await expectLater(
        testCodeBuildHook(
          targetOS: os,
          targetIOSVersion: os == OS.iOS ? 17 : null,
          targetIOSVersionString: os == OS.iOS ? '17.2.1' : null,
          targetMacOSVersion: os == OS.macOS ? 14 : null,
          targetMacOSVersionString: os == OS.macOS ? '14.4.1' : null,
          mainMethod: (args) => build(args, (input, output) async {}),
          check: (input, output) {},
        ),
        throwsArgumentError,
      );
    });
    test('$os testing helper preserves integer callers', () async {
      await testCodeBuildHook(
        targetOS: os,
        targetIOSVersion: os == OS.iOS ? 17 : null,
        targetMacOSVersion: os == OS.macOS ? 14 : null,
        mainMethod: (args) => build(args, (input, output) async {}),
        check: (input, output) =>
            expect(version(input.config), os == OS.iOS ? '17' : '14'),
      );
    });
  }
}
