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
    setUpAll(() {
      loadLibrary();
    });

    test('Global string', () {
      expect(globalString.toDartString(), 'Hello World');
      globalString = 'Something else'.toNSString();
      expect(globalString.toDartString(), 'Something else');
      globalString = 'Hello World'.toNSString();
    });

    void globalObjectRefCountingInner(ReferenceTracker tracker) {
      final obj = NSObject();
      tracker.track(obj);
      globalObject = obj;
      expect(tracker.isAlive, true);
    }

    test('Global object ref counting', () {
      using((Arena arena) {
        final tracker = ReferenceTracker(arena);
        globalObjectRefCountingInner(tracker);
        expect(tracker.isAlive, true);
        globalObject = null;
        doGC();
        expect(tracker.isAlive, false);
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
      final tracker1 = ReferenceTracker(arena);
      final blk1 = ObjCBlock_Int32_Int32.fromFunction((int x) => x * 10);
      tracker1.trackBlock(blk1);
      globalBlock = blk1;
      expect(tracker1.isAlive, true);

      final tracker2 = ReferenceTracker(arena);
      final blk2 = ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      tracker2.trackBlock(blk2);
      globalBlock = blk2;

      expect(tracker2.isAlive, true);
      expect(tracker1.isAlive, true);

      expect(blk1, isNotNull);
      expect(blk2, isNotNull);

      return (tracker1, tracker2);
    }

    test('Global block ref counting', () {
      using((Arena arena) {
        final (tracker1, tracker2) = globalBlockRefCountingInner(arena);
        doGC();

        expect(tracker2.isAlive, true);
        expect(tracker1.isAlive, false);

        globalBlock = null;
        doGC();
        expect(tracker2.isAlive, false);
        expect(tracker1.isAlive, false);
      });
    }, skip: !canDoGC);
  });
}
