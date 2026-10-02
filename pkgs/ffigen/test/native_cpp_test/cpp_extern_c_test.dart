// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' as ffi;

import 'package:test/test.dart';

import 'cpp_extern_c_test_bindings.dart';

void main() {
  group('CppExternC', () {
    setUp(reset);

    test('enum inside an extern "C" block', () {
      expect(Fruit.apple.value, 1);
      expect(Fruit.banana.value, 2);
      expect(Fruit.fromValue(2), Fruit.banana);
    });

    test('struct and union inside an extern "C" block', () {
      expect(ffi.sizeOf<Pair>(), ffi.sizeOf<ffi.Int>() * 2);
      expect(ffi.sizeOf<Number>(), ffi.sizeOf<ffi.Int>());
    });

    test('function inside an extern "C" block', () {
      expect(add(2, 3), 5);
    });

    test('global inside an extern "C" block', () {
      expect(counter, 0);
      counter = 5;
      expect(counter, 5);
    });

    test('function inside a nested extern "C" block', () {
      expect(deep(), 42);
    });

    test('function in the braceless extern "C" form', () {
      counter = 9;
      reset();
      expect(counter, 0);
    });

    test('enum inside an extern "C" block in a namespace', () {
      expect(ns$Flag.off.value, 0);
      expect(ns$Flag.on.value, 1);
    });

    test('function outside any extern "C" block has C++ linkage', () {
      outsideCounter = 10;
      expect(outside(2.5), 12);
    });

    test('global outside any extern "C" block has C++ linkage', () {
      outsideCounter = 3;
      expect(outsideCounter, 3);
      expect(outside(0), 3);
      reset();
      expect(outsideCounter, 0);
    });

    test('symbol address of a global with C++ linkage', () {
      outsideCounter = 21;
      expect(addresses.outsideCounter.value, 21);
      addresses.outsideCounter.value = 22;
      expect(outsideCounter, 22);
    });

    test('extern "C++" nested inside extern "C" has C++ linkage', () {
      expect(nestedCpp(21), 42);
    });

    test('function pointer parameter through the wrapper', () {
      final fn = ffi.Pointer.fromFunction<ffi.Int Function(ffi.Int)>(
        _addOne,
        0,
      );
      expect(applyTwice(fn, 5), 7);
    });
  });
}

int _addOne(int x) => x + 1;
