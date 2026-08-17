// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/config_provider/public_ast.dart' as public_ast;
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
            visitors: [
              public_ast.Visitor(
                func: (node) => node.isIncluded = true,
                struct: (node) => node.isIncluded = true,
                union: (node) => node.isIncluded = true,
                enumClass: (node) => node.isIncluded = true,
                global: (node) => node.isIncluded = true,
                macroConstant: (node) => node.isIncluded = true,
                typealias: (node) => node.isIncluded = true,
              ),
            ],
            input: Input(
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
            typedefs: const Typedefs(includeUnused: true),
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
