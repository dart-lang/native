// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/config_provider.dart';
import 'package:ffigen/src/header_parser.dart' show parse;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('record_use_test', () {
    test('Expected Bindings', () {
      final headerFile = p.join('test', 'header_parser_tests', 'record_use.h');
      final generator = FfiGenerator(
        headers: Headers(entryPoints: [Uri.file(headerFile)]),
        functions: Functions(
          include: (decl) => true,
          recordUse: (decl) => true,
          rename: (decl) =>
              decl.originalName == 'sum' ? 'add' : decl.originalName,
        ),
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
