// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

void main() {
  group('NSData', () {
    setUpAll(() {
      // TODO(https://github.com/dart-lang/native/issues/1068): Remove this.
      DynamicLibrary.open('test/objective_c.dylib');
    });

    group('toNSData', () {
      test('empty', () {
        final data = <int>[].toNSMutableData();
        expect(data.length, 0);
        data.release(); // Make sure that dealloc succeeds.
      });

      test('non empty', () {
        final data = [1, 2, 3].toNSMutableData();
        expect(data.length, 3);
        expect(data.bytes.cast<Uint8>()[0], 1);
        expect(data.bytes.cast<Uint8>()[1], 2);
        expect(data.bytes.cast<Uint8>()[2], 3);
        data.release(); // Make sure that dealloc succeeds.
      });

      test('non-byte', () {
        final data = [257].toNSMutableData();
        expect(data.length, 1);
        expect(data.bytes.cast<Uint8>().value, 1);
        data.release(); // Make sure that dealloc succeeds.
      });
    });

    group('toList', () {
      test('empty', () {
        final data = NSMutableData.data();
        expect(data.toList(), isEmpty);
      });

      test('non empty', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSMutableData.dataWithBytes_length_(bytes.cast(), 3);
          expect(data.toList(), [1, 2, 3]);
        });
      });
    });

    group('operator[index, value]', () {
      test('in bounds', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSMutableData.dataWithBytes_length_(bytes.cast(), 3);
          data[0] = 4;
          data[1] = 5;
          data[2] = 6;
          expect(data[0], 4);
          expect(data[1], 5);
          expect(data[2], 6);
        });
      });

      test('out of bounds', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSMutableData.dataWithBytes_length_(bytes.cast(), 3);
          expect(() => data[3] = 2, throwsRangeError);
          expect(() => data[-1] = 1, throwsRangeError);
          expect(data[0], 1);
          expect(data[1], 2);
          expect(data[2], 3);
        });
      });

      test('non-byte', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSMutableData.dataWithBytes_length_(bytes.cast(), 3);
          data[0] = 256;
          data[1] = 257;
          data[2] = -1;
          expect(data[0], 0);
          expect(data[1], 1);
          expect(data[2], 255);
        });
      });
    });

    group('addAll', () {
      test('empty addAll on empty NSMutableData', () {
        final data = NSMutableData.data();
        data.addAll([]);

        expect(data.length, isZero);
      });

      test('empty addAll on non-empty NSMutableData', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSMutableData.dataWithBytes_length_(bytes.cast(), 3);
          data.addAll([]);

          expect(data.length, 3);
          expect(data[0], 1);
          expect(data[1], 2);
          expect(data[2], 3);
        });
      });

      test('bytes', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSMutableData.dataWithBytes_length_(bytes.cast(), 3);
          data.addAll([4, 5, 6]);

          expect(data.length, 6);
          expect(data[0], 1);
          expect(data[1], 2);
          expect(data[2], 3);
          expect(data[3], 4);
          expect(data[4], 5);
          expect(data[5], 6);
        });
      });

      test('non-byte', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSMutableData.dataWithBytes_length_(bytes.cast(), 3);
          data.addAll([-1, 256, 257]);

          expect(data.length, 6);
          expect(data[0], 1);
          expect(data[1], 2);
          expect(data[2], 3);
          expect(data[3], 255);
          expect(data[4], 0);
          expect(data[5], 1);
        });
      });
    });
  });
}
