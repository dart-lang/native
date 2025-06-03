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
  group('NSMutableSet', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(testDylib);
    });

    test('of', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();
      final expected = {obj1, obj2, obj3, obj4, obj5};
      final s = NSMutableSet.of(expected);

      expect(s.length, 5);

      expect(s.contains(obj3), isTrue);
      expect(s.contains(NSObject()), isFalse);
      expect((s as Set).contains(123), isFalse);
      expect(s.contains(null), isFalse);

      expect(s.lookup(obj3), obj3);
      expect(s.lookup(NSObject()), null);
      expect((s as Set).lookup(123), null);
      expect(s.lookup(null), null);

      final actual = <ObjCObjectBase>[];
      for (final value in s) {
        actual.add(value);
      }
      expect(actual, expected);

      expect(s.toSet(), expected);
    });

    test('mutable', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();

      final s = NSMutableSet.of({obj1, obj2, obj3, obj4, obj5});

      final obj6 = NSObject();
      expect(s.add(obj1), isFalse);
      expect(s.add(obj6), isTrue);
      expect(s, {obj1, obj2, obj3, obj4, obj5, obj6});

      final obj7 = NSObject();
      expect(s.remove(obj7), isFalse);
      expect((s as Set).remove(123), isFalse);
      expect(s.remove(null), isFalse);
      expect(s.remove(obj3), isTrue);
      expect(s, {obj1, obj2, obj4, obj5, obj6});

      s.clear();
      expect(s, <NSObject>{});
    });

    test('SetBase mixin', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();
      final expected = {obj1, obj2, obj3, obj4, obj5};
      final s = NSMutableSet.of(expected);

      expect(s.isNotEmpty, isTrue);
      expect(s.intersection({obj5, obj2, null, 123}), {obj5, obj2});
      expect(s.toList(), expected);
    });
  });
}
