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
import 'nullable_inheritance_bindings.dart';
import 'util.dart';

void main() {
  late NullableBase nullableBase;
  late NullableChild nullableChild;
  late NSObject obj;
  group('Nullable inheritance', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('../objective_c/test/objective_c.dylib');
      final dylib =
          File('test/native_objc_test/objc_test.dylib');
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      nullableBase = NullableBase.new1();
      nullableChild = NullableChild.new1();
      obj = NSObject.new1();
      generateBindingsForCoverage('nullable');
    });

    group('Base', () {
      test('Nullable arguments', () {
        expect(nullableBase.nullableArg_(obj), false);
        expect(nullableBase.nullableArg_(null), true);
      });

      test('Non-null arguments', () {
        expect(nullableBase.nonNullArg_(obj), false);
      });

      test('Nullable return', () {
        expect(nullableBase.nullableReturn_(false), isA<NSObject>());
        expect(nullableBase.nullableReturn_(true), null);
      });

      test('Non-null return', () {
        expect(nullableBase.nonNullReturn(), isA<NSObject>());
      });
    });

    group('Child', () {
      test('Nullable arguments, changed to non-null', () {
        expect(nullableChild.nullableArg_(obj), false);
      });

      test('Non-null arguments, changed to nullable', () {
        expect(nullableChild.nonNullArg_(obj), false);
        expect(nullableChild.nonNullArg_(null), true);
      });

      test('Nullable return, changed to non-null', () {
        expect(nullableChild.nullableReturn_(false), isA<NSObject>());
      });

      test('Non-null return, changed to nullable', () {
        expect(nullableChild.nonNullReturn(), null);
      });
    });
  });
}
