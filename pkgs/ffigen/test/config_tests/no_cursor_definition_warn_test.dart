// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/context.dart';
import 'package:ffigen/src/header_parser.dart' show parse;
import 'package:ffigen/src/strings.dart' as strings;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  var logString = '';
  group('no_cursor_definition_warn_test', () {
    setUpAll(() {
      final logArr = <String>[];
      final logger = logToArray(logArr, Level.WARNING);
      final config = testConfig('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Warn for no cursor definition.'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - '${absPath('test/header_parser_tests/opaque_dependencies.h')}'
${strings.structs}:
  ${strings.dependencyOnly}: ${strings.opaqueCompoundDependencies}
  ${strings.include}:
    - 'D'
    - 'E'
        ''', logger: logger);
      parse(Context(logger, config));
      logString = logArr.join('\n');
    });
    test('No warning for missing cursor definition.', () {
      expect(logString.contains('NoDefinitionStructInC'), true);
      expect(logString.contains('NoDefinitionStructInD'), true);
    });
  });
}
