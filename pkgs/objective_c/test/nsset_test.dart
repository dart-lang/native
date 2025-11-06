// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

void main() {
  group('NSSet', () {
    test('of', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();
      final expected = <NSObject>{obj1, obj2, obj3, obj4, obj5};
      final s = NSSet.of(expected).asDart();

      expect(s.length, 5);

      expect(s.contains(obj3), isTrue);
      expect(s.contains(NSObject()), isFalse);
      expect((s as Set).contains(123), isFalse);
      expect(s.contains(null), isFalse);

      expect(s.lookup(obj3), obj3);
      expect(s.lookup(NSObject()), null);
      expect((s as Set).lookup(123), null);
      expect(s.lookup(null), null);

      final actual = <ObjCObject>[];
      for (final value in s) {
        actual.add(value);
      }
      expect(actual, expected);

      expect(s.toSet(), expected);
    });

    test('immutable', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();

      // NSSet.of actually returns a NSMutableSet, so our immutability tests
      // wouldn't actually work. So convert it to a real NSSet using an ObjC
      // constructor.
      final s = NSSet.setWithSet(
        NSSet.of(<NSObject>{obj1, obj2, obj3, obj4, obj5}),
      ).asDart();

      expect(() => s.add(NSObject()), throwsUnsupportedError);
      expect(() => s.remove(obj3), throwsUnsupportedError);
      expect(s.clear, throwsUnsupportedError);
    });

    test('SetBase mixin', () {
      final obj1 = NSObject();
      final obj2 = NSObject();
      final obj3 = NSObject();
      final obj4 = NSObject();
      final obj5 = NSObject();
      final expected = <NSObject>{obj1, obj2, obj3, obj4, obj5};
      final s = NSSet.of(expected).asDart();

      expect(s.isNotEmpty, isTrue);
      expect(s.intersection(<Object?>{obj5, obj2, null, 123}), {obj5, obj2});
      expect(s.toList(), expected);
    });

    test('ref counting', () async {
      final pointers = <Pointer<ObjCObjectImpl>>[];
      Set<ObjCObject>? set;

      autoReleasePool(() {
        final obj1 = NSObject();
        final obj2 = NSObject();
        final obj3 = NSObject();
        final obj4 = NSObject();
        final obj5 = NSObject();
        final objects = [obj1, obj2, obj3, obj4, obj5];
        final objCSet = NSSet.of(objects);
        set = objCSet.asDart();

        pointers.addAll(set!.map((o) => o.ref.pointer));
        pointers.add(objCSet.ref.pointer);

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
      set = null;

      doGC();
      await Future<void>.delayed(Duration.zero);
      doGC();
      for (final pointer in pointers) {
        expect(objectRetainCount(pointer), 0);
      }
    });
  });
}
