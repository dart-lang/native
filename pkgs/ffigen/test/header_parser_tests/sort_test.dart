// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:test/test.dart';

import '../test_utils.dart';

late Library actual;

void main() {
  group('sort_test', () {
    setUpAll(() {
      logWarnings();
      actual = parser.parse(Config(
        output: Uri.file('unused'),
        entryPoints: [Uri.file('test/header_parser_tests/sort.h')],
        structDecl: DeclarationFilters.includeAll,
        unionDecl: DeclarationFilters.includeAll,
        typedefs: DeclarationFilters.includeAll,
        includeUnusedTypedefs: true,
        sort: true,
      ));
    });
    test('Expected Bindings', () {
      matchLibraryWithExpected(actual, 'header_parser_sort_test_output.dart', [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_sort_bindings.dart',
      ]);
    });
  });
}
