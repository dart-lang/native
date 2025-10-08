// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/code_generator/scope.dart';
import 'package:test/test.dart';

void main() {
  group('Namer', () {
    test('ordinary renaming', () {
      final namer = Namer({});
      expect(namer.add('foo', SymbolKind.field), 'foo');
      expect(namer.add('foo', SymbolKind.field), 'foo\$1');
      expect(namer.add('foo', SymbolKind.field), 'foo\$2');
      expect(namer.add('foo', SymbolKind.field), 'foo\$3');
    });

    test('keyword renaming', () {
      final namer = Namer({});
      expect(namer.add('for', SymbolKind.field), 'for\$');
      expect(namer.add('for', SymbolKind.field), 'for\$1');
      expect(namer.add('for', SymbolKind.field), 'for\$2');
      expect(namer.add('for', SymbolKind.field), 'for\$3');
    });

    test('unnamed renaming', () {
      final namer = Namer({});
      expect(namer.add('', SymbolKind.field), 'unnamed');
      expect(namer.add('', SymbolKind.field), 'unnamed\$1');
      expect(namer.add('', SymbolKind.field), 'unnamed\$2');
      expect(namer.add('', SymbolKind.field), 'unnamed\$3');
    });

    test('mark used', () {
      final namer = Namer({
        'foo': SymbolKind.field.mask,
        'bar': SymbolKind.field.mask,
      });
      namer.markUsed('baz', SymbolKind.field);

      expect(namer.add('foo', SymbolKind.field), 'foo\$1');
      expect(namer.add('bar', SymbolKind.field), 'bar\$1');
      expect(namer.add('baz', SymbolKind.field), 'baz\$1');
      expect(namer.add('blah', SymbolKind.field), 'blah');
    });

    test('cSafeName', () {
      final namer = Namer({});
      expect(Namer.cSafeName(namer.add('foo', SymbolKind.field)), 'foo');
      expect(Namer.cSafeName(namer.add('foo', SymbolKind.field)), 'foo_1');
      expect(Namer.cSafeName(namer.add('foo', SymbolKind.field)), 'foo_2');
      expect(Namer.cSafeName(namer.add('foo', SymbolKind.field)), 'foo_3');
    });

    test('stringLiteral', () {
      final namer = Namer({});
      expect(Namer.stringLiteral(namer.add('foo', SymbolKind.field)), 'foo');
      expect(
        Namer.stringLiteral(namer.add('foo', SymbolKind.field)),
        'foo\\\$1',
      );
      expect(
        Namer.stringLiteral(namer.add('foo', SymbolKind.field)),
        'foo\\\$2',
      );
      expect(
        Namer.stringLiteral(namer.add('foo', SymbolKind.field)),
        'foo\\\$3',
      );
    });
  });

  group('Scope', () {
    test('parenting', () {
      final root = Scope.createRoot('root');
      final parent = root.addChild('parent');
      final child = parent.addChild('child');
      final uncle = root.addChild('uncle');

      final rootSymbol = Symbol('foo', SymbolKind.field);
      final parentSymbol = Symbol('foo', SymbolKind.field);
      final childSymbol = Symbol('foo', SymbolKind.field);
      final uncleSymbol = Symbol('foo', SymbolKind.field);

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
      final root = Scope.createRoot('root');
      root.fillNames();
      expect(root.addPrivate('_foo'), '_foo');
      expect(root.addPrivate('_foo'), '_foo\$1');
      expect(root.addPrivate('_foo'), '_foo\$2');
    });

    test('preUsedNames', () {
      final root = Scope.createRoot('root');
      final parent = root.addChild(
        'parent',
        preUsedNames: {'bar': SymbolKind.field.mask},
      );
      final child = parent.addChild('child');
      final uncle = root.addChild('uncle');

      final parentSymbol = Symbol('bar', SymbolKind.field);
      final childSymbol = Symbol('bar', SymbolKind.field);
      final uncleSymbol = Symbol('bar', SymbolKind.field);

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
