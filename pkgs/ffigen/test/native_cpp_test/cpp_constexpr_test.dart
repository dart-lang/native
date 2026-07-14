// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'cpp_constexpr_test_bindings.dart';

void main() {
  group('CppConstexpr', () {
    test('top-level constexpr constants', () {
      expect(topInt, 5);
      expect(topDouble, 3.5);
      expect(topStr, 'hello');
      expect(topDerived, 10);
    });

    test('constexpr in a namespace', () {
      expect(ns$nsInt, 42);
    });

    test('constexpr in a nested namespace', () {
      expect(ns$inner$nsInt, 43);
    });

    test('static constexpr member of a struct', () {
      expect(Box$memberInt, 7);
      expect(Box$memberDouble, 2.5);
    });

    test('static constexpr member of a class', () {
      expect(Widget$classInt, 99);
    });

    test('static constexpr member of a class in a namespace', () {
      expect(scoped$Gadget$gadgetInt, 100);
    });
  });
}
