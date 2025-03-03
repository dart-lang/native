// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/unique_namer.dart';
import 'package:test/test.dart';

void main() {
  group('UniqueNamer', () {
    test('ordinary renaming', () {
      final namer = UniqueNamer();
      expect(namer.makeUnique('foo'), 'foo');
      expect(namer.makeUnique('foo'), 'foo\$1');
      expect(namer.makeUnique('foo'), 'foo\$2');
      expect(namer.makeUnique('foo'), 'foo\$3');

      expect(namer.isUsed('foo'), isTrue);
      expect(namer.isUsed('bar'), isFalse);
    });

    test('keyword renaming', () {
      final namer = UniqueNamer();
      expect(namer.makeUnique('for'), 'for\$');
      expect(namer.makeUnique('for'), 'for\$1');
      expect(namer.makeUnique('for'), 'for\$2');
      expect(namer.makeUnique('for'), 'for\$3');
    });

    test('unnamed renaming', () {
      final namer = UniqueNamer();
      expect(namer.makeUnique(''), 'unnamed');
      expect(namer.makeUnique(''), 'unnamed\$1');
      expect(namer.makeUnique(''), 'unnamed\$2');
      expect(namer.makeUnique(''), 'unnamed\$3');
    });

    test('parenting', () {
      final parentNamer = UniqueNamer();
      expect(parentNamer.makeUnique('foo'), 'foo');
      expect(parentNamer.makeUnique('foo'), 'foo\$1');

      final namer = UniqueNamer(parent: parentNamer);
      expect(namer.makeUnique('foo'), 'foo\$2');
      expect(namer.makeUnique('foo'), 'foo\$3');
    });

    test('mark used', () {
      final namer = UniqueNamer();
      namer.markUsed('foo');
      namer.markAllUsed(['bar', 'baz']);

      expect(namer.isUsed('foo'), isTrue);
      expect(namer.isUsed('bar'), isTrue);
      expect(namer.isUsed('baz'), isTrue);
      expect(namer.isUsed('blah'), isFalse);

      expect(namer.makeUnique('foo'), 'foo\$1');
      expect(namer.makeUnique('bar'), 'bar\$1');
      expect(namer.makeUnique('baz'), 'baz\$1');
      expect(namer.makeUnique('blah'), 'blah');
    });

    test('cSafeName', () {
      final namer = UniqueNamer();
      expect(UniqueNamer.cSafeName(namer.makeUnique('foo')), 'foo');
      expect(UniqueNamer.cSafeName(namer.makeUnique('foo')), 'foo_1');
      expect(UniqueNamer.cSafeName(namer.makeUnique('foo')), 'foo_2');
      expect(UniqueNamer.cSafeName(namer.makeUnique('foo')), 'foo_3');
    });

    test('stringLiteral', () {
      final namer = UniqueNamer();
      expect(UniqueNamer.stringLiteral(namer.makeUnique('foo')), 'foo');
      expect(UniqueNamer.stringLiteral(namer.makeUnique('foo')), 'foo\\\$1');
      expect(UniqueNamer.stringLiteral(namer.makeUnique('foo')), 'foo\\\$2');
      expect(UniqueNamer.stringLiteral(namer.makeUnique('foo')), 'foo\\\$3');
    });
  });
}
