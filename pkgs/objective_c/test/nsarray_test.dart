// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'util.dart';

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
      final arena = Arena();
      try {
        final trackers = <ReferenceTracker>[];
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

          for (final o in array!) {
            final t = ReferenceTracker(arena);
            t.track(o.ref.pointer.cast());
            trackers.add(t);
          }
          final tArray = ReferenceTracker(arena);
          tArray.track(objCArray.ref.pointer.cast());
          trackers.add(tArray);

          for (final t in trackers) {
            expect(t.isAlive, true);
          }
        });

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();
        for (final t in trackers) {
          expect(t.isAlive, true);
        }
        array = null;

        doGC();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        doGC();
        for (final t in trackers) {
          expect(t.isAlive, false);
        }
      } finally {
        arena.releaseAll();
      }
    });
  });
}
