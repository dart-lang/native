// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' as ffi;

import 'package:test/test.dart';

import 'cpp_scoped_struct_test_bindings.dart';

void main() {
  group('CppScopedStruct', () {
    test('struct in a namespace', () {
      expect(ffi.sizeOf<outer$Point>(), ffi.sizeOf<ffi.Int>() * 2);
    });

    test('struct in a nested namespace', () {
      expect(ffi.sizeOf<outer$inner$Point>(), ffi.sizeOf<ffi.Float>() * 2);
    });

    test('struct nested in a class in a namespace', () {
      expect(ffi.sizeOf<outer$Palette$Entry>(), ffi.sizeOf<ffi.Int>());
    });

    test('union in a namespace', () {
      expect(ffi.sizeOf<other$Value>(), ffi.sizeOf<ffi.Int>());
    });

    test('structs sharing a leaf name across namespaces are distinct', () {
      // All three are named `Point`, so each has to keep its scope path, and
      // each keeps its own field types.
      expect(ffi.sizeOf<outer$Point>(), ffi.sizeOf<ffi.Int>() * 2);
      expect(ffi.sizeOf<outer$inner$Point>(), ffi.sizeOf<ffi.Float>() * 2);
      expect(ffi.sizeOf<other$Point>(), ffi.sizeOf<ffi.Double>());
    });

    test('struct nested in a struct is usable as a member of it', () {
      expect(ffi.sizeOf<GlobalBox$Lid>(), ffi.sizeOf<ffi.Int>());
      expect(ffi.sizeOf<GlobalBox>(), ffi.sizeOf<ffi.Int>() * 2);

      // The nested struct is the type of the enclosing struct's field, not a
      // second copy of it.
      final box = ffi.Struct.create<GlobalBox>();
      box.lid.hinge = 3;
      box.size = 4;
      expect(box.lid.hinge, 3);
      expect(box.size, 4);
    });
  });
}
