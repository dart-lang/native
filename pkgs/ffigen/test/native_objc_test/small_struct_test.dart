// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

import 'small_struct_test_bindings.dart';

typedef Struct8Block = ObjCBlock_Struct8;
typedef Struct16Block = ObjCBlock_Struct16;
typedef Struct24Block = ObjCBlock_Struct24;
typedef Struct32Block = ObjCBlock_Struct32;

void main() {
  group('Small struct return tests (8 to 32 bytes)', () {
    late SmallStructTester tester;

    setUpAll(() {
      tester = SmallStructTester.alloc().init();
    });

    group('Methods returning struct', () {
      test('Struct8 (8 bytes)', () {
        final result = tester.getStruct8Method();
        expect(result.a, 100);
      });

      test('Struct16 (16 bytes)', () {
        final result = tester.getStruct16Method();
        expect(result.a, 100);
        expect(result.b, 200);
      });

      test('Struct24 (24 bytes)', () {
        final result = tester.getStruct24Method();
        expect(result.a, 100);
        expect(result.b, 200);
        expect(result.c, 300);
      });

      test('Struct32 (32 bytes)', () {
        final result = tester.getStruct32Method();
        expect(result.a, 100);
        expect(result.b, 200);
        expect(result.c, 300);
        expect(result.d, 400);
      });
    });

    group('Property getters returning struct', () {
      test('Struct8 (8 bytes)', () {
        final result = tester.struct8Property;
        expect(result.a, 10);
      });

      test('Struct16 (16 bytes)', () {
        final result = tester.struct16Property;
        expect(result.a, 10);
        expect(result.b, 20);
      });

      test('Struct24 (24 bytes)', () {
        final result = tester.struct24Property;
        expect(result.a, 10);
        expect(result.b, 20);
        expect(result.c, 30);
      });

      test('Struct32 (32 bytes)', () {
        final result = tester.struct32Property;
        expect(result.a, 10);
        expect(result.b, 20);
        expect(result.c, 30);
        expect(result.d, 40);
      });
    });

    group('Blocks returning struct', () {
      test('Struct8 (8 bytes)', () {
        using((arena) {
          final temp = arena<Struct8>().ref;
          temp.a = 1000;
          final block = Struct8Block.fromFunction(() => temp);
          final result = SmallStructTester.callStruct8Block(block);
          expect(result.a, 1000);
        });
      });

      test('Struct16 (16 bytes)', () {
        using((arena) {
          final temp = arena<Struct16>().ref;
          temp.a = 1000;
          temp.b = 2000;
          final block = Struct16Block.fromFunction(() => temp);
          final result = SmallStructTester.callStruct16Block(block);
          expect(result.a, 1000);
          expect(result.b, 2000);
        });
      });

      test('Struct24 (24 bytes)', () {
        using((arena) {
          final temp = arena<Struct24>().ref;
          temp.a = 1000;
          temp.b = 2000;
          temp.c = 3000;
          final block = Struct24Block.fromFunction(() => temp);
          final result = SmallStructTester.callStruct24Block(block);
          expect(result.a, 1000);
          expect(result.b, 2000);
          expect(result.c, 3000);
        });
      });

      test('Struct32 (32 bytes)', () {
        using((arena) {
          final temp = arena<Struct32>().ref;
          temp.a = 1000;
          temp.b = 2000;
          temp.c = 3000;
          temp.d = 4000;
          final block = Struct32Block.fromFunction(() => temp);
          final result = SmallStructTester.callStruct32Block(block);
          expect(result.a, 1000);
          expect(result.b, 2000);
          expect(result.c, 3000);
          expect(result.d, 4000);
        });
      });
    });
  });
}
