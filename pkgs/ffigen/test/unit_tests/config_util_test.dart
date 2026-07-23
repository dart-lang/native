// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:test/test.dart';

Declaration decl(String name) => Declaration(usr: '', originalName: name);

void main() {
  group('Visitor utils', () {
    test('IncludeSetVisitor', () {
      final visitor = IncludeSetVisitor({'foo', 'bar'});
      final structFoo = Struct(originalName: 'foo', usr: 'foo');
      final structBaz = Struct(originalName: 'baz', usr: 'baz');
      visitor.visitStruct(structFoo);
      visitor.visitStruct(structBaz);
      expect(structFoo.isExcluded, isFalse);
      expect(structBaz.isExcluded, isTrue);
    });

    test('RenameMapVisitor', () {
      final visitor = RenameMapVisitor({'foo': 'bar'});
      final structFoo = Struct(originalName: 'foo', usr: 'foo');
      final structBaz = Struct(originalName: 'baz', usr: 'baz');
      visitor.visitStruct(structFoo);
      visitor.visitStruct(structBaz);
      expect(structFoo.name, 'bar');
      expect(structBaz.name, 'baz');
    });
  });
}
