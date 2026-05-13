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
import 'arc_test_bindings.dart';
import 'util.dart';

void main() {
  group('ARC', () {
    setUpAll(() {
      loadLibrary();
    });

    void newMethodsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject();
      obj1.setCounter(counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 2);

      final obj2b = ArcTestObject.fromPointer(
        obj2.ref.pointer,
        retain: true,
        release: true,
      );
      expect(obj2b, isNotNull);

      final obj2c = ArcTestObject.fromPointer(
        obj2.ref.pointer,
        retain: true,
        release: true,
      );
      expect(obj2c, isNotNull);
    }

    test('new methods ref count correctly', () {
      // To get the GC to work correctly, the references to the objects all have
      // to be in a separate function.
      final counter = calloc<Int32>()..value = 0;
      newMethodsInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    void allocMethodsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.alloc().initWithCounter(counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.as(ArcTestObject.alloc().init());
      obj2.setCounter(counter);
      expect(counter.value, 2);
      final obj3 = ArcTestObject.allocTheThing().initWithCounter(counter);
      expect(counter.value, 3);

      expect(obj1, isNotNull); // Force obj1 to stay in scope.
      expect(obj2, isNotNull); // Force obj2 to stay in scope.
      expect(obj3, isNotNull); // Force obj3 to stay in scope.
    }

    test('alloc and init methods ref count correctly', () {
      final counter = calloc<Int32>()..value = 0;
      allocMethodsInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    void copyMethodsInner(Pointer<Int32> counter) {
      final pool = objc_autoreleasePoolPush();
      final obj1 = ArcTestObject.newWithCounter(counter);
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

      objc_autoreleasePoolPop(pool);
      expect(counter.value, 9);

      expect(obj1, isNotNull);
      expect(obj2, isNotNull);
      expect(obj3, isNotNull);
      expect(obj4, isNotNull);
      expect(obj5, isNotNull);
      expect(obj6, isNotNull);
      expect(obj7, isNotNull);
      expect(obj8, isNotNull);
      expect(obj9, isNotNull);
    }

    test('copy methods ref count correctly', () {
      final counter = calloc<Int32>()..value = 0;
      copyMethodsInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    void autoreleaseMethodsInner(Pointer<Int32> counter) {
      final obj1 = ArcTestObject.makeAndAutorelease(counter);
      expect(counter.value, 1);
    }

    test('autorelease methods ref count correctly', () {
      final counter = calloc<Int32>()..value = 0;

      final pool1 = objc_autoreleasePoolPush();
      autoreleaseMethodsInner(counter);
      doGC();
      // The autorelease pool is still holding a reference to the object.
      expect(counter.value, 1);
      objc_autoreleasePoolPop(pool1);
      expect(counter.value, 0);

      final pool2 = objc_autoreleasePoolPush();
      final obj2 = ArcTestObject.makeAndAutorelease(counter);
      expect(counter.value, 1);
      doGC();
      expect(counter.value, 1);
      objc_autoreleasePoolPop(pool2);
      // The obj2 variable still holds a reference to the object.
      expect(counter.value, 1);
      obj2.ref.release();
      expect(counter.value, 0);

      calloc.free(counter);
    }, skip: !canDoGC);

    void assignPropertiesInnerInner(
      Pointer<Int32> counter,
      ArcTestObject outerObj,
    ) {
      final assignObj = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 2);
      outerObj.assignedProperty = assignObj;
      expect(counter.value, 2);
      expect(assignObj, outerObj.assignedProperty);
    }

    void assignPropertiesInner(Pointer<Int32> counter) {
      final outerObj = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      assignPropertiesInnerInner(counter, outerObj);
      doGC();
      // assignObj has been cleaned up.
      expect(counter.value, 1);
      expect(outerObj, isNotNull); // Force outerObj to stay in scope.
    }

    test('assign properties ref count correctly', () {
      final counter = calloc<Int32>()..value = 0;
      assignPropertiesInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    void retainPropertiesInnerInner(
      Pointer<Int32> counter,
      ArcTestObject outerObj,
    ) {
      final retainObj = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 2);
      outerObj.retainedProperty = retainObj;
      expect(counter.value, 2);
      expect(retainObj, outerObj.retainedProperty);
    }

    void retainPropertiesInner(Pointer<Int32> counter) {
      final outerObj = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      retainPropertiesInnerInner(counter, outerObj);
      doGC();
      // retainObj is still around, because outerObj retains a reference to it.
      expect(counter.value, 2);
      expect(outerObj, isNotNull); // Force outerObj to stay in scope.
    }

    test('retain properties ref count correctly', () {
      final counter = calloc<Int32>()..value = 0;
      // The getters of retain properties retain+autorelease the value. So we
      // need an autorelease pool.
      final pool = objc_autoreleasePoolPush();
      retainPropertiesInner(counter);
      doGC();
      expect(counter.value, 1);
      objc_autoreleasePoolPop(pool);
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    void copyPropertiesInner(Pointer<Int32> counter) {
      final outerObj = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 1);

      final copyObj = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 2);
      outerObj.copiedProperty = copyObj;
      // Copy properties make a copy of the object, so now we have 3 objects.
      expect(counter.value, 3);
      expect(copyObj, isNot(outerObj.copiedProperty));

      final anotherCopy = outerObj.copiedProperty;
      // The getter doesn't copy the object.
      expect(counter.value, 3);
      expect(anotherCopy, outerObj.copiedProperty);

      expect(outerObj, isNotNull);
      expect(copyObj, isNotNull);
      expect(anotherCopy, isNotNull);
    }

    test('copy properties ref count correctly', () {
      final counter = calloc<Int32>()..value = 0;
      // The getters of copy properties retain+autorelease the value. So we need
      // an autorelease pool.
      final pool = objc_autoreleasePoolPush();
      copyPropertiesInner(counter);
      doGC();
      expect(counter.value, 1);
      objc_autoreleasePoolPop(pool);
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    test('Manual release', () {
      final counter = calloc<Int32>()..value = 0;
      final obj1 = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      final obj2 = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 2);
      final obj3 = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 3);

      obj1.ref.release();
      expect(counter.value, 2);
      obj2.ref.release();
      expect(counter.value, 1);
      obj3.ref.release();
      expect(counter.value, 0);

      expect(() => obj1.ref.release(), throwsStateError);
      calloc.free(counter);
    });

    void largeRefCountInner(Pointer<Int32> counter) {
      final obj = ArcTestObject.newWithCounter(counter);
      expect(counter.value, 1);
      final objRefs = <ArcTestObject>[];
      for (int i = 1; i < 1000; ++i) {
        objRefs.add(
          ArcTestObject.fromPointer(
            obj.ref.pointer,
            retain: true,
            release: true,
          ),
        );
      }
      expect(counter.value, 1);
      expect(objRefs, isNotEmpty);
    }

    test('Consumed arguments', () {
      final counter = calloc<Int32>()..value = 0;
      ArcTestObject? obj1 = ArcTestObject.newWithCounter(counter);

      expect(counter.value, 1);

      ArcTestObject.consumeArg(obj1);

      expect(counter.value, 1);

      obj1 = null;
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    test('objectRetainCount large ref count', () {
      // Most ObjC API methods return us a reference without incrementing the
      // ref count (ie, returns us a reference we don't own). So the wrapper
      // object has to take ownership by calling retain. This test verifies that
      // is working correctly by holding a reference to an object returned by a
      // method, after the original wrapper object is gone.
      final counter = calloc<Int32>()..value = 0;
      largeRefCountInner(counter);
      doGC();
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);

    test('Destroy on main thread', () async {
      const numTestObjects = 1000;

      final dtorCounter = calloc<Int32>();
      final dtorOnMainThreadCounter = calloc<Int32>();
      final objects = <ArcDtorTestObject>[];
      for (var i = 0; i < numTestObjects; ++i) {
        objects.add(
          ArcDtorTestObject.alloc().initWithCounters(
            dtorCounter,
            onMainThread: dtorOnMainThreadCounter,
          ),
        );
      }
      objects.clear();

      while (dtorCounter.value < numTestObjects) {
        await flutterDoGC();
      }
      expect(dtorOnMainThreadCounter.value, numTestObjects);
    }, skip: !isFlutterTester);
  });
}
