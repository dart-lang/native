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
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../test_utils.dart';
import 'ref_count_bindings.dart';
import 'util.dart';

void main() {
  late RefCountTestObjCLibrary lib;

  group('Reference counting', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(
        path.join(
          packagePathForTests,
          '..',
          'objective_c',
          'test',
          'objective_c.dylib',
        ),
      );
      final dylib = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'objc_test.dylib',
        ),
      );
      verifySetupFile(dylib);
      lib = RefCountTestObjCLibrary(DynamicLibrary.open(dylib.absolute.path));

      generateBindingsForCoverage('ref_count');
    });

    test('objectRetainCount edge cases', () {
      expect(objectRetainCount(nullptr), 0);
      expect(objectRetainCount(Pointer.fromAddress(0x1234)), 0);
    });

    (Pointer<ObjCObjectImpl>, Pointer<ObjCObjectImpl>) newMethodsInner(
      Pointer<Int32> counter,
    ) {
      final obj1 = RefCountTestObject();
      obj1.setCounter(counter);
      expect(counter.value, 1);
      final obj2 = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 2);

      final obj1raw = obj1.ref.pointer;
      final obj2raw = obj2.ref.pointer;

      expect(objectRetainCount(obj1raw), greaterThan(0));
      expect(objectRetainCount(obj2raw), greaterThan(0));

      final obj2b = RefCountTestObject.fromPointer(
        obj2raw,
        retain: true,
        release: true,
      );
      expect(objectRetainCount(obj2b.ref.pointer), greaterThan(0));

      final obj2c = RefCountTestObject.fromPointer(
        obj2raw,
        retain: true,
        release: true,
      );
      expect(objectRetainCount(obj2c.ref.pointer), greaterThan(0));

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
    }, skip: !canDoGC);

    (Pointer<ObjCObjectImpl>, Pointer<ObjCObjectImpl>, Pointer<ObjCObjectImpl>)
    allocMethodsInner(Pointer<Int32> counter) {
      final obj1 = RefCountTestObject.alloc().initWithCounter(counter);
      expect(counter.value, 1);
      final obj2 = RefCountTestObject.as(RefCountTestObject.alloc().init());
      obj2.setCounter(counter);
      expect(counter.value, 2);
      final obj3 = RefCountTestObject.allocTheThing().initWithCounter(counter);
      expect(counter.value, 3);

      final obj1raw = obj1.ref.pointer;
      final obj2raw = obj2.ref.pointer;
      final obj3raw = obj3.ref.pointer;

      expect(objectRetainCount(obj1raw), greaterThan(0));
      expect(objectRetainCount(obj2raw), greaterThan(0));
      expect(objectRetainCount(obj3raw), greaterThan(0));

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
    }, skip: !canDoGC);

    (
      Pointer<ObjCObjectImpl>,
      Pointer<ObjCObjectImpl>,
      Pointer<ObjCObjectImpl>,
      Pointer<ObjCObjectImpl>,
      Pointer<ObjCObjectImpl>,
      Pointer<ObjCObjectImpl>,
      Pointer<ObjCObjectImpl>,
      Pointer<ObjCObjectImpl>,
      Pointer<ObjCObjectImpl>,
    )
    copyMethodsInner(Pointer<Int32> counter) {
      final pool = lib.objc_autoreleasePoolPush();
      final obj1 = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      final obj2 = obj1.copyMe();
      expect(counter.value, 2);
      final obj3 = obj1.mutableCopyMe();
      expect(counter.value, 3);
      final obj4 = obj1.copyWithZone$1(nullptr);
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

      final obj1raw = obj1.ref.pointer;
      final obj2raw = obj2.ref.pointer;
      final obj3raw = obj3.ref.pointer;
      final obj4raw = obj4.ref.pointer;
      final obj5raw = obj5.ref.pointer;
      final obj6raw = obj6.ref.pointer;
      final obj7raw = obj7.ref.pointer;
      final obj8raw = obj8.ref.pointer;
      final obj9raw = obj9.ref.pointer;

      expect(objectRetainCount(obj1raw), greaterThan(0));
      expect(objectRetainCount(obj2raw), greaterThan(0));
      expect(objectRetainCount(obj3raw), greaterThan(0));
      expect(objectRetainCount(obj4raw), greaterThan(0));
      expect(objectRetainCount(obj5raw), greaterThan(0));
      expect(objectRetainCount(obj6raw), greaterThan(0));
      expect(
        objectRetainCount(obj7raw),
        2,
      ); // One ref in autorelease pogreaterThat(0)l.
      expect(
        objectRetainCount(obj8raw),
        2,
      ); // One ref in autorelease pogreaterThat(0)l.
      expect(objectRetainCount(obj9raw), greaterThan(0));

      lib.objc_autoreleasePoolPop(pool);
      expect(objectRetainCount(obj1raw), greaterThan(0));
      expect(objectRetainCount(obj2raw), greaterThan(0));
      expect(objectRetainCount(obj3raw), greaterThan(0));
      expect(objectRetainCount(obj4raw), greaterThan(0));
      expect(objectRetainCount(obj5raw), greaterThan(0));
      expect(objectRetainCount(obj6raw), greaterThan(0));
      expect(objectRetainCount(obj7raw), greaterThan(0));
      expect(objectRetainCount(obj8raw), greaterThan(0));
      expect(objectRetainCount(obj9raw), greaterThan(0));

      return (
        obj1raw,
        obj2raw,
        obj3raw,
        obj4raw,
        obj5raw,
        obj6raw,
        obj7raw,
        obj8raw,
        obj9raw,
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
        obj9raw,
      ) = copyMethodsInner(
        counter,
      );
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
    }, skip: !canDoGC);

    Pointer<ObjCObjectImpl> autoreleaseMethodsInner(Pointer<Int32> counter) {
      final obj1 = RefCountTestObject.makeAndAutorelease(counter);
      expect(counter.value, 1);

      final obj1raw = obj1.ref.pointer;
      expect(objectRetainCount(obj1raw), greaterThan(0));
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
      expect(objectRetainCount(obj1raw), greaterThan(0));
      lib.objc_autoreleasePoolPop(pool1);
      expect(counter.value, 0);
      expect(objectRetainCount(obj1raw), 0);

      final pool2 = lib.objc_autoreleasePoolPush();
      final obj2 = RefCountTestObject.makeAndAutorelease(counter);
      final obj2raw = obj2.ref.pointer;
      expect(counter.value, 1);
      expect(objectRetainCount(obj2raw), greaterThan(0));
      doGC();
      expect(counter.value, 1);
      expect(objectRetainCount(obj2raw), greaterThan(0));
      lib.objc_autoreleasePoolPop(pool2);
      // The obj2 variable still holds a reference to the object.
      expect(counter.value, 1);
      expect(objectRetainCount(obj2raw), greaterThan(0));
      obj2.ref.release();
      expect(counter.value, 0);
      expect(objectRetainCount(obj2raw), 0);

      calloc.free(counter);
    }, skip: !canDoGC);

    Pointer<ObjCObjectImpl> assignPropertiesInnerInner(
      Pointer<Int32> counter,
      RefCountTestObject outerObj,
    ) {
      final assignObj = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 2);
      final assignObjRaw = assignObj.ref.pointer;
      expect(objectRetainCount(assignObjRaw), greaterThan(0));
      outerObj.assignedProperty = assignObj;
      expect(counter.value, 2);
      expect(assignObj, outerObj.assignedProperty);
      expect(objectRetainCount(assignObjRaw), greaterThan(0));
      // To test that outerObj isn't holding a reference to assignObj, we let
      // assignObj go out of scope, but keep outerObj in scope. This is
      // dangerous because outerObj now has a dangling reference, so don't
      // access that reference.
      return assignObjRaw;
    }

    (Pointer<ObjCObjectImpl>, Pointer<ObjCObjectImpl>) assignPropertiesInner(
      Pointer<Int32> counter,
    ) {
      final outerObj = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      final outerObjRaw = outerObj.ref.pointer;
      expect(objectRetainCount(outerObjRaw), greaterThan(0));
      final assignObjRaw = assignPropertiesInnerInner(counter, outerObj);
      doGC();
      // assignObj has been cleaned up.
      expect(counter.value, 1);
      expect(objectRetainCount(assignObjRaw), 0);
      expect(objectRetainCount(outerObjRaw), greaterThan(0));
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
    }, skip: !canDoGC);

    Pointer<ObjCObjectImpl> retainPropertiesInnerInner(
      Pointer<Int32> counter,
      RefCountTestObject outerObj,
    ) {
      final retainObj = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 2);
      final retainObjRaw = retainObj.ref.pointer;
      expect(objectRetainCount(retainObjRaw), greaterThan(0));
      outerObj.retainedProperty = retainObj;
      expect(counter.value, 2);
      expect(retainObj, outerObj.retainedProperty);
      expect(objectRetainCount(retainObjRaw), greaterThan(0));
      return retainObjRaw;
    }

    (Pointer<ObjCObjectImpl>, Pointer<ObjCObjectImpl>) retainPropertiesInner(
      Pointer<Int32> counter,
    ) {
      final outerObj = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      final outerObjRaw = outerObj.ref.pointer;
      expect(objectRetainCount(outerObjRaw), greaterThan(0));
      final retainObjRaw = retainPropertiesInnerInner(counter, outerObj);
      doGC();
      // retainObj is still around, because outerObj retains a reference to it.
      expect(objectRetainCount(retainObjRaw), greaterThan(0));
      expect(objectRetainCount(outerObjRaw), greaterThan(0));
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
      expect(objectRetainCount(retainObjRaw), greaterThan(0));
      expect(objectRetainCount(outerObjRaw), 0);
      expect(counter.value, 1);
      lib.objc_autoreleasePoolPop(pool);
      expect(objectRetainCount(retainObjRaw), 0);
      expect(objectRetainCount(outerObjRaw), 0);
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    (Pointer<ObjCObjectImpl>, Pointer<ObjCObjectImpl>, Pointer<ObjCObjectImpl>)
    copyPropertiesInner(Pointer<Int32> counter) {
      final outerObj = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 1);

      final copyObj = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 2);
      outerObj.copiedProperty = copyObj;
      // Copy properties make a copy of the object, so now we have 3 objects.
      expect(counter.value, 3);
      expect(copyObj, isNot(outerObj.copiedProperty));

      final anotherCopy = outerObj.copiedProperty;
      // The getter doesn't copy the object.
      expect(counter.value, 3);
      expect(anotherCopy, outerObj.copiedProperty);

      final outerObjRaw = outerObj.ref.pointer;
      final copyObjRaw = copyObj.ref.pointer;
      final anotherCopyRaw = anotherCopy.ref.pointer;

      expect(objectRetainCount(outerObjRaw), greaterThan(0));
      expect(objectRetainCount(copyObjRaw), greaterThan(0));
      expect(objectRetainCount(anotherCopyRaw), greaterThan(0));

      return (outerObjRaw, copyObjRaw, anotherCopyRaw);
    }

    test('copy properties ref count correctly', () {
      final counter = calloc<Int32>();
      counter.value = 0;
      // The getters of copy properties retain+autorelease the value. So we need
      // an autorelease pool.
      final pool = lib.objc_autoreleasePoolPush();
      final (outerObjRaw, copyObjRaw, anotherCopyRaw) = copyPropertiesInner(
        counter,
      );
      doGC();
      expect(counter.value, 1);
      expect(objectRetainCount(outerObjRaw), 0);
      expect(objectRetainCount(copyObjRaw), 0);
      expect(objectRetainCount(anotherCopyRaw), greaterThan(0));
      lib.objc_autoreleasePoolPop(pool);
      expect(counter.value, 0);
      expect(objectRetainCount(outerObjRaw), 0);
      expect(objectRetainCount(copyObjRaw), 0);
      expect(objectRetainCount(anotherCopyRaw), 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    castFromPointerInnerReleaseAndRetain(int address) {
      final fromCast = RefCounted.fromPointer(
        Pointer<ObjCObjectImpl>.fromAddress(address),
        release: true,
        retain: true,
      );
      expect(fromCast.refCount, 2);
    }

    test('fromPointer - release and retain', () {
      final obj1 = RefCounted();
      expect(obj1.refCount, 1);

      castFromPointerInnerReleaseAndRetain(obj1.meAsInt());
      doGC();
      expect(obj1.refCount, 1);
    }, skip: !canDoGC);

    castFromPointerInnerNoReleaseAndRetain(int address) {
      final fromCast = RefCounted.fromPointer(
        Pointer<ObjCObjectImpl>.fromAddress(address),
        release: false,
        retain: false,
      );
      expect(fromCast.refCount, 1);
    }

    test('fromPointer - no release and retain', () {
      final obj1 = RefCounted();
      expect(obj1.refCount, 1);

      castFromPointerInnerNoReleaseAndRetain(obj1.meAsInt());
      doGC();
      expect(obj1.refCount, 1);
    }, skip: !canDoGC);

    test('Manual release', () {
      final counter = calloc<Int32>();
      final obj1 = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      final obj2 = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 2);
      final obj3 = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 3);

      final obj1raw = obj1.ref.pointer;
      final obj2raw = obj2.ref.pointer;
      final obj3raw = obj3.ref.pointer;

      expect(objectRetainCount(obj1raw), greaterThan(0));
      expect(objectRetainCount(obj2raw), greaterThan(0));
      expect(objectRetainCount(obj3raw), greaterThan(0));

      obj1.ref.release();
      expect(counter.value, 2);
      obj2.ref.release();
      expect(counter.value, 1);
      obj3.ref.release();
      expect(counter.value, 0);

      expect(() => obj1.ref.release(), throwsStateError);
      calloc.free(counter);

      expect(objectRetainCount(obj1raw), 0);
      expect(objectRetainCount(obj2raw), 0);
      expect(objectRetainCount(obj3raw), 0);
    });

    Pointer<ObjCObjectImpl> manualRetainInner(Pointer<Int32> counter) {
      final obj = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      final objRaw = obj.ref.retainAndReturnPointer();
      expect(objectRetainCount(objRaw), greaterThan(0));
      return objRaw;
    }

    manualRetainInner2(Pointer<Int32> counter, Pointer<ObjCObjectImpl> objRaw) {
      final obj = RefCountTestObject.fromPointer(
        objRaw,
        retain: false,
        release: true,
      );
      expect(counter.value, 1);
      expect(objectRetainCount(objRaw), greaterThan(0));
    }

    test('Manual retain', () {
      final counter = calloc<Int32>();
      final objRaw = manualRetainInner(counter);
      doGC();
      expect(counter.value, 1);
      expect(objectRetainCount(objRaw), greaterThan(0));

      manualRetainInner2(counter, objRaw);
      doGC();
      expect(counter.value, 0);
      expect(objectRetainCount(objRaw), 0);

      calloc.free(counter);
    }, skip: !canDoGC);

    RefCountTestObject unownedReferenceInner2(Pointer<Int32> counter) {
      final obj1 = RefCountTestObject();
      obj1.setCounter(counter);
      expect(counter.value, 1);
      expect(objectRetainCount(obj1.ref.pointer), greaterThan(0));
      final obj1b = obj1.unownedReference();
      expect(counter.value, 1);
      expect(objectRetainCount(obj1b.ref.pointer), greaterThan(0));

      // Make a second object so that the counter check in unownedReferenceInner
      // sees some sort of change. Otherwise this test could pass just by the GC
      // not working correctly.
      final obj2 = RefCountTestObject();
      obj2.setCounter(counter);
      expect(counter.value, 2);
      expect(objectRetainCount(obj2.ref.pointer), greaterThan(0));

      return obj1b;
    }

    Pointer<ObjCObjectImpl> unownedReferenceInner(Pointer<Int32> counter) {
      final obj1b = unownedReferenceInner2(counter);
      doGC(); // Collect obj1 and obj2.
      // The underlying object obj1 and obj1b points to still exists, because
      // obj1b took a reference to it. So we still have 1 object.
      expect(counter.value, 1);
      expect(objectRetainCount(obj1b.ref.pointer), greaterThan(0));
      return obj1b.ref.pointer;
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
    }, skip: !canDoGC);

    void largeRefCountInner(Pointer<Int32> counter) {
      final obj = RefCountTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      final objRefs = <RefCountTestObject>[];
      for (int i = 1; i < 1000; ++i) {
        final expectedCount = i < 128 ? i : 128;
        expect(objectRetainCount(obj.ref.pointer), expectedCount);
        objRefs.add(
          RefCountTestObject.fromPointer(
            obj.ref.pointer,
            retain: true,
            release: true,
          ),
        );
      }
      expect(counter.value, 1);
    }

    test('Consumed arguments', () {
      final counter = calloc<Int32>();
      RefCountTestObject? obj1 = RefCountTestObject.newWithCounter(counter);
      final obj1raw = obj1.ref.pointer;

      expect(objectRetainCount(obj1raw), greaterThan(0));
      expect(counter.value, 1);

      RefCountTestObject.consumeArg(obj1);

      expect(objectRetainCount(obj1raw), greaterThan(0));
      expect(counter.value, 1);

      obj1 = null;
      doGC();
      expect(objectRetainCount(obj1raw), 0);
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    test('objectRetainCount large ref count', () {
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
    }, skip: !canDoGC);
  });
}
