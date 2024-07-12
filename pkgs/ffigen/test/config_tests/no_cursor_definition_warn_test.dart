// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual, expected;

void main() {
  var logString = '';
  group('no_cursor_definition_warn_test', () {
    setUpAll(() {
      final logArr = <String>[];
      logToArray(logArr, Level.WARNING);
      final config = testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Warn for no cursor definition.'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/opaque_dependencies.h'
${strings.structs}:
  ${strings.dependencyOnly}: ${strings.opaqueCompoundDependencies}
  ${strings.include}:
    - 'D'
    - 'E'
        ''');
      parse(config);
      logString = logArr.join('\n');
    });
    test('No warning for missing cursor definition.', () {
      // No warning since C is not included directly.
      expect(logString.contains('NoDefinitionStructInC'), false);
      // Warning since D is included.
      expect(logString.contains('NoDefinitionStructInD'), true);
    });
  });
}
