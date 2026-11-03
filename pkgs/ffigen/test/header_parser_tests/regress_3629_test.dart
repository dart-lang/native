// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual;
void main() {
  group('regress_3629_test', () {
    setUpAll(() {
      actual = parser.parse(
        testContext(
          testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'https://github.com/dart-lang/native/issues/3629'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - '${absPath('test/header_parser_tests/regress_3629.h')}'
        '''),
        ),
      );
    });

    test('Expected bindings', () async {
      final context = testContext();
      await matchLibraryWithExpected(
        context,
        actual,
        'header_parser_regress_3629_test_output.dart',
        [
          'test',
          'header_parser_tests',
          'expected_bindings',
          '_expected_regress_3629_bindings.dart',
        ],
      );
    });
  });
}
