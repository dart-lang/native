// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// These tests deliberately exercise the legacy API and wire format.
// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:code_assets/src/code_assets/apple_version.dart';
import 'package:code_assets/src/code_assets/config.dart';
import 'package:code_assets/src/code_assets/syntax.g.dart';
import 'package:code_assets/src/code_assets/validation.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  test('AppleVersion compares major, minor, and patch numerically', () {
    final values = [
      AppleVersion(14, minor: 10),
      AppleVersion(13, minor: 99),
      AppleVersion(14, minor: 9, patch: 1),
      AppleVersion(14, minor: 9),
    ];
    values.sort();
    expect(values, [
      AppleVersion(13, minor: 99),
      AppleVersion(14, minor: 9),
      AppleVersion(14, minor: 9, patch: 1),
      AppleVersion(14, minor: 10),
    ]);
    expect(values[0].compareTo(values[1]), lessThan(0));
    expect(values[1].compareTo(values[0]), greaterThan(0));
    expect(values[1].compareTo(AppleVersion(14, minor: 9)), 0);
  });
  test('AppleVersion relational operators compare every component', () {
    final values = [
      AppleVersion(13, minor: 99, patch: 99),
      AppleVersion(14),
      AppleVersion(14, minor: 9),
      AppleVersion(14, minor: 9, patch: 1),
      AppleVersion(14, minor: 10),
    ];
    for (var i = 0; i < values.length; i++) {
      for (var j = 0; j < values.length; j++) {
        expect(values[i] < values[j], i < j);
        expect(values[i] <= values[j], i <= j);
        expect(values[i] > values[j], i > j);
        expect(values[i] >= values[j], i >= j);
      }
      final equal = AppleVersion(
        values[i].major,
        minor: values[i].minor,
        patch: values[i].patch,
      );
      expect(values[i] < equal, isFalse);
      expect(values[i] <= equal, isTrue);
      expect(values[i] > equal, isFalse);
      expect(values[i] >= equal, isTrue);
    }
  });

  test('AppleVersion syntax fields are read lazily', () {
    final version = AppleVersionSyntaxExtension.fromSyntax(
      AppleVersionSyntax.fromJson({'major': 17}),
    );
    expect(version.major, 17);
    expect(() => version.minor, throwsFormatException);
    expect(() => version.patch, throwsFormatException);
  });

  test('AppleVersion defaults, equality, hashing, and diagnostic string', () {
    final version = AppleVersion(17);
    expect(version.major, 17);
    expect(version.minor, 0);
    expect(version.patch, 0);
    expect(version, AppleVersion(17, minor: 0, patch: 0));
    expect(version.hashCode, AppleVersion(17).hashCode);
    expect(version, isNot(AppleVersion(18)));
    expect(version, isNot(AppleVersion(17, minor: 1)));
    expect(version, isNot(AppleVersion(17, patch: 1)));
    expect(version, isNot('17.0.0'));
    expect(version.toString(), 'AppleVersion(17, minor: 0, patch: 0)');
  });
  for (final component in ['major', 'minor', 'patch']) {
    for (final value in [-1, 2147483648, 2147483649, 4294967296]) {
      test('AppleVersion rejects $component $value', () {
        expect(
          () => AppleVersion(
            component == 'major' ? value : 17,
            minor: component == 'minor' ? value : 0,
            patch: component == 'patch' ? value : 0,
          ),
          throwsA(
            isA<ArgumentError>()
                .having((error) => error.name, 'name', component)
                .having((error) => error.invalidValue, 'value', value),
          ),
        );
      });
    }
  }

  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('apple_version_');
  });
  tearDown(() async => directory.delete(recursive: true));
  for (final os in [OS.iOS, OS.macOS]) {
    CodeAssetExtension extension({int? major, AppleVersion? version}) =>
        CodeAssetExtension(
          targetOS: os,
          targetArchitecture: Architecture.arm64,
          linkModePreference: LinkModePreference.dynamic,
          iOS: os == OS.iOS
              ? IOSCodeConfig(
                  targetSdk: IOSSdk.iPhoneOS,
                  targetVersion: major,
                  deploymentVersion: version,
                )
              : null,
          macOS: os == OS.macOS
              ? MacOSCodeConfig(
                  targetVersion: major,
                  deploymentVersion: version,
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

    AppleVersion version(HookConfig config) => os == OS.iOS
        ? config.code.iOS.deploymentVersion
        : config.code.macOS.deploymentVersion;

    for (final value in [
      AppleVersion(0),
      AppleVersion(16),
      AppleVersion(16, minor: 4),
      AppleVersion(17, minor: 2, patch: 1),
      AppleVersion(17, patch: 1),
      AppleVersion(16, minor: 10),
      AppleVersion(2147483647),
      AppleVersion(16, minor: 2147483647),
      AppleVersion(16, minor: 4, patch: 2147483647),
    ]) {
      test('$os $value round trips through build and link inputs', () {
        final json = builder(extension(version: value)).json;
        final major = value.major;
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
            'deployment_version': {
              'major': value.major,
              'minor': value.minor,
              'patch': value.patch,
            },
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
    test('$os syntax conversion preserves unknown fields', () {
      final json = builder(extension(version: AppleVersion(16, minor: 4))).json;
      apple(json)['future_field'] = {'enabled': true};
      for (final config in [BuildInput(json).config, LinkInput(json).config]) {
        final syntax = os == OS.iOS
            ? config.code.iOS.toSyntax().json
            : config.code.macOS.toSyntax().json;
        expect(syntax, apple(json));
        expect(syntax['future_field'], {'enabled': true});
      }
    });
    test('$os legacy constructor populates both fields', () {
      final json = builder(extension(major: 16)).json;
      expect(apple(json)['target_version'], 16);
      expect(apple(json)['deployment_version'], {
        'major': 16,
        'minor': 0,
        'patch': 0,
      });
      expect(version(BuildInput(json).config), AppleVersion(16));
    });
    test(
      '$os old SDK input falls back to integer version without changing JSON',
      () async {
        final json = builder(extension(version: AppleVersion(16))).json;
        apple(json).remove('deployment_version');
        for (final config in [
          BuildInput(json).config,
          LinkInput(json).config,
        ]) {
          expect(version(config), AppleVersion(16));
          final syntax = os == OS.iOS
              ? config.code.iOS.toSyntax().json
              : config.code.macOS.toSyntax().json;
          expect(syntax.containsKey('deployment_version'), isFalse);
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
      expect(
        () => extension(major: 16, version: AppleVersion(16, minor: 4)),
        throwsArgumentError,
      );
    });
    for (final major in [-1, 2147483648, 2147483649, 4294967296]) {
      test('$os legacy constructor rejects version $major', () {
        expect(
          () => extension(major: major),
          throwsA(
            isA<ArgumentError>()
                .having((error) => error.name, 'name', 'major')
                .having((error) => error.invalidValue, 'value', major),
          ),
        );
      });
    }
    for (final value in <Object?>[
      '16.4',
      16,
      16.4,
      true,
      <Object?>[],
      <String, Object?>{},
      {'major': 16},
      {'major': 16, 'minor': 4},
      for (final component in ['major', 'minor', 'patch'])
        for (final invalid in <Object?>[
          -1,
          2147483648,
          2147483649,
          4294967296,
          '4',
          4.5,
          true,
          null,
        ])
          {'major': 16, 'minor': 4, 'patch': 1, component: invalid},
    ]) {
      test(
        '$os reader and build/link validation reject ${jsonEncode(value)}',
        () async {
          final json = builder(
            extension(version: AppleVersion(16, minor: 4)),
          ).json;
          apple(json)['deployment_version'] = value;
          expect(() {
            final value = version(BuildInput(json).config);
            // Read every lazy field so malformed minor/patch values also throw.
            return [value.major, value.minor, value.patch];
          }, throwsFormatException);
          expect(
            await validateCodeAssetBuildInput(BuildInput(json)),
            isNotEmpty,
          );
          json['assets'] = <Object?>[];
          expect(await validateCodeAssetLinkInput(LinkInput(json)), isNotEmpty);
        },
      );
    }
    for (final major in [-1, 2147483648, 2147483649, 4294967296]) {
      test('$os reader and validation reject legacy $major', () async {
        final json = builder(extension(version: AppleVersion(16))).json;
        apple(json)
          ..remove('deployment_version')
          ..['target_version'] = major;
        expect(() => version(BuildInput(json).config), throwsFormatException);
        expect(await validateCodeAssetBuildInput(BuildInput(json)), isNotEmpty);
        json['assets'] = <Object?>[];
        expect(await validateCodeAssetLinkInput(LinkInput(json)), isNotEmpty);
      });
    }
    test('$os nested deployment version takes precedence', () async {
      final json = builder(extension(version: AppleVersion(16, minor: 4))).json;
      apple(json)['target_version'] = 17;
      expect(version(BuildInput(json).config), AppleVersion(16, minor: 4));
      expect(
        os == OS.iOS
            ? BuildInput(json).config.code.iOS.targetVersion
            : BuildInput(json).config.code.macOS.targetVersion,
        16,
      );
      expect(await validateCodeAssetBuildInput(BuildInput(json)), isEmpty);
      json['assets'] = <Object?>[];
      expect(await validateCodeAssetLinkInput(LinkInput(json)), isEmpty);
    });
    test(
      '$os optional null deployment version falls back to the legacy major',
      () {
        final json = builder(extension(major: 16)).json;
        apple(json)['deployment_version'] = null;
        expect(version(BuildInput(json).config), AppleVersion(16));
      },
    );
    test('$os getters support nested-only input '
        'but current protocol requires legacy major', () async {
      final json = builder(extension(version: AppleVersion(16, minor: 4))).json;
      apple(json).remove('target_version');
      final syntax = os == OS.iOS
          ? BuildInput(json).config.code.iOS.toSyntax().json
          : BuildInput(json).config.code.macOS.toSyntax().json;
      expect(syntax.containsKey('target_version'), isFalse);
      expect(version(BuildInput(json).config), AppleVersion(16, minor: 4));
      expect(
        os == OS.iOS
            ? BuildInput(json).config.code.iOS.targetVersion
            : BuildInput(json).config.code.macOS.targetVersion,
        16,
      );
      expect(await validateCodeAssetBuildInput(BuildInput(json)), isNotEmpty);
      json['assets'] = <Object?>[];
      expect(version(LinkInput(json).config), AppleVersion(16, minor: 4));
      expect(await validateCodeAssetLinkInput(LinkInput(json)), isNotEmpty);
    });
    test('$os minor and patch changes invalidate the input cache', () {
      final checksums = {
        for (final value in [
          AppleVersion(16, minor: 4),
          AppleVersion(16, minor: 5),
          AppleVersion(16, minor: 4, patch: 1),
        ])
          builder(extension(version: value)).computeChecksum(),
      };
      expect(checksums, hasLength(3));
    });
    test('$os omitted and explicit zero components have the same checksum', () {
      expect(
        builder(extension(version: AppleVersion(16))).computeChecksum(),
        builder(
          extension(version: AppleVersion(16, minor: 0, patch: 0)),
        ).computeChecksum(),
      );
    });
    test('$os testing helper retains the default deployment version', () async {
      await testCodeBuildHook(
        targetOS: os,
        mainMethod: (args) => build(args, (input, output) async {}),
        check: (input, output) =>
            expect(version(input.config), AppleVersion(os == OS.iOS ? 17 : 13)),
      );
    });
    test('$os testing helper forwards the full version', () async {
      await testCodeBuildHook(
        targetOS: os,
        iOSDeploymentVersion: os == OS.iOS
            ? AppleVersion(17, minor: 2, patch: 1)
            : null,
        macOSDeploymentVersion: os == OS.macOS
            ? AppleVersion(14, minor: 4, patch: 1)
            : null,
        mainMethod: (args) => build(args, (input, output) async {}),
        check: (input, output) => expect(
          version(input.config),
          os == OS.iOS
              ? AppleVersion(17, minor: 2, patch: 1)
              : AppleVersion(14, minor: 4, patch: 1),
        ),
      );
    });
    test('$os testing helper rejects both version arguments', () async {
      await expectLater(
        testCodeBuildHook(
          targetOS: os,
          targetIOSVersion: os == OS.iOS ? 17 : null,
          iOSDeploymentVersion: os == OS.iOS
              ? AppleVersion(17, minor: 2, patch: 1)
              : null,
          targetMacOSVersion: os == OS.macOS ? 14 : null,
          macOSDeploymentVersion: os == OS.macOS
              ? AppleVersion(14, minor: 4, patch: 1)
              : null,
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
            expect(version(input.config), AppleVersion(os == OS.iOS ? 17 : 14)),
      );
    });
  }
}
