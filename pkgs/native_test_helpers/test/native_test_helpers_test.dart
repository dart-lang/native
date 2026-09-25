// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('convertYamlMapToJsonMap converts maps, lists, and primitives', () {
    final yaml =
        loadYaml('''
string: hello
number: 42
list:
  - a
  - b
nested:
  key: value
''')
            as YamlMap;

    final json = convertYamlMapToJsonMap(yaml);
    expect(json, {
      'string': 'hello',
      'number': 42,
      'list': ['a', 'b'],
      'nested': {'key': 'value'},
    });
  });

  test('convertYamlMapToJsonMap throws on non-string key', () {
    final yaml = loadYaml('{123: value}') as YamlMap;
    expect(() => convertYamlMapToJsonMap(yaml), throwsArgumentError);
  });

  test('findPackageRoot finds package or throws StateError', () {
    final root = findPackageRoot('native_test_helpers');
    expect(root.path, contains('native_test_helpers'));
    expect(() => findPackageRoot('non_existent_package_xyz'), throwsStateError);
  });

  test('skipLocal returns reason when condition is true locally', () {
    expect(skipLocal(false, 'skip reason'), isNull);
  });
}
