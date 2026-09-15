// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/visitor/ast.dart';
import 'package:ffigen/src/visitor/copy_typealias_docs.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('CopyTypealiasDocsVisitation', () {
    test('copies documentation to a same-name target', () {
      final context = testContext();
      final target = Struct(name: 'Foo', context: context);
      final typealias = Typealias(
        name: 'Foo',
        type: target,
        dartDoc: 'Typedef documentation.',
      );

      visit(context, CopyTypealiasDocsVisitation(), [typealias]);

      expect(target.dartDoc, 'Typedef documentation.');
    });

    test('does not overwrite target documentation', () {
      final context = testContext();
      final target = Struct(
        name: 'Foo',
        context: context,
        dartDoc: 'Struct documentation.',
      );
      final typealias = Typealias(
        name: 'Foo',
        type: target,
        dartDoc: 'Typedef documentation.',
      );

      visit(context, CopyTypealiasDocsVisitation(), [typealias]);

      expect(target.dartDoc, 'Struct documentation.');
    });

    test('does not copy documentation to a differently named target', () {
      final context = testContext();
      final target = Struct(name: 'Foo', context: context);
      final typealias = Typealias(
        name: 'FooAlias',
        type: target,
        dartDoc: 'Typedef documentation.',
      );

      visit(context, CopyTypealiasDocsVisitation(), [typealias]);

      expect(target.dartDoc, isNull);
    });
  });
}
