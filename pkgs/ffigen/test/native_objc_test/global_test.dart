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
import 'global_test_bindings.dart';
import 'util.dart';

void main() {
  late GlobalTestObjCLibrary lib;
  group('global', () {
    setUpAll(() {
      lib = GlobalTestObjCLibrary(DynamicLibrary.open(findDylib("objc_test")));
    });

    test('Global string', () {
      expect(lib.globalString.toDartString(), 'Hello World');
      lib.globalString = 'Something else'.toNSString();
      expect(lib.globalString.toDartString(), 'Something else');
      lib.globalString = 'Hello World'.toNSString();
    });

    void globalObjectRefCountingInner(ReferenceTracker tracker) {
      final obj = NSObject();
      tracker.track(obj);
      lib.globalObject = obj;
      expect(tracker.isAlive, true);
    }

    test('Global object ref counting', () {
      using((Arena arena) {
        final tracker = ReferenceTracker(arena);
        globalObjectRefCountingInner(tracker);
        expect(tracker.isAlive, true);
        lib.globalObject = null;
        doGC();
        expect(tracker.isAlive, false);
      });
    }, skip: !canDoGC);

    test('Global block', () {
      lib.globalBlock = ObjCBlock_Int32_Int32.fromFunction((int x) => x * 10);
      expect(lib.globalBlock!(123), 1230);
      lib.globalBlock = ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      expect(lib.globalBlock!(456), 1456);
    });

    (ReferenceTracker, ReferenceTracker) globalBlockRefCountingInner(
      Arena arena,
    ) {
      final tracker1 = ReferenceTracker(arena);
      final blk1 = ObjCBlock_Int32_Int32.fromFunction((int x) => x * 10);
      tracker1.trackBlock(blk1);
      lib.globalBlock = blk1;
      expect(tracker1.isAlive, true);

      final tracker2 = ReferenceTracker(arena);
      final blk2 = ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      tracker2.trackBlock(blk2);
      lib.globalBlock = blk2;

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

        lib.globalBlock = null;
        doGC();
        expect(tracker2.isAlive, false);
        expect(tracker1.isAlive, false);
      });
    }, skip: !canDoGC);
  });
}
