// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
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
  group('NSNumber', () {
    test('from double', () {
      final n = 1.23.toNSNumber();

      expect(n.intValue, 1);
      expect(n.longLongValue, 1);
      expect(n.doubleValue, 1.23);
      expect(n.numValue, isA<double>());
      expect(n.numValue, 1.23);
      expect(n.isFloat, isTrue);
      expect(n.isBool, isFalse);
    });

    test('from int', () {
      final n = 0x7fffffffffffffff.toNSNumber();

      expect(n.intValue, -1);
      expect(n.longLongValue, 0x7fffffffffffffff);
      expect(n.doubleValue, 0x7ffffffffffffff0);
      expect(n.numValue, isA<int>());
      expect(n.numValue, 0x7fffffffffffffff);
      expect(n.isFloat, isFalse);
      expect(n.isBool, isFalse);
    });

    test('from num', () {
      late num x;

      x = 1.23;
      final n = x.toNSNumber();
      expect(n.intValue, 1);
      expect(n.longLongValue, 1);
      expect(n.doubleValue, 1.23);
      expect(n.numValue, isA<double>());
      expect(n.numValue, 1.23);

      x = 0x7fffffffffffffff;
      final m = x.toNSNumber();
      expect(m.intValue, -1);
      expect(m.longLongValue, 0x7fffffffffffffff);
      expect(m.doubleValue, 0x7ffffffffffffff0);
      expect(m.numValue, isA<int>());
      expect(m.numValue, 0x7fffffffffffffff);
    });

    // Values small enough to be stored as tagged pointers are never
    // deallocated, so these tests use values that are large enough to require
    // a real object.
    //
    // `bool.toNSNumber` isn't tested because it always returns one of the two
    // immortal `__NSCFBoolean` singletons.
    test('`double.toNSNumber` garbage collected', () async {
      await using((arena) async {
        final tracker = ReferenceTracker(arena);
        () {
          tracker.track(1.2345678901234567e300.toNSNumber());
        }();

        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(tracker.isAlive, isFalse);
      });
    });

    test('`int.toNSNumber` garbage collected', () async {
      await using((arena) async {
        final tracker = ReferenceTracker(arena);
        () {
          tracker.track(0x7fffffffffffffff.toNSNumber());
        }();

        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(tracker.isAlive, isFalse);
      });
    });
  });

  test('from bool', () {
    final t = true.toNSNumber();
    final f = false.toNSNumber();

    expect(t.boolValue, isTrue);
    expect(f.boolValue, isFalse);
  });
}
