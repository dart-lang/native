// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

void main() {
  group('NSMutableArray', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('test/objective_c.dylib');
    });

    test('filled', () {
      final obj = NSObject();
      final array = NSMutableArray.filled(3, obj);

      expect(array.length, 3);

      expect(array.elementAt(0), obj);
      expect(array.elementAt(1), obj);
      expect(array.elementAt(2), obj);

      expect(array[0], obj);
      expect(array[1], obj);
      expect(array[2], obj);
    });

    test('of', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();
      final expected = [obj1, obj2, obj3, obj4, obj5];
      final array = NSMutableArray.of(expected);

      expect(array.length, 5);

      final actual = <ObjCObjectBase>[];
      for (final value in array) {
        actual.add(value);
      }
      expect(actual, expected);
    });

    test('length setter', () {
      final array = NSMutableArray.filled(3, NSObject());
      expect(array.length, 3);
      expect(() => array.length = 4, throwsA(isA<RangeError>()));
      expect(() => array.length = -1, throwsA(isA<RangeError>()));
      array.length = 3;
      expect(array.length, 3);
      array.length = 2;
      expect(array.length, 2);
      array.length = 0;
      expect(array.length, 0);
    });

    test('element setter', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();
      final array = NSMutableArray.of([obj1, obj2, obj3]);

      array[1] = obj4;
      expect(array, [obj1, obj4, obj3]);

      array[2] = obj5;
      expect(array, [obj1, obj4, obj5]);
    });

    test('add', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();
      final array = NSMutableArray();

      expect(array.length, 0);

      array.add(obj1);
      array.add(obj2);

      expect(array.length, 2);
      expect(array, [obj1, obj2]);

      array.addAll([obj3, obj4, obj5]);

      expect(array.length, 5);
      expect(array, [obj1, obj2, obj3, obj4, obj5]);
    });

    test('List mixin', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();
      final array = NSMutableArray.of([obj1, obj2, obj3, obj4, obj5]);

      array.setRange(1, 4, [obj5, obj1, obj2]);
      expect(array, [obj1, obj5, obj1, obj2, obj5]);

      expect(array.remove(obj2), isTrue);
      expect(array, [obj1, obj5, obj1, obj5]);

      expect(array.sublist(1, 3), [obj5, obj1]);
    });
  });
}
