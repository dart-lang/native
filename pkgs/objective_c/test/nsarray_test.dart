// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'package:objective_c_helper/src/util.dart';

void main() {
  group('NSArray', () {
    test('filled', () {
      final obj = NSObject();
      final array = NSArray.filled(3, obj).asDart();

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
      final array = NSArray.of(expected).asDart();

      expect(array.length, 5);

      final actual = <ObjCObject>[];
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
      final array = NSArray.of(expected).asDart();

      expect(array.isNotEmpty, isTrue);
      expect(array.first, obj1);
      expect(array.toList(), expected);
    });

    test('ref counting', () async {
      final pointers = <Pointer<ObjCObjectImpl>>[];
      List<ObjCObject>? array;

      autoReleasePool(() {
        final obj1 = NSObject();
        final obj2 = NSObject();
        final obj3 = NSObject();
        final obj4 = NSObject();
        final obj5 = NSObject();
        final objects = [obj1, obj2, obj3, obj4, obj5];
        final objCArray = NSArray.of(objects);
        array = objCArray.asDart();

        pointers.addAll(array!.map((o) => o.ref.pointer));
        pointers.add(objCArray.ref.pointer);

        for (final pointer in pointers) {
          expect(objectRetainCount(pointer), greaterThan(0));
        }
      });

      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();
      for (final pointer in pointers) {
        expect(objectRetainCount(pointer), greaterThan(0));
      }
      array = null;

      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();
      for (final pointer in pointers) {
        expect(objectRetainCount(pointer), 0);
      }
    });
  });
}
