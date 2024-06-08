// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual;
void main() {
  group('enum_int_mimic', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      actual = parser.parse(
        testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Enum int mimic test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/enum_int_mimic.h'
  ${strings.includeDirectives}:
    - '**enum_int_mimic.h'
        '''),
      );
    });

    test('Expected bindings', () {
      matchLibraryWithExpected(
          actual, 'header_parser_enum_int_mimic_test_output.dart', [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_enum_int_mimic_bindings.dart'
      ]);
    });
  });
}
