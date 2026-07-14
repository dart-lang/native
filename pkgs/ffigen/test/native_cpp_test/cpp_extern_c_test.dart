// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'cpp_extern_c_test_bindings.dart';

void main() {
  group('CppExternC', () {
    test('declarations inside extern "C" blocks are generated', () {
      expect(Fruit, isNotNull);
      expect(Pair, isNotNull);
      expect(Number, isNotNull);
    });

    test('enum inside an extern "C" block', () {
      expect(Fruit.apple.value, 1);
      expect(Fruit.banana.value, 2);
    });

    test('enum inside an extern "C" block in a namespace', () {
      expect(ns$Flag.off.value, 0);
      expect(ns$Flag.on.value, 1);
    });
  });
}
