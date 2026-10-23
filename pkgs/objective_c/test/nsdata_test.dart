// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:objective_c/objective_c.dart';
import 'package:test/test.dart';

import 'util.dart';

/// `malloc_statistics_t` from `<malloc/malloc.h>`.
final class _MallocStatistics extends Struct {
  @UnsignedInt()
  external int blocksInUse;

  @Size()
  external int sizeInUse;

  @Size()
  external int maxSizeInUse;

  @Size()
  external int sizeAllocated;
}

final _mallocZoneStatistics = DynamicLibrary.process()
    .lookupFunction<
      Void Function(Pointer<Void>, Pointer<_MallocStatistics>),
      void Function(Pointer<Void>, Pointer<_MallocStatistics>)
    >('malloc_zone_statistics');

/// The number of bytes, allocated by `malloc` in any zone, that are in use.
int _mallocSizeInUse() => using((arena) {
  final statistics = arena<_MallocStatistics>();
  _mallocZoneStatistics(nullptr, statistics);
  return statistics.ref.sizeInUse;
});

void main() {
  group('NSData', () {
    group('toNSData', () {
      test('empty', () {
        final data = <int>[].toNSData();
        expect(data.length, 0);
        data.ref.release(); // Make sure that dealloc succeeds.
      });

      test('non empty', () {
        final data = [1, 2, 3].toNSData();
        expect(data.length, 3);
        expect(data.bytes.cast<Uint8>()[0], 1);
        expect(data.bytes.cast<Uint8>()[1], 2);
        expect(data.bytes.cast<Uint8>()[2], 3);
        data.ref.release(); // Make sure that dealloc succeeds.
      });

      test('non-byte', () {
        final data = [257].toNSData();
        expect(data.length, 1);
        expect(data.bytes.cast<Uint8>().value, 1);
        data.ref.release(); // Make sure that dealloc succeeds.
      });

      test('large', () {
        final list = Uint8List.fromList([
          for (var i = 0; i < 1024 * 1024; ++i) i * 7,
        ]);
        final data = list.toNSData();
        expect(data.length, list.length);
        expect(data.toList(), list);
        data.ref.release(); // Make sure that dealloc succeeds.
      });

      test('copies the list', () {
        final list = [1, 2, 3];
        final data = list.toNSData();
        list[0] = 4;
        expect(data.toList(), [1, 2, 3]);
        data.ref.release();
      });

      test('data outlives the Dart object', () async {
        // Objective-C code can keep using the data after the Dart object
        // that wraps it has been released and garbage collected.
        final expected = [for (var i = 0; i < 4096; ++i) i % 256];
        final array = NSMutableArray().asDart();
        () {
          final data = expected.toNSData();
          array.add(data);
          data.ref.release();
        }();
        doGC();
        await Future<void>.delayed(Duration.zero);
        doGC();
        expect(NSData.as(array[0]).toList(), expected);
      });

      test('frees the bytes when deallocated', () {
        const size = 1024 * 1024;
        final list = Uint8List(size);
        final before = _mallocSizeInUse();
        for (var i = 0; i < 100; ++i) {
          list.toNSData().ref.release();
        }
        // If the bytes were not freed then at least 100 MiB would be in use.
        expect(_mallocSizeInUse() - before, lessThan(50 * size));
      });

      test('garbage collected', () async {
        await using((arena) async {
          final tracker = ReferenceTracker(arena);
          () {
            final data = [1, 2, 3].toNSData();
            tracker.track(data);
          }();
          doGC();
          await Future<void>.delayed(Duration.zero);
          doGC();
          expect(tracker.isAlive, isFalse);
        });
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

          final data = NSData.dataWithBytes(bytes.cast(), length: 3);
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

          final data = NSData.dataWithBytes(bytes.cast(), length: 3);
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

          final data = NSData.dataWithBytes(bytes.cast(), length: 3);
          expect(() => data[3], throwsRangeError);
          expect(() => data[-1], throwsRangeError);
        });
      });
    });
  });
}
