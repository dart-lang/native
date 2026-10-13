// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  final packageUri = findPackageRoot('code_assets');
  final schemas = loadSchemas([
    packageUri.resolve('doc/schema/'),
    packageUri.resolve('../hooks/doc/schema/'),
  ]);
  for (final os in ['ios', 'macos']) {
    for (final hook in ['build', 'link']) {
      final fixtureOS = hook == 'link' ? 'macos' : os;
      final fixture = File.fromUri(
        packageUri.resolve('test/data/${hook}_input_$fixtureOS.json'),
      ).readAsStringSync();
      Map<String, Object?> input() {
        final json = jsonDecode(fixture) as Map<String, Object?>;
        final config = json['config']! as Map<String, Object?>;
        final extensions = config['extensions']! as Map<String, Object?>;
        final code = extensions['code_assets']! as Map<String, Object?>;
        if (hook == 'link' && os == 'ios') {
          code.remove('macos');
          code['target_os'] = 'ios';
          code['ios'] = <String, Object?>{
            'target_sdk': 'iphonesimulator',
            'target_version': 16,
          };
        }
        return json;
      }

      for (final party in ['hook', 'sdk']) {
        final schema =
            schemas[packageUri.resolve(
              'doc/schema/$party/${hook}_input.generated.schema.json',
            )]!;
        for (final version in [
          {'major': 16, 'minor': 0, 'patch': 0},
          {'major': 16, 'minor': 4, 'patch': 0},
          {'major': 17, 'minor': 2, 'patch': 1},
          {'major': 2147483647, 'minor': 2147483647, 'patch': 2147483647},
        ]) {
          test('$os $hook $party accepts deployment version $version', () {
            final json = input();
            final apple = appleConfig(json, os);
            apple['target_version'] = version['major']!;
            apple['target_version_v2'] = version;
            expect(schema.validate(json).isValid, isTrue);
          });
        }
        test('$os $hook $party accepts legacy integer-only input', () {
          final json = input();
          appleConfig(json, os).remove('target_version_v2');
          expect(schema.validate(json).isValid, isTrue);
        });
        test(
          '$os $hook $party requires the legacy major with a nested version',
          () {
            final json = input();
            appleConfig(json, os)
              ..['target_version_v2'] = {'major': 16, 'minor': 4, 'patch': 1}
              ..remove('target_version');
            expect(schema.validate(json).isValid, isFalse);
          },
        );
        for (final major in [-1, 2147483648, 2147483649, 4294967296]) {
          test('$os $hook $party rejects legacy major $major', () {
            final json = input();
            appleConfig(json, os)
              ..remove('target_version_v2')
              ..['target_version'] = major;
            expect(schema.validate(json).isValid, isFalse);
          });
        }
        for (final value in <Object?>[
          null,
          '',
          '16.4.1-beta.1',
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
          test('$os $hook $party rejects version ${jsonEncode(value)}', () {
            final json = input();
            appleConfig(json, os)['target_version_v2'] = value;
            expect(schema.validate(json).isValid, isFalse);
          });
        }
      }
    }
  }
}

Map<String, Object?> appleConfig(Map<String, Object?> json, String os) {
  final config = json['config']! as Map<String, Object?>;
  final extensions = config['extensions']! as Map<String, Object?>;
  final code = extensions['code_assets']! as Map<String, Object?>;
  return code[os]! as Map<String, Object?>;
}
