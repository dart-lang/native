// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: unused_local_variable

// Objective C support is only available on mac.
@TestOn('mac-os')
// Keep in sync with static_func_test.dart. These are the same tests, but using
// @Native.
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'static_func_native_bindings.dart';
import 'util.dart';

typedef IntBlock = ObjCBlock_Int32_Int32;

void main() {
  group('static functions', () {
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
      DynamicLibrary.open(dylib.absolute.path);

      generateBindingsForCoverage('static_func');
    });

    Pointer<Int32> staticFuncOfObjectRefCountTest(Allocator alloc) {
      final counter = alloc<Int32>();
      counter.value = 0;

      final obj = StaticFuncTestObj.newWithCounter(counter);
      expect(counter.value, 1);

      final pool = objc_autoreleasePoolPush();
      final outputObj = staticFuncOfObject(obj);
      objc_autoreleasePoolPop(pool);
      expect(obj, outputObj);
      expect(counter.value, 1);

      return counter;
    }

    test(
      'Objects passed through static functions have correct ref counts',
      () {
        using((Arena arena) {
          final (counter) = staticFuncOfObjectRefCountTest(arena);
          doGC();
          expect(counter.value, 0);
        });
      },
      skip: !canDoGC,
    );

    Pointer<Int32> staticFuncOfNullableObjectRefCountTest(Allocator alloc) {
      final counter = alloc<Int32>();
      counter.value = 0;

      final obj = StaticFuncTestObj.newWithCounter(counter);
      expect(counter.value, 1);

      final pool = objc_autoreleasePoolPush();
      final outputObj = staticFuncOfNullableObject(obj);
      objc_autoreleasePoolPop(pool);
      expect(obj, outputObj);
      expect(counter.value, 1);

      return counter;
    }

    test(
      'Nullables passed through static functions have correct ref counts',
      () {
        using((Arena arena) {
          final (counter) = staticFuncOfNullableObjectRefCountTest(arena);
          doGC();
          expect(counter.value, 0);

          expect(staticFuncOfNullableObject(null), isNull);
        });
      },
      skip: !canDoGC,
    );

    Pointer<ObjCBlockImpl> staticFuncOfBlockRefCountTest() {
      final block = IntBlock.fromFunction((int x) => 2 * x);
      expect(blockRetainCount(block.ref.pointer.cast()), 1);

      final pool = objc_autoreleasePoolPush();
      final outputBlock = staticFuncOfBlock(block);
      objc_autoreleasePoolPop(pool);
      expect(block, outputBlock);
      expect(blockRetainCount(block.ref.pointer.cast()), 2);

      return block.ref.pointer;
    }

    test(
      'Blocks passed through static functions have correct ref counts',
      () {
        final rawBlock = staticFuncOfBlockRefCountTest();
        doGC();
        expect(blockRetainCount(rawBlock), 0);
      },
      skip: !canDoGC,
    );

    Pointer<Int32> staticFuncReturnsRetainedRefCountTest(Allocator alloc) {
      final counter = alloc<Int32>();
      counter.value = 0;

      final outputObj = staticFuncReturnsRetained(counter);
      expect(counter.value, 1);

      return counter;
    }

    test('Objects returned from static functions with NS_RETURNS_RETAINED '
        'have correct ref counts', () {
      using((Arena arena) {
        final (counter) = staticFuncReturnsRetainedRefCountTest(arena);
        doGC();
        expect(counter.value, 0);
      });
    }, skip: !canDoGC);

    Pointer<Int32> staticFuncOfObjectReturnsRetainedRefCountTest(
      Allocator alloc,
    ) {
      final counter = alloc<Int32>();
      counter.value = 0;

      final obj = StaticFuncTestObj.newWithCounter(counter);
      expect(counter.value, 1);

      final outputObj = staticFuncReturnsRetainedArg(obj);
      expect(obj, outputObj);
      expect(counter.value, 1);

      return counter;
    }

    test('Objects passed through static functions with NS_RETURNS_RETAINED '
        'have correct ref counts', () {
      using((Arena arena) {
        final (counter) = staticFuncOfObjectReturnsRetainedRefCountTest(arena);
        doGC();
        expect(counter.value, 0);
      });
    }, skip: !canDoGC);

    test('Objects passed to static functions that consume them '
        'have correct ref counts', () {
      final counter = calloc<Int32>();
      StaticFuncTestObj? obj1 = StaticFuncTestObj.newWithCounter(counter);
      final obj1raw = obj1.ref.pointer;

      expect(objectRetainCount(obj1raw), 1);
      expect(counter.value, 1);

      staticFuncConsumesArg(obj1);

      expect(objectRetainCount(obj1raw), 1);
      expect(counter.value, 1);

      obj1 = null;
      doGC();
      expect(objectRetainCount(obj1raw), 0);
      expect(counter.value, 0);
      calloc.free(counter);
    }, skip: !canDoGC);
  });
}
