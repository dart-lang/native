// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:math' show Random;

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

const testRuns = 1000;
const _isWasm = bool.fromEnvironment('dart.tool.dart2wasm');

List<int> _readBytes(Pointer<Uint8> pointer, int length) => _isWasm
    ? [for (var i = 0; i < length; i++) pointer[i]]
    : pointer.asTypedList(length);

void main() async {
  test('calloc', () {
    // Tests that calloc successfully zeroes out memory.
    for (var i = 0; i < testRuns; i++) {
      final allocBytes = Random().nextInt(1000);
      final mem = calloc<Uint8>(allocBytes);
      expect(
        _readBytes(mem, allocBytes).where((element) => element != 0),
        isEmpty,
      );
      calloc.free(mem);
    }
  });

  test('malloc', () {
    final mem = malloc<Uint8>(64);
    malloc.free(mem);
  });

  test('testPointerAllocateTooLarge', () {
    // Try to allocate something that doesn't fit in 64 bit address space.
    const maxInt = 9223372036854775807; // 2^63 - 1
    expect(() => calloc<Uint8>(maxInt), throwsA(isA<ArgumentError>()));
    expect(() => malloc<Uint8>(maxInt), throwsA(isA<ArgumentError>()));

    // Try to allocate almost the full 64 bit address space.
    const maxInt1_8 = 1152921504606846975; // 2^60 -1
    expect(() => calloc<Uint8>(maxInt1_8), throwsA(isA<ArgumentError>()));
    expect(() => malloc<Uint8>(maxInt1_8), throwsA(isA<ArgumentError>()));

    if (sizeOf<IntPtr>() == 4) {
      // On 32-bit platforms (including wasm32), sizes >= 2^32 must not
      // silently truncate to a smaller allocation.
      const fourGiB = 0x100000000;
      const fourGiBPlus8 = 0x100000008;
      expect(() => calloc<Uint8>(fourGiB), throwsA(isA<ArgumentError>()));
      expect(() => malloc<Uint8>(fourGiB), throwsA(isA<ArgumentError>()));
      expect(() => calloc<Uint8>(fourGiBPlus8), throwsA(isA<ArgumentError>()));
      expect(() => malloc<Uint8>(fourGiBPlus8), throwsA(isA<ArgumentError>()));
    }
  });

  test('testPointerAllocateNegative', () {
    // Negative byte counts must always be rejected, including multiples of
    // 2^32 that would otherwise wrap to 0 on 32-bit platforms.
    expect(() => calloc<Uint8>(-1), throwsA(isA<ArgumentError>()));
    expect(() => malloc<Uint8>(-1), throwsA(isA<ArgumentError>()));
    expect(() => calloc<Uint8>(-0x100000000), throwsA(isA<ArgumentError>()));
    expect(() => malloc<Uint8>(-0x100000000), throwsA(isA<ArgumentError>()));
  });

  test(
    'nativeFree',
    () {
      // malloc.nativeFree should be able to free memory allocated by malloc.
      final ptr1 = malloc.allocate<Uint8>(1024);
      malloc.nativeFree.asFunction<void Function(Pointer<Void>)>()(ptr1.cast());
      // calloc.nativeFree should be able to free memory allocated by calloc.
      final ptr2 = calloc.allocate<Uint8>(1024);
      calloc.nativeFree.asFunction<void Function(Pointer<Void>)>()(ptr2.cast());
    },
    skip: _isWasm
        ? 'Native.addressOf is not yet supported in dart2wasm.'
        : null,
  );
}
