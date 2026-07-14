// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' as ffi;

import 'package:test/test.dart';

import 'cpp_scoped_struct_test_bindings.dart';

void main() {
  group('CppScopedStruct', () {
    test('structs in scopes are generated with flattened names', () {
      expect(GlobalBox, isNotNull);
      expect(GlobalBox$Lid, isNotNull);
      expect(outer$Point, isNotNull);
      expect(outer$inner$Point, isNotNull);
      expect(outer$Palette$Entry, isNotNull);
      expect(other$Point, isNotNull);
      expect(other$Value, isNotNull);
    });

    test('struct in a single namespace', () {
      expect(ffi.sizeOf<outer$Point>(), 8);
      final point = ffi.Struct.create<outer$Point>();
      point.x = 1;
      point.y = 2;
      expect(point.x, 1);
      expect(point.y, 2);
    });

    test('struct in a nested namespace', () {
      expect(ffi.sizeOf<outer$inner$Point>(), 8);
      final point = ffi.Struct.create<outer$inner$Point>();
      point.x = 1.5;
      point.y = 2.5;
      expect(point.x, 1.5);
      expect(point.y, 2.5);
    });

    test('struct nested in a class inside a namespace', () {
      expect(ffi.sizeOf<outer$Palette$Entry>(), 4);
      final entry = ffi.Struct.create<outer$Palette$Entry>();
      entry.tone = 42;
      expect(entry.tone, 42);
    });

    test('struct nested in a struct at global scope', () {
      expect(ffi.sizeOf<GlobalBox$Lid>(), 4);
      expect(ffi.sizeOf<GlobalBox>(), 8);
      final box = ffi.Struct.create<GlobalBox>();
      box.lid.hinge = 3;
      box.size = 4;
      expect(box.lid.hinge, 3);
      expect(box.size, 4);
    });

    test('leaf-name collision across namespaces is disambiguated', () {
      expect(ffi.sizeOf<other$Point>(), 8);
      final point = ffi.Struct.create<other$Point>();
      point.x = 3.25;
      expect(point.x, 3.25);
    });

    test('union in a namespace', () {
      expect(ffi.sizeOf<other$Value>(), 4);
      final value = ffi.Union.create<other$Value>();
      value.i = 7;
      expect(value.i, 7);
    });
  });
}
