// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' as ffi;

import 'package:test/test.dart';

import 'cpp_extern_c_test_bindings.dart';

void main() {
  group('CppExternC', () {
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
      // Signature checks on the tear-offs. The functions are never invoked, so
      // no native library is needed.
      expect(add, isA<int Function(int, int)>());
    });

    test('function inside a nested extern "C" block', () {
      expect(deep, isA<int Function()>());
    });

    test('function in the braceless extern "C" form', () {
      expect(reset, isA<void Function()>());
    });

    test('enum inside an extern "C" block in a namespace', () {
      expect(ns$Flag.off.value, 0);
      expect(ns$Flag.on.value, 1);
    });

    test('declarations outside any extern "C" block still parse', () {
      expect(outside, isA<int Function(double)>());
    });
  });
}
