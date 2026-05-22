// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'global_native_test_bindings.dart';
import 'util.dart';

void main() {
  group('global using @Native', () {
    test('Global string', () {
      expect(globalString.toDartString(), 'Hello World');
      globalString = 'Something else'.toNSString();
      expect(globalString.toDartString(), 'Something else');
      globalString = 'Hello World'.toNSString();
    });

    void globalObjectRefCountingInner(ReferenceTracker globalObjectTracker) {
      final obj = NSObject();
      globalObjectTracker.track(obj);
      globalObject = obj;
      expect(globalObjectTracker.isAlive, true);
    }

    test('Global object ref counting', () {
      using((Arena arena) {
        final globalObjectTracker = ReferenceTracker(arena);
        globalObjectRefCountingInner(globalObjectTracker);
        expect(globalObjectTracker.isAlive, true);
        globalObject = null;
        doGC();
        expect(globalObjectTracker.isAlive, false);
      });
    }, skip: !canDoGC);

    test('Global block', () {
      globalBlock = ObjCBlock_Int32_Int32.fromFunction((int x) => x * 10);
      expect(globalBlock!(123), 1230);
      globalBlock = ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      expect(globalBlock!(456), 1456);
    });

    (ReferenceTracker, ReferenceTracker) globalBlockRefCountingInner(
      Arena arena,
    ) {
      final blk1Tracker = ReferenceTracker(arena);
      final blk1 = ObjCBlock_Int32_Int32.fromFunction((int x) => x * 10);
      blk1Tracker.trackBlock(blk1);
      globalBlock = blk1;
      expect(blk1Tracker.isAlive, true);

      final blk2Tracker = ReferenceTracker(arena);
      final blk2 = ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      blk2Tracker.trackBlock(blk2);
      globalBlock = blk2;

      expect(blk2Tracker.isAlive, true);
      expect(blk1Tracker.isAlive, true);

      expect(blk1, isNotNull);
      expect(blk2, isNotNull);

      return (blk1Tracker, blk2Tracker);
    }

    test('Global block ref counting', () {
      using((Arena arena) {
        final (blk1Tracker, blk2Tracker) = globalBlockRefCountingInner(arena);
        doGC();

        expect(blk2Tracker.isAlive, true);
        expect(blk1Tracker.isAlive, false);

        globalBlock = null;
        doGC();
        expect(blk2Tracker.isAlive, false);
        expect(blk1Tracker.isAlive, false);
      });
    }, skip: !canDoGC);
  });
}
