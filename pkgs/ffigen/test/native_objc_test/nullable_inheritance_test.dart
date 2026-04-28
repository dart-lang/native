// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:ffi';
import 'dart:io';

import 'package:objective_c/objective_c.dart' as objc;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'nullable_inheritance_test_bindings.dart';
import 'util.dart';

void main() {
  group('Nullable inheritance', () {
    late NullableChild nullableChild;
    late NullableBase nullableBase;
    late objc.NSObject obj;
    setUpAll(() {
      loadLibrary();
      nullableChild = NullableChild.alloc().init();
      nullableBase = NullableBase.alloc().init();
      obj = objc.NSObject.alloc().init();
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
        expect(nullableBase.nullableReturn(false), isA<objc.NSObject>());
        expect(nullableBase.nullableReturn(true), null);
      });
      test('Non-null return', () {
        expect(nullableBase.nonNullReturn(), isA<objc.NSObject>());
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
        expect(nullableChild.nullableReturn(false), isA<objc.NSObject>());
      });

      test('Non-null return, changed to nullable', () {
        expect(nullableChild.nonNullReturn(), null);
      });
    });
  });
}
