// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:swift2objc/src/transformer/_core/unique_namer.dart';

void main() {
  group('UniqueNamer Sanitization Tests', () {
    late UniqueNamer namer;

    setUp(() {
      namer = UniqueNamer();
    });

    test('converts basic operators to valid names', () {
      expect(namer.makeUnique('+'), equals('plus'));
      expect(namer.makeUnique('-'), equals('minus'));
      expect(namer.makeUnique('=='), equals('equalequal'));
    });

    test('handles custom multi-character operators', () {
      expect(namer.makeUnique('***'), equals('multiplymultiplymultiply'));
    });

    test('sanitizes names starting with numbers', () {
      expect(namer.makeUnique('2objects'), equals('n2objects'));
    });

    test('falls back to ASCII for unknown symbols', () {
      final result = namer.makeUnique(r'$');
      expect(result, equals('op36'));
    });

    test('preserves uniqueness even after sanitization', () {
      namer.makeUnique('plus');
      expect(namer.makeUnique('+'), equals('plus1'));
    });

    test('handles mixed alphanumeric and symbols', () {
      expect(namer.makeUnique('set+value'), equals('setplusvalue'));
    });

    test('returns unnamed for empty strings', () {
      expect(namer.makeUnique(''), equals('unnamed'));
    });
  });
}
