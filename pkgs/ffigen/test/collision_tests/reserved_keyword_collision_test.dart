// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('reserved_keyword_collision_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
    });
    test('reserved keyword collision', () {
      final library = parser.parse(Config(
        output: Uri.file('unused'),
        entryPoints: [
          Uri.file('test/collision_tests/reserved_keyword_collision.h')
        ],
        structDecl: DeclarationFilters.includeAll,
        unionDecl: DeclarationFilters.includeAll,
        enumClassDecl: DeclarationFilters.includeAll,
        functionDecl: DeclarationFilters.includeAll,
        globals: DeclarationFilters.includeAll,
        typedefs: DeclarationFilters.includeAll,
        includeUnusedTypedefs: true,
        sort: true,
      ));
      matchLibraryWithExpected(
          library, 'reserved_keyword_collision_test_output.dart', [
        'test',
        'collision_tests',
        'expected_bindings',
        '_expected_reserved_keyword_collision_bindings.dart',
      ]);
    });
  });
}
