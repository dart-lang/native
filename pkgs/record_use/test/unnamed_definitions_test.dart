// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:record_use/record_use.dart';
import 'package:test/test.dart';

void main() {
  group('Unnamed Extension', () {
    const library = Library('package:a/a.dart');

    test('Extension.unnamed constructor', () {
      const extension = Extension.unnamed(library);
      expect(extension.name, '');
      expect(extension.isUnnamed, isTrue);
      expect(extension.parent, library);
    });

    test('Extension named constructor with empty string', () {
      const extension = Extension('', library);
      expect(extension.isUnnamed, isTrue);
    });

    test('Extension named constructor with name', () {
      const extension = Extension('MyExtension', library);
      expect(extension.isUnnamed, isFalse);
    });

    test('toString for unnamed extension', () {
      const extension = Extension.unnamed(library);
      expect(extension.toString(), 'package:a/a.dart#extension:');
    });

    test('semanticEquals for unnamed extension', () {
      const ext1 = Extension.unnamed(library);
      const ext2 = Extension.unnamed(library);
      const ext3 = Extension('MyExtension', library);
      const library2 = Library('package:a/b.dart');
      const ext4 = Extension.unnamed(library2);

      expect(ext1.semanticEquals(ext2), isTrue);
      expect(ext1.semanticEquals(ext3), isFalse);
      expect(ext1.semanticEquals(ext4), isFalse);
    });
  });

  group('Unnamed Constructor', () {
    const library = Library('package:a/a.dart');
    const classDef = Class('MyClass', library);

    test('Constructor.unnamed constructor', () {
      const constructor = Constructor.unnamed(classDef);
      expect(constructor.name, '');
      expect(constructor.isUnnamed, isTrue);
      expect(constructor.parent, classDef);
    });

    test('Constructor named constructor with empty string', () {
      const constructor = Constructor('', classDef);
      expect(constructor.isUnnamed, isTrue);
    });

    test('Constructor named constructor with name', () {
      const constructor = Constructor('named', classDef);
      expect(constructor.isUnnamed, isFalse);
    });

    test('toString for unnamed constructor', () {
      const constructor = Constructor.unnamed(classDef);
      expect(
        constructor.toString(),
        'package:a/a.dart#class:MyClass::constructor:',
      );
    });

    test('semanticEquals for unnamed constructor', () {
      const ctor1 = Constructor.unnamed(classDef);
      const ctor2 = Constructor.unnamed(classDef);
      const ctor3 = Constructor('named', classDef);
      const classDef2 = Class('OtherClass', library);
      const ctor4 = Constructor.unnamed(classDef2);

      expect(ctor1.semanticEquals(ctor2), isTrue);
      expect(ctor1.semanticEquals(ctor3), isFalse);
      expect(ctor1.semanticEquals(ctor4), isFalse);
    });
  });

  group('Operators', () {
    const library = Library('package:a/a.dart');
    const classDef = Class('MyClass', library);

    test('Specialized Operator constructors', () {
      const ops = [
        (Operator.plus, '+', 'isPlus'),
        (Operator.minus, '-', 'isMinus'),
        (Operator.multiply, '*', 'isMultiply'),
        (Operator.division, '/', 'isDivision'),
        (Operator.mustache, '~/', 'isMustache'),
        (Operator.percent, '%', 'isPercent'),
        (Operator.ampersand, '&', 'isAmpersand'),
        (Operator.bar, '|', 'isBar'),
        (Operator.caret, '^', 'isCaret'),
        (Operator.leftShift, '<<', 'isLeftShift'),
        (Operator.rightShift, '>>', 'isRightShift'),
        (Operator.tripleShift, '>>>', 'isTripleShift'),
        (Operator.lessThan, '<', 'isLessThan'),
        (Operator.lessThanOrEquals, '<=', 'isLessThanOrEquals'),
        (Operator.greaterThan, '>', 'isGreaterThan'),
        (Operator.greaterThanOrEquals, '>=', 'isGreaterThanOrEquals'),
        (Operator.equals, '==', 'isEquals'),
        (Operator.indexGet, '[]', 'isIndexGet'),
        (Operator.indexSet, '[]=', 'isIndexSet'),
        (Operator.unaryMinus, 'unary-', 'isUnaryMinus'),
        (Operator.tilde, '~', 'isTilde'),
      ];

      for (final (constructor, expectedName, _) in ops) {
        final op = constructor(classDef);
        expect(op.name, expectedName);
        expect(op.parent, classDef);
      }
    });

    test('isPlus getter', () {
      expect(const Operator.plus(classDef).isPlus, isTrue);
      expect(const Operator.minus(classDef).isPlus, isFalse);
    });

    test('isIndexGet getter', () {
      expect(const Operator.indexGet(classDef).isIndexGet, isTrue);
      expect(const Operator.indexSet(classDef).isIndexGet, isFalse);
    });
  });
}
