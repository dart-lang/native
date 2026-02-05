// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('reserved_keyword_collision_test', () {
    test('reserved keyword collision', () {
      final context = testContext();
      final library = parser.parse(
        testContext(
          FfiGenerator(
            output: Output(
              dartFile: Uri.file('unused'),
              style: const DynamicLibraryBindings(),
            ),

            headers: Headers(
              entryPoints: [
                Uri.file(
                  path.join(
                    packagePathForTests,
                    'test',
                    'collision_tests',
                    'reserved_keyword_collision.h',
                  ),
                ),
              ],
            ),
            structs: Structs.includeAll,
            unions: Unions.includeAll,
            enums: Enums.includeAll,
            functions: Functions.includeAll,
            globals: Globals.includeAll,
            typedefs: Typedefs(
              include: (Declaration decl) => true,
              includeUnused: true,
            ),
          ),
        ),
      );
      matchLibraryWithExpected(
        context,
        library,
        'reserved_keyword_collision_test_output.dart',
        [
          'test',
          'collision_tests',
          'expected_bindings',
          '_expected_reserved_keyword_collision_bindings.dart',
        ],
      );
    });
  });
}
