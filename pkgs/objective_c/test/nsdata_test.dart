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
    group('toNSData', () {
      test('empty', () {
        final data = <int>[].toNSData();
        expect(data.length, 0);
        data.release(); // Make sure that dealloc succeeds.
      });

      test('non empty', () {
        final data = [1, 2, 3].toNSData();
        expect(data.length, 3);
        expect(data.bytes.cast<Uint8>()[0], 1);
        expect(data.bytes.cast<Uint8>()[1], 2);
        expect(data.bytes.cast<Uint8>()[2], 3);
        data.release(); // Make sure that dealloc succeeds.
      });

      test('non-byte', () {
        final data = [257].toNSData();
        expect(data.length, 1);
        expect(data.bytes.cast<Uint8>().value, 1);
        data.release(); // Make sure that dealloc succeeds.
      });
    });

    group('toList', () {
      test('empty', () {
        final data = NSData.data();
        expect(data.toList(), isEmpty);
      });

      test('non empty', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSData.dataWithBytes_length_(bytes.cast(), 3);
          expect(data.toList(), [1, 2, 3]);
        });
      });
    });

    group('operator[]', () {
      test('in bounds', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSData.dataWithBytes_length_(bytes.cast(), 3);
          expect(data[0], 1);
          expect(data[1], 2);
          expect(data[2], 3);
        });
      });

      test('out of bounds', () {
        using((arena) {
          final bytes = arena<Uint8>(3);
          bytes[0] = 1;
          bytes[1] = 2;
          bytes[2] = 3;

          final data = NSData.dataWithBytes_length_(bytes.cast(), 3);
          expect(() => data[3], throwsRangeError);
          expect(() => data[-1], throwsRangeError);
        });
      });
    });
  });
}
