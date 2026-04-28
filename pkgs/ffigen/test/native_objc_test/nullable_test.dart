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
import 'nullable_test_bindings.dart';
import 'util.dart';

void main() {
  late NSObject obj;
  late NullableInterface testInterface;
  group('Nullability', () {
    setUpAll(() {
      loadLibrary();
      obj = NSObject.alloc().init();
      testInterface = NullableInterface.alloc().init();
    });

    group('Nullable property', () {
      test('Not null', () {
        testInterface.nullableObjectProperty = obj;
        expect(testInterface.nullableObjectProperty, obj);
      });
      test('Null', () {
        testInterface.nullableObjectProperty = null;
        expect(testInterface.nullableObjectProperty, null);
      });
    });

    group('Nullable return', () {
      test('Not null', () {
        expect(NullableInterface.returnNil(false), isA<NSObject>());
      });
      test('Null', () {
        expect(NullableInterface.returnNil(true), null);
      });
    });

    group('Nullable arguments', () {
      test('Not null', () {
        expect(NullableInterface.isNullWithNullableNSObjectArg(obj), false);
      });
      test('Null', () {
        expect(NullableInterface.isNullWithNullableNSObjectArg(null), true);
      });
    });

    group('Not-nullable arguments', () {
      test('Not null', () {
        expect(
          NullableInterface.isNullWithNotNullableNSObjectPtrArg(obj),
          false,
        );
      });

      test('Explicit non null', () {
        expect(
          NullableInterface.isNullWithExplicitNonNullableNSObjectPtrArg(obj),
          false,
        );
      });
    });

    test('Nullable typealias', () {
      // Regression test for https://github.com/dart-lang/native/issues/1701
      expect(NullableInterface.returnNullableAlias(true), isNull);
      expect(
        NullableInterface.returnNullableAlias(false)?.toDartString(),
        "Hi",
      );
    });

    test('Multiple nullable args', () {
      final x = NSObject();
      final y = NSObject();
      final z = NSObject();

      expect(NullableInterface.multipleNullableArgs(x, y: y, z: z), x);
      expect(NullableInterface.multipleNullableArgs(null, y: y, z: z), y);
      expect(NullableInterface.multipleNullableArgs(null, y: null, z: z), z);
      expect(
        NullableInterface.multipleNullableArgs(null, y: null, z: null),
        null,
      );

      // Nullable named args are optional.
      expect(NullableInterface.multipleNullableArgs(null, z: z), z);
      expect(NullableInterface.multipleNullableArgs(null, y: y), y);
      expect(NullableInterface.multipleNullableArgs(null), null);
    });
  });
}
