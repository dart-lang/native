// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'cpp_namespace_enum_test_bindings.dart';

void main() {
  group('CppNamespaceEnum', () {
    test('enum in a namespace', () {
      expect(outer$Color.red.value, 0);
      expect(outer$Color.blue.value, 2);
    });

    test('enum class in a nested namespace', () {
      expect(outer$inner$Color.cyan.value, 10);
      expect(outer$inner$Color.magenta.value, 20);
    });

    test('enum nested in a class in a namespace', () {
      expect(outer$Palette$Tone.light.value, 1);
      expect(outer$Palette$Tone.dark.value, 2);
    });

    test('enum nested in a class at global scope', () {
      expect(GlobalPalette$Shade.dim.value, 7);
      expect(GlobalPalette$Shade.bright.value, 8);
    });

    test('enum nested in a struct at global scope', () {
      expect(GlobalBox$State.closed.value, 30);
      expect(GlobalBox$State.open.value, 31);
    });

    test('enums sharing a leaf name across namespaces are distinct', () {
      // All three are named `Color`, so each has to keep its scope path.
      expect(outer$Color.red.value, 0);
      expect(outer$inner$Color.cyan.value, 10);
      expect(other$Color.black.value, 100);
    });
  });
}
