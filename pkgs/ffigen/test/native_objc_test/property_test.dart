// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../test_utils.dart';
import 'property_test_bindings.dart';
import 'util.dart';

void main() {
  group('properties', () {
    late PropertyInterface testInterface;
    setUpAll(() {
      loadLibrary();
      testInterface = PropertyInterface.alloc().init();
    });

    group('instance properties', () {
      test('read-only property', () {
        expect(testInterface.readOnlyProperty, 7);
      });

      test('read-write property', () {
        testInterface.readWriteProperty = 23;
        expect(testInterface.readWriteProperty, 23);
      });
    });

    group('class properties', () {
      test('read-only property', () {
        expect(PropertyInterface.getClassReadOnlyProperty(), 42);
      });

      test('read-write property', () {
        PropertyInterface.setClassReadWriteProperty(101);
        expect(PropertyInterface.getClassReadWriteProperty(), 101);
      });
    });

    group('Regress #209', () {
      // Test for https://github.com/dart-lang/native/issues/209
      test('Structs', () {
        final inputPtr = calloc<Vec4>();
        final input = inputPtr.ref;
        input.x = 1.2;
        input.y = 3.4;
        input.z = 5.6;
        input.w = 7.8;

        testInterface.structProperty = input;
        final result = testInterface.structProperty;
        expect(result.x, 1.2);
        expect(result.y, 3.4);
        expect(result.z, 5.6);
        expect(result.w, 7.8);

        calloc.free(inputPtr);
      });

      test('Floats', () {
        testInterface.floatProperty = 1.23;
        expect(testInterface.floatProperty, closeTo(1.23, 1e-6));
      });

      test('Doubles', () {
        testInterface.doubleProperty = 1.23;
        expect(testInterface.doubleProperty, 1.23);
      });
    });

    test('Instance and static properties with same name', () {
      // Test for https://github.com/dart-lang/native/issues/1136
      expect(testInterface.instStaticSameName, 123);
      expect(PropertyInterface.getInstStaticSameName$1(), 456);
    });

    test('Regress #1268', () {
      // Test for https://github.com/dart-lang/native/issues/1268
      final array = PropertyInterface.getRegressGH1268().asDart();
      expect(array.length, 1);
      expect(NSString.as(array[0]).toDartString(), "hello");
    });
  });
}
