// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:ffigen/src/header_parser.dart' show parse;
import 'package:ffigen/src/public_ast.dart' as public_ast;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../test_utils.dart';

class _RenamingVisitor extends public_ast.Visitor {
  const _RenamingVisitor();

  @override
  void visitFunc(public_ast.Func node) {
    if (node.name == 'sum') {
      node.name = 'add';
    }
  }
}

void main() {
  group('record_use_test', () {
    test('Expected Bindings', () {
      final headerFile = absPath(
        p.join('test', 'header_parser_tests', 'record_use.h'),
      );
      final generator = FfiGenerator(
        input: Input(entryPoints: [Uri.file(headerFile)]),
        functions: Functions(
          include: (decl) => true,
          recordUse: (decl) => true,
        ),
        visitors: const [_RenamingVisitor()],
        output: Output(
          dartFile: Uri.file('unused.dart'),
          style: const NativeExternalBindings(),
          recordUseMapping: Uri.file('unused_mapping.dart'),
        ),
      );

      final context = testContext(generator);
      final library = parse(context);

      matchLibraryWithExpected(context, library, 'record_use_bindings.dart', [
        'test',
        'header_parser_tests',
        'expected_bindings',
        '_expected_record_use_bindings.dart',
      ]);

      matchRecordUseMappingWithExpected(
        context,
        library,
        'record_use_mapping.dart',
        [
          'test',
          'header_parser_tests',
          'expected_bindings',
          '_expected_record_use_mapping.dart',
        ],
      );
    });
  });
}
