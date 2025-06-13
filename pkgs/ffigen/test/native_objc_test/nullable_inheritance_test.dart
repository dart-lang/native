// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart';
import 'package:path/path.dart' as path;
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
      final dylib = File(path.join(
        packagePathForTests,
        'test',
        'native_objc_test',
        'objc_test.dylib',
      ));
      verifySetupFile(dylib);
      DynamicLibrary.open(dylib.absolute.path);
      nullableBase = NullableBase();
      nullableChild = NullableChild();
      obj = NSObject();
      generateBindingsForCoverage('nullable');
    });

    group('Base', () {
      test('Nullable arguments', () {
        expect(nullableBase.nullableArg(obj), false);
        expect(nullableBase.nullableArg(null), true);
      });

      test('Non-null arguments', () {
        expect(nullableBase.nonNullArg(obj), false);
      });

      test('Nullable return', () {
        expect(nullableBase.nullableReturn(false), isA<NSObject>());
        expect(nullableBase.nullableReturn(true), null);
      });

      test('Non-null return', () {
        expect(nullableBase.nonNullReturn(), isA<NSObject>());
      });
    });

    group('Child', () {
      test('Nullable arguments, changed to non-null', () {
        expect(nullableChild.nullableArg(obj), false);
      });

      test('Non-null arguments, changed to nullable', () {
        expect(nullableChild.nonNullArg(obj), false);
        expect(nullableChild.nonNullArg(null), true);
      });

      test('Nullable return, changed to non-null', () {
        expect(nullableChild.nullableReturn(false), isA<NSObject>());
      });

      test('Non-null return, changed to nullable', () {
        expect(nullableChild.nonNullReturn(), null);
      });
    });
  });
}
