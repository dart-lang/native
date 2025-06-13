// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import '../test_utils.dart';
import 'method_bindings.dart';
import 'util.dart';

void main() {
  late MethodInterface testInstance;

  group('method calls', () {
    setUpAll(() {
      final dylib = File(path.join(
        packagePathForTests,
        'test',
        'native_objc_test',
        'objc_test.dylib',
      ));
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      testInstance = MethodInterface();
      generateBindingsForCoverage('method');
    });

    group('Instance methods', () {
      test('No arguments', () {
        expect(testInstance.add(), 5);
      });

      test('One argument', () {
        expect(testInstance.add$1(23), 23);
      });

      test('Two arguments', () {
        expect(testInstance.add$2(23, Y: 17), 40);
      });

      test('Three arguments', () {
        expect(testInstance.add$3(23, Y: 17, Z: 60), 100);
      });
    });

    group('Class methods', () {
      test('No arguments', () {
        expect(MethodInterface.sub(), -5);
      });

      test('One argument', () {
        expect(MethodInterface.sub$1(7), -7);
      });

      test('Two arguments', () {
        expect(MethodInterface.sub$2(7, Y: 3), -10);
      });

      test('Three arguments', () {
        expect(MethodInterface.sub$3(10, Y: 7, Z: 3), -20);
      });
    });

    group('Regress #608', () {
      test('Structs', () {
        final inputPtr = calloc<Vec4>();
        final input = inputPtr.ref;
        input.x = 1.2;
        input.y = 3.4;
        input.z = 5.6;
        input.w = 7.8;

        final result = testInstance.twiddleVec4Components(input);
        expect(result.x, 3.4);
        expect(result.y, 5.6);
        expect(result.z, 7.8);
        expect(result.w, 1.2);

        calloc.free(inputPtr);
      });

      test('Floats', () {
        expect(testInstance.addFloats(1.23, Y: 4.56), closeTo(5.79, 1e-6));
      });

      test('Doubles', () {
        expect(testInstance.addDoubles(1.23, Y: 4.56), closeTo(5.79, 1e-6));
      });

      test('Method with same name as a type', () {
        // Test for https://github.com/dart-lang/native/issues/1007
        final result = testInstance.Vec4$1();
        expect(result.x, 1);
        expect(result.y, 2);
        expect(result.z, 3);
        expect(result.w, 4);
      });
    });

    test('Instance and static methods with same name', () {
      // Test for https://github.com/dart-lang/native/issues/1136
      expect(testInstance.instStaticSameName(), 123);
      expect(MethodInterface.instStaticSameName$1(), 456);
    });
  });
}
