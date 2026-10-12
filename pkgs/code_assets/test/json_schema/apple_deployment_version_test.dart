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
          code['ios'] = {'target_sdk': 'iphonesimulator', 'target_version': 16};
        }
        return json;
      }

      for (final party in ['hook', 'sdk']) {
        final schema =
            schemas[packageUri.resolve(
              'doc/schema/$party/${hook}_input.generated.schema.json',
            )]!;
        for (final version in ['16', '16.4', '17.2.1']) {
          test('$os $hook $party accepts deployment version $version', () {
            final json = input();
            final apple = appleConfig(json, os);
            apple['target_version'] = int.parse(version.split('.').first);
            apple['target_version_string'] = version;
            expect(schema.validate(json).isValid, isTrue);
          });
        }
        test('$os $hook $party accepts legacy integer-only input', () {
          expect(schema.validate(input()).isValid, isTrue);
        });
        for (final value in <Object>[
          '',
          '-1',
          '16.',
          '16..4',
          'v16.4',
          ' 16.4',
          '16.4 ',
          '16.4.1-beta.1',
          '16.4.1+build.1',
          '16.4.1.2',
          16,
          16.4,
          true,
        ]) {
          test('$os $hook $party rejects version ${jsonEncode(value)}', () {
            final json = input();
            appleConfig(json, os)['target_version_string'] = value;
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
