// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'package:objective_c/objective_c.dart';

import '../test_utils.dart';
import 'error_method_test_bindings.dart';
import 'util.dart';

void main() {
  group('error_method_test', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open(
        path.join(
          packagePathForTests,
          '..',
          'objective_c',
          'test',
          'objective_c.dylib',
        ),
      );
      final dylib = File(
        path.join(
          packagePathForTests,
          'test',
          'native_objc_test',
          'objc_test.dylib',
        ),
      );
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      generateBindingsForCoverage('error_method');
    });

    test("Error method that returns bool", () {
      final obj = ErrorMethodTestObject();
      expect(obj.errorMethodReturningBool(true), isTrue);
      expect(
        () => obj.errorMethodReturningBool(false),
        throwsA(isA<NSErrorException>()),
      );
    });

    test("Error method that returns nullable", () {
      final obj = ErrorMethodTestObject();
      expect(obj.errorMethodReturningNullable(true), isA<NSObject>());
      expect(
        () => obj.errorMethodReturningNullable(false),
        throwsA(isA<NSErrorException>()),
      );
    });

    test("Error method with param named outError", () {
      final obj = ErrorMethodTestObject();
      expect(obj.outErrorMethod(true), isTrue);
      expect(() => obj.outErrorMethod(false), throwsA(isA<NSErrorException>()));
    });

    test("Error method with nullable error", () {
      final obj = ErrorMethodTestObject();
      expect(obj.nullableErrorMethod(true), isTrue);
      expect(
        () => obj.nullableErrorMethod(false),
        throwsA(isA<NSErrorException>()),
      );
    });
  });
}
