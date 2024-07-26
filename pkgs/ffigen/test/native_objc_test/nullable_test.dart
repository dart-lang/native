// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import '../test_utils.dart';
import 'nullable_bindings.dart';
import 'util.dart';

void main() {
  late NullableInterface nullableInterface;
  late NSObject obj;
  group('Nullability', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib = File('test/native_objc_test/nullable_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      nullableInterface = NullableInterface.new1();
      obj = NSObject.new1();
      generateBindingsForCoverage('nullable');
    });

    group('Nullable property', () {
      test('Not null', () {
        nullableInterface.nullableObjectProperty = obj;
        expect(nullableInterface.nullableObjectProperty, obj);
      });
      test('Null', () {
        nullableInterface.nullableObjectProperty = null;
        expect(nullableInterface.nullableObjectProperty, null);
      });
    });

    group('Nullable return', () {
      test('Not null', () {
        expect(NullableInterface.returnNil_(false), isA<NSObject>());
      });
      test('Null', () {
        expect(NullableInterface.returnNil_(true), null);
      });
    });

    group('Nullable arguments', () {
      test('Not null', () {
        expect(NullableInterface.isNullWithNullableNSObjectArg_(obj), false);
      });
      test('Null', () {
        expect(NullableInterface.isNullWithNullableNSObjectArg_(null), true);
      });
    });

    group('Not-nullable arguments', () {
      test('Not null', () {
        expect(
            NullableInterface.isNullWithNotNullableNSObjectPtrArg_(obj), false);
      });

      test('Explicit non null', () {
        expect(
            NullableInterface.isNullWithExplicitNonNullableNSObjectPtrArg_(obj),
            false);
      });
    });
  });
}
