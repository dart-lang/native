// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('record_use_test', () {
    test('generate @RecordUse annotation and mapping', () {
      final func = Func(
        name: 'sum',
        originalName: 'sum_native',
        returnType: intType,
        parameters: [
          Parameter(name: 'a', type: intType, objCConsumed: false),
          Parameter(name: 'b', type: intType, objCConsumed: false),
        ],
        recordUse: true,
      );

      final library = Library(bindings: [func], context: testContext())
        ..forceFillNamesForTesting();

      final output = library.generate();
      expect(output, contains('@meta.RecordUse()'));
      expect(output, contains("import 'package:meta/meta.dart' as meta;"));
      expect(
        output,
        contains(
          'ignore_for_file: type=lint, unused_import, unused_element, experimental_member_use',
        ),
      );

      final mapping = library.writer.generateRecordUseMapping();
      expect(mapping, contains("'sum': 'sum_native'"));
      expect(mapping, contains('const recordUseMapping = {'));
    });

    test('no @RecordUse annotation and mapping when recordUse is false', () {
      final func = Func(
        name: 'sum',
        originalName: 'sum_native',
        returnType: intType,
        parameters: [
          Parameter(name: 'a', type: intType, objCConsumed: false),
          Parameter(name: 'b', type: intType, objCConsumed: false),
        ],
        recordUse: false,
      );

      final library = Library(bindings: [func], context: testContext())
        ..forceFillNamesForTesting();

      final output = library.generate();
      expect(output, isNot(contains('@meta.RecordUse()')));
      expect(output, isNot(contains('experimental_member_use')));

      final mapping = library.writer.generateRecordUseMapping();
      expect(mapping, isNull);
    });
  });
}
