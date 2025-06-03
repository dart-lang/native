// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'util.dart';

void main() {
  group('NSArray', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(testDylib);
    });

    test('filled', () {
      final obj = NSObject();
      final array = NSArray.filled(3, obj);

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
      final array = NSArray.of(expected);

      expect(array.length, 5);

      final actual = <ObjCObjectBase>[];
      for (final value in array) {
        actual.add(value);
      }
      expect(actual, expected);
    });

    test('Iterable mixin', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();
      final expected = [obj1, obj2, obj3, obj4, obj5];
      final array = NSArray.of(expected);

      expect(array.isNotEmpty, isTrue);
      expect(array.first, obj1);
      expect(array.toList(), expected);
    });
  });
}
