// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')

// This test is slightly flaky. Some of the ref counts are occasionally lower
// than expected, presumably due to the Dart wrapper objects being GC'd before
// the expect call.
@Retry(3)

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'arc_bindings.dart';
import 'util.dart';

void main() {
  late ArcTestObjCLibrary lib;

  group('Reference counting', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/arc_test.dylib');
      verifySetupFile(dylib);
      lib = ArcTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));

      generateBindingsForCoverage('arc');
    });

    test('objectRetainCount edge cases', () {
      expect(objectRetainCount(nullptr), 0);
      expect(objectRetainCount(Pointer.fromAddress(0x1234)), 0);
    });

    (Pointer<ObjCObject>, Pointer<ObjCObject>) newMethodsInner(
        Pointer<Int32> counter) {
      final obj1 = ArcTestObject.new1();
      obj1.setCounter_(counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 2);

      final obj1raw = obj1.pointer;
      final obj2raw = obj2.pointer;

      expect(objectRetainCount(obj1raw), 1);
      expect(objectRetainCount(obj2raw), 1);

      final obj2b = ArcTestObject.castFromPointer(obj2raw,
          retain: true, release: true);
      expect(objectRetainCount(obj2b.pointer), 2);

      final obj2c = ArcTestObject.castFromPointer(obj2raw,
          retain: true, release: true);
      expect(objectRetainCount(obj2c.pointer), 3);

      return (obj1raw, obj2raw);
    }

    test('new methods ref count correctly', () {
      // To get the GC to work correctly, the references to the objects all have
      // to be in a separate function.
      final counter = calloc<Int32>();
      counter.value = 0;
      final (obj1raw, obj2raw) = newMethodsInner(counter);
      doGC();
      expect(objectRetainCount(obj1raw), 0);
      expect(objectRetainCount(obj2raw), 0);
      expect(counter.value, 0);
      calloc.free(counter);
    });

    (Pointer<ObjCObject>, Pointer<ObjCObject>, Pointer<ObjCObject>)
        allocMethodsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.alloc().initWithCounter_(counter);
      expect(counter.value, 1);
      final obj2 =
          ArcTestObject.castFrom(ArcTestObject.alloc().init());
      obj2.setCounter_(counter);
      expect(counter.value, 2);
      final obj3 = ArcTestObject.allocTheThing().initWithCounter_(counter);
      expect(counter.value, 3);

      final obj1raw = obj1.pointer;
      final obj2raw = obj2.pointer;
      final obj3raw = obj3.pointer;

      expect(objectRetainCount(obj1raw), 2);
      expect(objectRetainCount(obj2raw), 3);
      expect(objectRetainCount(obj3raw), 2);

      return (obj1raw, obj2raw, obj3raw);
    }

    test('alloc and init methods ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      final (obj1raw, obj2raw, obj3raw) = allocMethodsInner(counter);
      doGC();
      expect(objectRetainCount(obj1raw), 0);
      expect(objectRetainCount(obj2raw), 0);
      expect(objectRetainCount(obj3raw), 0);
      expect(counter.value, 0);
      calloc.free(counter);
    });

    (
      Pointer<ObjCObject>,
      Pointer<ObjCObject>,
      Pointer<ObjCObject>,
      Pointer<ObjCObject>,
      Pointer<ObjCObject>
    ) copyMethodsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final obj2 = obj1.copyMe();
      expect(counter.value, 2);
      final obj3 = obj1.makeACopy();
      expect(counter.value, 3);
      final obj4 = obj1.copyWithZone_(nullptr);
      expect(counter.value, 4);
      final obj5 = obj1.copy();
      expect(counter.value, 5);

      final obj1raw = obj1.pointer;
      final obj2raw = obj2.pointer;
      final obj3raw = obj3.pointer;
      final obj4raw = obj4.pointer;
      final obj5raw = obj5.pointer;

      expect(objectRetainCount(obj1raw), 1);
      expect(objectRetainCount(obj2raw), 1);
      expect(objectRetainCount(obj3raw), 1);
      expect(objectRetainCount(obj4raw), 1);
      expect(objectRetainCount(obj5raw), 1);

      return (obj1raw, obj2raw, obj3raw, obj4raw, obj5raw);
    }

    test('copy methods ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      final (obj1raw, obj2raw, obj3raw, obj4raw, obj5raw) =
          copyMethodsInner(counter);
      doGC();
      expect(objectRetainCount(obj1raw), 0);
      expect(objectRetainCount(obj2raw), 0);
      expect(objectRetainCount(obj3raw), 0);
      expect(objectRetainCount(obj4raw), 0);
      expect(objectRetainCount(obj5raw), 0);
      expect(counter.value, 0);
      calloc.free(counter);
    });

    Pointer<ObjCObject> autoreleaseMethodsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.makeAndAutorelease_(counter);
      expect(counter.value, 1);

      final obj1raw = obj1.pointer;
      expect(objectRetainCount(obj1raw), 2);
      return obj1raw;
    }

    test('autorelease methods ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;

      final pool1 = lib.objc_autoreleasePoolPush();
      final obj1raw = autoreleaseMethodsInner(counter);
      doGC();
      // The autorelease pool is still holding a reference to the object.
      expect(counter.value, 1);
      expect(objectRetainCount(obj1raw), 1);
      lib.objc_autoreleasePoolPop(pool1);
      expect(counter.value, 0);
      expect(objectRetainCount(obj1raw), 0);

      final pool2 = lib.objc_autoreleasePoolPush();
      final obj2 = ArcTestObject.makeAndAutorelease_(counter);
      final obj2raw = obj2.pointer;
      expect(counter.value, 1);
      expect(objectRetainCount(obj2raw), 2);
      doGC();
      expect(counter.value, 1);
      expect(objectRetainCount(obj2raw), 2);
      lib.objc_autoreleasePoolPop(pool2);
      // The obj2 variable still holds a reference to the object.
      expect(counter.value, 1);
      expect(objectRetainCount(obj2raw), 1);
      obj2.release();
      expect(counter.value, 0);
      expect(objectRetainCount(obj2raw), 0);

      calloc.free(counter);
    });

    Pointer<ObjCObject> assignPropertiesInnerInner(
        Pointer<Int32> counter, ArcTestObject outerObj) {
      final assignObj = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 2);
      final assignObjRaw = assignObj.pointer;
      expect(objectRetainCount(assignObjRaw), 1);
      outerObj.assignedProperty = assignObj;
      expect(counter.value, 2);
      expect(assignObj, outerObj.assignedProperty);
      expect(objectRetainCount(assignObjRaw), 2);
      // To test that outerObj isn't holding a reference to assignObj, we let
      // assignObj go out of scope, but keep outerObj in scope. This is
      // dangerous because outerObj now has a dangling reference, so don't
      // access that reference.
      return assignObjRaw;
    }

    (Pointer<ObjCObject>, Pointer<ObjCObject>) assignPropertiesInner(
        Pointer<Int32> counter) {
      final outerObj = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final outerObjRaw = outerObj.pointer;
      expect(objectRetainCount(outerObjRaw), 1);
      final assignObjRaw = assignPropertiesInnerInner(counter, outerObj);
      expect(objectRetainCount(assignObjRaw), 2);
      doGC();
      // assignObj has been cleaned up.
      expect(counter.value, 1);
      expect(objectRetainCount(assignObjRaw), 0);
      expect(objectRetainCount(outerObjRaw), 1);
      return (outerObjRaw, assignObjRaw);
    }

    test('assign properties ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      final (outerObjRaw, assignObjRaw) = assignPropertiesInner(counter);
      expect(objectRetainCount(assignObjRaw), 0);
      expect(objectRetainCount(outerObjRaw), 1);
      doGC();
      expect(counter.value, 0);
      expect(objectRetainCount(assignObjRaw), 0);
      expect(objectRetainCount(outerObjRaw), 0);
      calloc.free(counter);
    });

    Pointer<ObjCObject> retainPropertiesInnerInner(
        Pointer<Int32> counter, ArcTestObject outerObj) {
      final retainObj = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 2);
      final retainObjRaw = retainObj.pointer;
      expect(objectRetainCount(retainObjRaw), 1);
      outerObj.retainedProperty = retainObj;
      expect(counter.value, 2);
      expect(retainObj, outerObj.retainedProperty);
      expect(objectRetainCount(retainObjRaw), 4);
      return retainObjRaw;
    }

    (Pointer<ObjCObject>, Pointer<ObjCObject>) retainPropertiesInner(
        Pointer<Int32> counter) {
      final outerObj = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final outerObjRaw = outerObj.pointer;
      expect(objectRetainCount(outerObjRaw), 1);
      final retainObjRaw = retainPropertiesInnerInner(counter, outerObj);
      expect(objectRetainCount(retainObjRaw), 4);
      doGC();
      // retainObj is still around, because outerObj retains a reference to it.
      expect(objectRetainCount(retainObjRaw), 2);
      expect(objectRetainCount(outerObjRaw), 1);
      expect(counter.value, 2);
      return (outerObjRaw, retainObjRaw);
    }

    test('retain properties ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      // The getters of retain properties retain+autorelease the value. So we
      // need an autorelease pool.
      final pool = lib.objc_autoreleasePoolPush();
      final (outerObjRaw, retainObjRaw) = retainPropertiesInner(counter);
      expect(objectRetainCount(retainObjRaw), 2);
      expect(objectRetainCount(outerObjRaw), 1);
      doGC();
      expect(objectRetainCount(retainObjRaw), 1);
      expect(objectRetainCount(outerObjRaw), 0);
      expect(counter.value, 1);
      lib.objc_autoreleasePoolPop(pool);
      expect(objectRetainCount(retainObjRaw), 0);
      expect(objectRetainCount(outerObjRaw), 0);
      expect(counter.value, 0);
      calloc.free(counter);
    });

    (Pointer<ObjCObject>, Pointer<ObjCObject>, Pointer<ObjCObject>)
        copyPropertiesInner(Pointer<Int32> counter) {
      final outerObj = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 1);

      final copyObj = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 2);
      outerObj.copiedProperty = copyObj;
      // Copy properties make a copy of the object, so now we have 3 objects.
      expect(counter.value, 3);
      expect(copyObj, isNot(outerObj.copiedProperty));

      final anotherCopy = outerObj.copiedProperty;
      // The getter doesn't copy the object.
      expect(counter.value, 3);
      expect(anotherCopy, outerObj.copiedProperty);

      final outerObjRaw = outerObj.pointer;
      final copyObjRaw = copyObj.pointer;
      final anotherCopyRaw = anotherCopy.pointer;

      expect(objectRetainCount(outerObjRaw), 1);
      expect(objectRetainCount(copyObjRaw), 1);
      expect(objectRetainCount(anotherCopyRaw), 7);

      return (outerObjRaw, copyObjRaw, anotherCopyRaw);
    }

    test('copy properties ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      // The getters of copy properties retain+autorelease the value. So we need
      // an autorelease pool.
      final pool = lib.objc_autoreleasePoolPush();
      final (outerObjRaw, copyObjRaw, anotherCopyRaw) =
          copyPropertiesInner(counter);
      doGC();
      expect(counter.value, 1);
      expect(objectRetainCount(outerObjRaw), 0);
      expect(objectRetainCount(copyObjRaw), 0);
      expect(objectRetainCount(anotherCopyRaw), 3);
      lib.objc_autoreleasePoolPop(pool);
      expect(counter.value, 0);
      expect(objectRetainCount(outerObjRaw), 0);
      expect(objectRetainCount(copyObjRaw), 0);
      expect(objectRetainCount(anotherCopyRaw), 0);
      calloc.free(counter);
    });

    test('Manual release', () {
      final counter = calloc<Int32>();
      final obj1 = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 2);
      final obj3 = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 3);

      final obj1raw = obj1.pointer;
      final obj2raw = obj2.pointer;
      final obj3raw = obj3.pointer;

      expect(objectRetainCount(obj1raw), 1);
      expect(objectRetainCount(obj2raw), 1);
      expect(objectRetainCount(obj3raw), 1);

      obj1.release();
      expect(counter.value, 2);
      obj2.release();
      expect(counter.value, 1);
      obj3.release();
      expect(counter.value, 0);

      expect(() => obj1.release(), throwsStateError);
      calloc.free(counter);

      expect(objectRetainCount(obj1raw), 0);
      expect(objectRetainCount(obj2raw), 0);
      expect(objectRetainCount(obj3raw), 0);
    });

    void largeRefCountInner(Pointer<Int32> counter) {
      final obj = ArcTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final objRefs = <ArcTestObject>[];
      for (int i = 1; i < 1000; ++i) {
        final expectedCount = i < 128 ? i : 128;
        expect(objectRetainCount(obj.pointer), expectedCount);
        objRefs.add(ArcTestObject.castFromPointer(obj.pointer,
            retain: true, release: true));
      }
      expect(counter.value, 1);
    }

    test("objectRetainCount large ref count", () {
      // Most ObjC API methods return us a reference without incrementing the
      // ref count (ie, returns us a reference we don't own). So the wrapper
      // object has to take ownership by calling retain. This test verifies that
      // is working correctly by holding a reference to an object returned by a
      // method, after the original wrapper object is gone.
      final counter = calloc<Int32>();
      counter.value = 0;
      largeRefCountInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    });
  });
}
