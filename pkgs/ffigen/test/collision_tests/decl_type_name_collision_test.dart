// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual;
void main() {
  group('decl_type_name_collision test', () {
    setUpAll(() {
      actual = parser.parse(
        testContext(
          testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Decl type name collision test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - '${absPath('test/collision_tests/decl_type_name_collision.h')}'
        '''),
        ),
      );
    });

    test('Expected bindings', () {
      final context = testContext();
      matchLibraryWithExpected(
        context,
        actual,
        'decl_type_name_collision_test_output.dart',
        [
          'test',
          'collision_tests',
          'expected_bindings',
          '_expected_decl_type_name_collision_bindings.dart',
        ],
      );
    });
  });
}
