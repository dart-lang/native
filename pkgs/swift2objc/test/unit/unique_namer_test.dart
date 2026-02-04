// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:swift2objc/src/transformer/_core/unique_namer.dart';
import 'package:test/test.dart';

void main() {
  group('UniqueNamer Sanitization Tests', () {
    late UniqueNamer namer;

    setUp(() {
      namer = UniqueNamer();
    });

    test('converts basic operators to valid names', () {
      expect(namer.makeUnique('+'), equals('add'));
      expect(namer.makeUnique('-'), equals('subtract'));
      expect(namer.makeUnique('=='), equals('equals'));
    });

    test('handles custom multi-character operators', () {
      expect(namer.makeUnique('***'), equals('operator_overloading'));
    });

    test('falls back to ASCII for unknown symbols', () {
      final result = namer.makeUnique(r'$');
      expect(result, equals('operator_overloading'));
    });

    test('preserves uniqueness even after sanitization', () {
      namer.makeUnique('add');
      expect(namer.makeUnique('+'), equals('add1'));
    });

    test('handles mixed alphanumeric and symbols', () {
      expect(namer.makeUnique('set+value'), equals('operator_overloading'));
    });

    test('returns unnamed for empty strings', () {
      expect(namer.makeUnique(''), equals('unnamed'));
    });

    test('handles multiple mixed alphanumeric and symbols', () {
      expect(namer.makeUnique('set+value'), equals('operator_overloading'));
      expect(namer.makeUnique('get-item'), equals('operator_overloading1'));
    });
  });
}
