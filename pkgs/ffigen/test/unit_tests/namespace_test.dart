// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/namespace.dart';
import 'package:test/test.dart';

void main() {
  group('Namer', () {
    test('ordinary renaming', () {
      final namer = Namer({});
      expect(namer.add('foo'), 'foo');
      expect(namer.add('foo'), 'foo\$1');
      expect(namer.add('foo'), 'foo\$2');
      expect(namer.add('foo'), 'foo\$3');
    });

    test('keyword renaming', () {
      final namer = Namer({});
      expect(namer.add('for'), 'for\$');
      expect(namer.add('for'), 'for\$1');
      expect(namer.add('for'), 'for\$2');
      expect(namer.add('for'), 'for\$3');
    });

    test('unnamed renaming', () {
      final namer = Namer({});
      expect(namer.add(''), 'unnamed');
      expect(namer.add(''), 'unnamed\$1');
      expect(namer.add(''), 'unnamed\$2');
      expect(namer.add(''), 'unnamed\$3');
    });

    test('mark used', () {
      final namer = Namer({'foo', 'bar'});
      namer.markUsed('baz');

      expect(namer.add('foo'), 'foo\$1');
      expect(namer.add('bar'), 'bar\$1');
      expect(namer.add('baz'), 'baz\$1');
      expect(namer.add('blah'), 'blah');
    });

    test('cSafeName', () {
      final namer = Namer({});
      expect(Namespace.cSafeName(namer.add('foo')), 'foo');
      expect(Namespace.cSafeName(namer.add('foo')), 'foo_1');
      expect(Namespace.cSafeName(namer.add('foo')), 'foo_2');
      expect(Namespace.cSafeName(namer.add('foo')), 'foo_3');
    });

    test('stringLiteral', () {
      final namer = Namer({});
      expect(Namespace.stringLiteral(namer.add('foo')), 'foo');
      expect(Namespace.stringLiteral(namer.add('foo')), 'foo\\\$1');
      expect(Namespace.stringLiteral(namer.add('foo')), 'foo\\\$2');
      expect(Namespace.stringLiteral(namer.add('foo')), 'foo\\\$3');
    });
  });

  group('Namespace', () {
    test('parenting', () {
      final root = Namespace.createRoot();
      final parent = root.addNamespace();
      final child = parent.addNamespace();
      final uncle = root.addNamespace();

      final rootSymbol = Symbol('foo');
      final parentSymbol = Symbol('foo');
      final childSymbol = Symbol('foo');
      final uncleSymbol = Symbol('foo');

      root.add(rootSymbol);
      parent.add(parentSymbol);
      child.add(childSymbol);
      uncle.add(uncleSymbol);

      root.fillNames();
      expect(rootSymbol.name, 'foo');
      expect(parentSymbol.name, 'foo\$1');
      expect(childSymbol.name, 'foo\$2');
      expect(uncleSymbol.name, 'foo\$1');
    });

    test('addPrivate', () {
      final root = Namespace.createRoot();
      root.fillNames();
      expect(root.addPrivate('_foo'), '_foo');
      expect(root.addPrivate('_foo'), '_foo\$1');
      expect(root.addPrivate('_foo'), '_foo\$2');
    });

    test('preUsedNames', () {
      final root = Namespace.createRoot();
      final parent = root.addNamespace(preUsedNames: {'bar'});
      final child = parent.addNamespace();
      final uncle = root.addNamespace();

      final parentSymbol = Symbol('bar');
      final childSymbol = Symbol('bar');
      final uncleSymbol = Symbol('bar');

      parent.add(parentSymbol);
      child.add(childSymbol);
      uncle.add(uncleSymbol);

      root.fillNames();
      expect(parentSymbol.name, 'bar\$1');
      expect(childSymbol.name, 'bar\$2');
      expect(uncleSymbol.name, 'bar');
    });
  });
}
