// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'global_native_bindings.dart';
import 'util.dart';

void main() {
  group('global using @Native', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/objc_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('global');
    });

    test('Global string', () {
      expect(globalString.toDartString(), 'Hello World');
      globalString = 'Something else'.toNSString();
      expect(globalString.toDartString(), 'Something else');
      globalString = 'Hello World'.toNSString();
    });

    Pointer<ObjCObject> globalObjectRefCountingInner() {
      globalObject = NSObject();
      final obj1raw = globalObject!.ref.pointer;

      // TODO(https://github.com/dart-lang/native/issues/1435): Fix flakiness.
      // expect(objectRetainCount(obj1raw), greaterThan(0));

      return obj1raw;
    }

    test('Global object ref counting', () {
      final obj1raw = globalObjectRefCountingInner();
      globalObject = null;
      doGC();
      expect(objectRetainCount(obj1raw), 0);
    }, skip: !canDoGC);

    test('Global block', () {
      globalBlock = ObjCBlock_Int32_Int32.fromFunction((int x) => x * 10);
      expect(globalBlock!(123), 1230);
      globalBlock = ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      expect(globalBlock!(456), 1456);
    });

    (Pointer<ObjCBlockImpl>, Pointer<ObjCBlockImpl>)
        globalBlockRefCountingInner() {
      final blk1 = ObjCBlock_Int32_Int32.fromFunction((int x) => x * 10);
      globalBlock = blk1;
      final blk1raw = blk1.ref.pointer;
      expect(blockRetainCount(blk1raw), 2); // blk1, and the global variable.

      final blk2 = ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      globalBlock = blk2;
      final blk2raw = blk2.ref.pointer;
      expect(blockRetainCount(blk2raw), 2); // blk2, and the global variable.
      expect(blockRetainCount(blk1raw), 1); // Just blk1.
      expect(blk1, isNotNull); // Force blk1 to stay in scope.
      expect(blk2, isNotNull); // Force blk2 to stay in scope.

      return (blk1raw, blk2raw);
    }

    test('Global block ref counting', () {
      final (blk1raw, blk2raw) = globalBlockRefCountingInner();
      doGC();

      expect(blockRetainCount(blk2raw), 1); // Just the global variable.
      expect(blockRetainCount(blk1raw), 0);

      globalBlock = null;
      expect(blockRetainCount(blk2raw), 0);
      expect(blockRetainCount(blk1raw), 0);
    }, skip: !canDoGC);
  });
}
