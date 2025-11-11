// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/ffigen.dart';
import 'package:test/test.dart';

Declaration decl(String name) => Declaration(usr: '', originalName: name);

void main() {
  group('Declarations utils', () {
    test('includeSet', () {
      final includer = Declarations.includeSet({'foo', 'bar'});
      expect(includer(decl('foo')), isTrue);
      expect(includer(decl('bar')), isTrue);
      expect(includer(decl('baz')), isFalse);
    });

    test('includeMemberSet', () {
      final includer = Declarations.includeMemberSet({
        'foo': {'bar'},
      });
      expect(includer(decl('foo'), 'bar'), isTrue);
      expect(includer(decl('foo'), 'baz'), isFalse);
      expect(includer(decl('goo'), 'bar'), isTrue);
      expect(includer(decl('goo'), 'baz'), isTrue);
    });

    test('renameWithMap', () {
      final renamer = Declarations.renameWithMap({'foo': 'bar'});
      expect(renamer(decl('foo')), 'bar');
      expect(renamer(decl('bar')), 'bar');
      expect(renamer(decl('baz')), 'baz');
    });

    test('renameMemberWithMap', () {
      final renamer = Declarations.renameMemberWithMap({'foo': {'bar': 'baz'}});
      expect(renamer(decl('foo'), 'bar'), 'baz');
      expect(renamer(decl('foo'), 'baz'), 'baz');
      expect(renamer(decl('foo'), 'bop'), 'bop');
      expect(renamer(decl('goo'), 'bar'), 'bar');
      expect(renamer(decl('goo'), 'baz'), 'baz');
      expect(renamer(decl('goo'), 'bop'), 'bop');
    });
  });
}
