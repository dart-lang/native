// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'cpp_namespace_enum_test_bindings.dart';

void main() {
  group('CppNamespaceEnum', () {
    test('enums in namespaces are generated with flattened names', () {
      expect(GlobalBox$State, isNotNull);
      expect(GlobalPalette$Shade, isNotNull);
      expect(outer$Color, isNotNull);
      expect(outer$inner$Color, isNotNull);
      expect(outer$Palette$Tone, isNotNull);
      expect(other$Color, isNotNull);
    });

    test('unscoped enum in a single namespace', () {
      expect(outer$Color.red.value, 0);
      expect(outer$Color.green.value, 1);
      expect(outer$Color.blue.value, 2);
    });

    test('scoped enum (enum class) in a nested namespace', () {
      expect(outer$inner$Color.cyan.value, 10);
      expect(outer$inner$Color.magenta.value, 20);
    });

    test('scoped enum nested in a class inside a namespace', () {
      expect(outer$Palette$Tone.light.value, 1);
      expect(outer$Palette$Tone.dark.value, 2);
    });

    test('scoped enum nested in a class at global scope', () {
      expect(GlobalPalette$Shade.dim.value, 7);
      expect(GlobalPalette$Shade.bright.value, 8);
    });

    test('scoped enum nested in a struct at global scope', () {
      expect(GlobalBox$State.closed.value, 30);
      expect(GlobalBox$State.open.value, 31);
    });

    test('leaf-name collision across namespaces is disambiguated', () {
      expect(other$Color.black.value, 100);
      expect(other$Color.white.value, 200);
    });
  });
}
