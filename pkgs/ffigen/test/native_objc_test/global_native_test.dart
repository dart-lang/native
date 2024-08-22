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
      final dylib = File('test/native_objc_test/global_native_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('global_native');
    });

    test('Global string', () {
      expect(globalString.toString(), 'Hello World');
      globalString = 'Something else'.toNSString();
      expect(globalString.toString(), 'Something else');
    });

    (Pointer<ObjCObject>, Pointer<ObjCObject>) globalObjectRefCountingInner() {
      final obj1 = NSObject.new1();
      globalObject = obj1;
      final obj1raw = obj1.pointer;
      expect(objectRetainCount(obj1raw), 2); // obj1, and the global variable.

      final obj2 = NSObject.new1();
      globalObject = obj2;
      final obj2raw = obj2.pointer;
      expect(objectRetainCount(obj2raw), 2); // obj2, and the global variable.
      expect(objectRetainCount(obj1raw), 1); // Just obj1.

      return (obj1raw, obj2raw);
    }

    test('Global object ref counting', () {
      final (obj1raw, obj2raw) = globalObjectRefCountingInner();
      doGC();

      expect(objectRetainCount(obj2raw), 1); // Just the global variable.
      expect(objectRetainCount(obj1raw), 0);

      globalObject = null;
      expect(objectRetainCount(obj2raw), 0);
      expect(objectRetainCount(obj1raw), 0);
    });

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
      final blk1raw = blk1.pointer;
      expect(blockRetainCount(blk1raw), 2); // blk1, and the global variable.

      final blk2 = ObjCBlock_Int32_Int32.fromFunction((int x) => x + 1000);
      globalBlock = blk2;
      final blk2raw = blk2.pointer;
      expect(blockRetainCount(blk2raw), 2); // blk2, and the global variable.
      expect(blockRetainCount(blk1raw), 1); // Just blk1.

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
    });
  });
}
