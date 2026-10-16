// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'autorelease_pool_test_bindings.dart';

void main() {
  test('autorelease pool method configuration', () {
    final outerPool = objc_autoreleasePoolPush();

    // 1. Method WITH autorelease pool
    final counterWithPool = calloc<Int32>()..value = 0;
    final objWithPool = AutoreleasePoolTestObject.makeAndAutoreleaseWithPool(
      counterWithPool,
    );
    expect(counterWithPool.value, 1);
    // Release Dart's reference to the object.
    objWithPool.ref.release();
    // Because the call was wrapped in autoReleasePool, the autorelease
    // reference was already popped.
    expect(counterWithPool.value, 0);

    // 2. Method WITHOUT autorelease pool
    final counterWithoutPool = calloc<Int32>()..value = 0;
    final objWithoutPool =
        AutoreleasePoolTestObject.makeAndAutoreleaseWithoutPool(
          counterWithoutPool,
        );
    expect(counterWithoutPool.value, 1);
    // Release Dart's reference to the object.
    objWithoutPool.ref.release();
    // Because the call was NOT wrapped in autoReleasePool, the outer pool
    // still holds a reference.
    expect(counterWithoutPool.value, 1);

    objc_autoreleasePoolPop(outerPool);
    // Now the object is destroyed.
    expect(counterWithoutPool.value, 0);

    calloc.free(counterWithPool);
    calloc.free(counterWithoutPool);
  });
}
