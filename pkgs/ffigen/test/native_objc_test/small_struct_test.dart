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

typedef Union8Block = ObjCBlock_Union8;
typedef Union16Block = ObjCBlock_Union16;
typedef Union24Block = ObjCBlock_Union24;
typedef Union32Block = ObjCBlock_Union32;

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

    group('Methods returning union', () {
      test('Union8 (8 bytes)', () {
        final result = tester.getUnion8Method();
        expect(result.a, 100);
      });

      test('Union16 (16 bytes)', () {
        final result = tester.getUnion16Method();
        expect(result.a, 100);
        expect(result.s.a, 100);
        expect(result.s.b, 200);
      });

      test('Union24 (24 bytes)', () {
        final result = tester.getUnion24Method();
        expect(result.a, 100);
        expect(result.s.a, 100);
        expect(result.s.b, 200);
        expect(result.s.c, 300);
      });

      test('Union32 (32 bytes)', () {
        final result = tester.getUnion32Method();
        expect(result.a, 100);
        expect(result.s.a, 100);
        expect(result.s.b, 200);
        expect(result.s.c, 300);
        expect(result.s.d, 400);
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

    group('Property getters returning union', () {
      test('Union8 (8 bytes)', () {
        final result = tester.union8Property;
        expect(result.a, 10);
      });

      test('Union16 (16 bytes)', () {
        final result = tester.union16Property;
        expect(result.a, 10);
        expect(result.s.a, 10);
        expect(result.s.b, 20);
      });

      test('Union24 (24 bytes)', () {
        final result = tester.union24Property;
        expect(result.a, 10);
        expect(result.s.a, 10);
        expect(result.s.b, 20);
        expect(result.s.c, 30);
      });

      test('Union32 (32 bytes)', () {
        final result = tester.union32Property;
        expect(result.a, 10);
        expect(result.s.a, 10);
        expect(result.s.b, 20);
        expect(result.s.c, 30);
        expect(result.s.d, 40);
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

    group('Blocks returning union', () {
      test('Union8 (8 bytes)', () {
        using((arena) {
          final temp = arena<Union8>().ref;
          temp.a = 1000;
          final block = Union8Block.fromFunction(() => temp);
          final result = SmallStructTester.callUnion8Block(block);
          expect(result.a, 1000);
        });
      });

      test('Union16 (16 bytes)', () {
        using((arena) {
          final temp = arena<Union16>().ref;
          temp.s.a = 1000;
          temp.s.b = 2000;
          final block = Union16Block.fromFunction(() => temp);
          final result = SmallStructTester.callUnion16Block(block);
          expect(result.a, 1000);
          expect(result.s.a, 1000);
          expect(result.s.b, 2000);
        });
      });

      test('Union24 (24 bytes)', () {
        using((arena) {
          final temp = arena<Union24>().ref;
          temp.s.a = 1000;
          temp.s.b = 2000;
          temp.s.c = 3000;
          final block = Union24Block.fromFunction(() => temp);
          final result = SmallStructTester.callUnion24Block(block);
          expect(result.a, 1000);
          expect(result.s.a, 1000);
          expect(result.s.b, 2000);
          expect(result.s.c, 3000);
        });
      });

      test('Union32 (32 bytes)', () {
        using((arena) {
          final temp = arena<Union32>().ref;
          temp.s.a = 1000;
          temp.s.b = 2000;
          temp.s.c = 3000;
          temp.s.d = 4000;
          final block = Union32Block.fromFunction(() => temp);
          final result = SmallStructTester.callUnion32Block(block);
          expect(result.a, 1000);
          expect(result.s.a, 1000);
          expect(result.s.b, 2000);
          expect(result.s.c, 3000);
          expect(result.s.d, 4000);
        });
      });
    });
  });
}
