// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';
import '../test_utils.dart';
import 'ref_count_bindings.dart';
import 'util.dart';

void main() {
  late RefCountTestObjCLibrary lib;

  group('Reference counting', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/ref_count_test.dylib');
      verifySetupFile(dylib);
      lib = RefCountTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));

      generateBindingsForCoverage('ref_count');
    });

    test('objectRetainCount edge cases', () {
      expect(objectRetainCount(nullptr), 0);
      expect(objectRetainCount(Pointer.fromAddress(0x1234)), 0);
    });

    (Pointer<ObjCObject>, Pointer<ObjCObject>) newMethodsInner(
        Pointer<Int32> counter) {
      final obj1 = RefCountTestObject.new1();
      obj1.setCounter_(counter);
      expect(counter.value, 1);
      final obj2 = RefCountTestObject.newWithCounter_(counter);
      expect(counter.value, 2);

      final obj1raw = obj1.pointer;
      final obj2raw = obj2.pointer;

      expect(objectRetainCount(obj1raw), 1);
      expect(objectRetainCount(obj2raw), 1);

      final obj2b = RefCountTestObject.castFromPointer(obj2raw,
          retain: true, release: true);
      expect(objectRetainCount(obj2b.pointer), 2);

      final obj2c = RefCountTestObject.castFromPointer(obj2raw,
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
      final obj1 = RefCountTestObject.alloc().initWithCounter_(counter);
      expect(counter.value, 1);
      final obj2 =
          RefCountTestObject.castFrom(RefCountTestObject.alloc().init());
      obj2.setCounter_(counter);
      expect(counter.value, 2);
      final obj3 = RefCountTestObject.allocTheThing().initWithCounter_(counter);
      expect(counter.value, 3);

      final obj1raw = obj1.pointer;
      final obj2raw = obj2.pointer;
      final obj3raw = obj3.pointer;

      expect(objectRetainCount(obj1raw), 2);
      expect(objectRetainCount(obj2raw), 3);
      expect(objectRetainCount(obj3raw), 2);

      expect(obj1, isNotNull); // Force obj1 to stay in scope.
      expect(obj2, isNotNull); // Force obj2 to stay in scope.
      expect(obj3, isNotNull); // Force obj3 to stay in scope.

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
      Pointer<ObjCObject>,
      Pointer<ObjCObject>,
      Pointer<ObjCObject>,
      Pointer<ObjCObject>,
      Pointer<ObjCObject>
    ) copyMethodsInner(Pointer<Int32> counter) {
      final pool = lib.objc_autoreleasePoolPush();
      final obj1 = RefCountTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final obj2 = obj1.copyMe();
      expect(counter.value, 2);
      final obj3 = obj1.mutableCopyMe();
      expect(counter.value, 3);
      final obj4 = obj1.copyWithZone_(nullptr);
      expect(counter.value, 4);
      final obj5 = obj1.copy();
      expect(counter.value, 5);
      final obj6 = obj1.returnsRetained();
      expect(counter.value, 6);
      final obj7 = obj1.copyMeNoRetain();
      expect(counter.value, 7);
      final obj8 = obj1.copyMeAutorelease();
      expect(counter.value, 8);
      final obj9 = obj1.copyMeConsumeSelf();
      expect(counter.value, 9);

      final obj1raw = obj1.pointer;
      final obj2raw = obj2.pointer;
      final obj3raw = obj3.pointer;
      final obj4raw = obj4.pointer;
      final obj5raw = obj5.pointer;
      final obj6raw = obj6.pointer;
      final obj7raw = obj7.pointer;
      final obj8raw = obj8.pointer;
      final obj9raw = obj9.pointer;

      expect(objectRetainCount(obj1raw), 1);
      expect(objectRetainCount(obj2raw), 1);
      expect(objectRetainCount(obj3raw), 1);
      expect(objectRetainCount(obj4raw), 1);
      expect(objectRetainCount(obj5raw), 1);
      expect(objectRetainCount(obj6raw), 1);
      expect(objectRetainCount(obj7raw), 2); // One ref in autorelease pool.
      expect(objectRetainCount(obj8raw), 2); // One ref in autorelease pool.
      expect(objectRetainCount(obj9raw), 1);

      lib.objc_autoreleasePoolPop(pool);
      expect(objectRetainCount(obj1raw), 1);
      expect(objectRetainCount(obj2raw), 1);
      expect(objectRetainCount(obj3raw), 1);
      expect(objectRetainCount(obj4raw), 1);
      expect(objectRetainCount(obj5raw), 1);
      expect(objectRetainCount(obj6raw), 1);
      expect(objectRetainCount(obj7raw), 1);
      expect(objectRetainCount(obj8raw), 1);
      expect(objectRetainCount(obj9raw), 1);

      return (
        obj1raw,
        obj2raw,
        obj3raw,
        obj4raw,
        obj5raw,
        obj6raw,
        obj7raw,
        obj8raw,
        obj9raw
      );
    }

    test('copy methods ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      final (
        obj1raw,
        obj2raw,
        obj3raw,
        obj4raw,
        obj5raw,
        obj6raw,
        obj7raw,
        obj8raw,
        obj9raw
      ) = copyMethodsInner(counter);
      doGC();
      expect(objectRetainCount(obj1raw), 0);
      expect(objectRetainCount(obj2raw), 0);
      expect(objectRetainCount(obj3raw), 0);
      expect(objectRetainCount(obj4raw), 0);
      expect(objectRetainCount(obj5raw), 0);
      expect(objectRetainCount(obj6raw), 0);
      expect(objectRetainCount(obj7raw), 0);
      expect(objectRetainCount(obj8raw), 0);
      expect(objectRetainCount(obj9raw), 0);
      expect(counter.value, 0);
      calloc.free(counter);
    });

    Pointer<ObjCObject> autoreleaseMethodsInner(Pointer<Int32> counter) {
      final obj1 = RefCountTestObject.makeAndAutorelease_(counter);
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
      final obj2 = RefCountTestObject.makeAndAutorelease_(counter);
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
        Pointer<Int32> counter, RefCountTestObject outerObj) {
      final assignObj = RefCountTestObject.newWithCounter_(counter);
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
      final outerObj = RefCountTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final outerObjRaw = outerObj.pointer;
      expect(objectRetainCount(outerObjRaw), 1);
      final assignObjRaw = assignPropertiesInnerInner(counter, outerObj);
      doGC();
      // assignObj has been cleaned up.
      expect(counter.value, 1);
      expect(objectRetainCount(assignObjRaw), 0);
      expect(objectRetainCount(outerObjRaw), 1);
      expect(outerObj, isNotNull); // Force outerObj to stay in scope.
      return (outerObjRaw, assignObjRaw);
    }

    test('assign properties ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      final (outerObjRaw, assignObjRaw) = assignPropertiesInner(counter);
      doGC();
      expect(counter.value, 0);
      expect(objectRetainCount(assignObjRaw), 0);
      expect(objectRetainCount(outerObjRaw), 0);
      calloc.free(counter);
    });

    Pointer<ObjCObject> retainPropertiesInnerInner(
        Pointer<Int32> counter, RefCountTestObject outerObj) {
      final retainObj = RefCountTestObject.newWithCounter_(counter);
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
      final outerObj = RefCountTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final outerObjRaw = outerObj.pointer;
      expect(objectRetainCount(outerObjRaw), 1);
      final retainObjRaw = retainPropertiesInnerInner(counter, outerObj);
      doGC();
      // retainObj is still around, because outerObj retains a reference to it.
      expect(objectRetainCount(retainObjRaw), 2);
      expect(objectRetainCount(outerObjRaw), 1);
      expect(counter.value, 2);
      expect(outerObj, isNotNull); // Force outerObj to stay in scope.
      return (outerObjRaw, retainObjRaw);
    }

    test('retain properties ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      // The getters of retain properties retain+autorelease the value. So we
      // need an autorelease pool.
      final pool = lib.objc_autoreleasePoolPush();
      final (outerObjRaw, retainObjRaw) = retainPropertiesInner(counter);
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
      final outerObj = RefCountTestObject.newWithCounter_(counter);
      expect(counter.value, 1);

      final copyObj = RefCountTestObject.newWithCounter_(counter);
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

    castFromPointerInnerReleaseAndRetain(int address) {
      final fromCast = RefCounted.castFromPointer(
          Pointer<ObjCObject>.fromAddress(address),
          release: true,
          retain: true);
      expect(fromCast.refCount, 2);
    }

    test('castFromPointer - release and retain', () {
      final obj1 = RefCounted.new1();
      expect(obj1.refCount, 1);

      castFromPointerInnerReleaseAndRetain(obj1.meAsInt());
      doGC();
      expect(obj1.refCount, 1);
    });

    castFromPointerInnerNoReleaseAndRetain(int address) {
      final fromCast = RefCounted.castFromPointer(
          Pointer<ObjCObject>.fromAddress(address),
          release: false,
          retain: false);
      expect(fromCast.refCount, 1);
    }

    test('castFromPointer - no release and retain', () {
      final obj1 = RefCounted.new1();
      expect(obj1.refCount, 1);

      castFromPointerInnerNoReleaseAndRetain(obj1.meAsInt());
      doGC();
      expect(obj1.refCount, 1);
    });

    test('Manual release', () {
      final counter = calloc<Int32>();
      final obj1 = RefCountTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final obj2 = RefCountTestObject.newWithCounter_(counter);
      expect(counter.value, 2);
      final obj3 = RefCountTestObject.newWithCounter_(counter);
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

    Pointer<ObjCObject> manualRetainInner(Pointer<Int32> counter) {
      final obj = RefCountTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final objRaw = obj.retainAndReturnPointer();
      expect(objectRetainCount(objRaw), 2);
      return objRaw;
    }

    manualRetainInner2(Pointer<Int32> counter, Pointer<ObjCObject> objRaw) {
      final obj = RefCountTestObject.castFromPointer(objRaw,
          retain: false, release: true);
      expect(counter.value, 1);
      expect(objectRetainCount(objRaw), 1);
    }

    test('Manual retain', () {
      final counter = calloc<Int32>();
      final objRaw = manualRetainInner(counter);
      doGC();
      expect(counter.value, 1);
      expect(objectRetainCount(objRaw), 1);

      manualRetainInner2(counter, objRaw);
      doGC();
      expect(counter.value, 0);
      expect(objectRetainCount(objRaw), 0);

      calloc.free(counter);
    });

    RefCountTestObject unownedReferenceInner2(Pointer<Int32> counter) {
      final obj1 = RefCountTestObject.new1();
      obj1.setCounter_(counter);
      expect(counter.value, 1);
      expect(objectRetainCount(obj1.pointer), 1);
      final obj1b = obj1.unownedReference();
      expect(counter.value, 1);
      expect(objectRetainCount(obj1b.pointer), 2);

      // Make a second object so that the counter check in unownedReferenceInner
      // sees some sort of change. Otherwise this test could pass just by the GC
      // not working correctly.
      final obj2 = RefCountTestObject.new1();
      obj2.setCounter_(counter);
      expect(counter.value, 2);
      expect(objectRetainCount(obj2.pointer), 1);

      return obj1b;
    }

    Pointer<ObjCObject> unownedReferenceInner(Pointer<Int32> counter) {
      final obj1b = unownedReferenceInner2(counter);
      doGC(); // Collect obj1 and obj2.
      // The underlying object obj1 and obj1b points to still exists, because
      // obj1b took a reference to it. So we still have 1 object.
      expect(counter.value, 1);
      expect(objectRetainCount(obj1b.pointer), 1);
      return obj1b.pointer;
    }

    test("Method that returns a reference we don't own", () {
      // Most ObjC API methods return us a reference without incrementing the
      // ref count (ie, returns us a reference we don't own). So the wrapper
      // object has to take ownership by calling retain. This test verifies that
      // is working correctly by holding a reference to an object returned by a
      // method, after the original wrapper object is gone.
      final counter = calloc<Int32>();
      final obj1bRaw = unownedReferenceInner(counter);
      doGC();
      expect(counter.value, 0);
      expect(objectRetainCount(obj1bRaw), 0);
      calloc.free(counter);
    });

    void largeRefCountInner(Pointer<Int32> counter) {
      final obj = RefCountTestObject.newWithCounter_(counter);
      expect(counter.value, 1);
      final objRefs = <RefCountTestObject>[];
      for (int i = 1; i < 1000; ++i) {
        final expectedCount = i < 128 ? i : 128;
        expect(objectRetainCount(obj.pointer), expectedCount);
        objRefs.add(RefCountTestObject.castFromPointer(obj.pointer,
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
