// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

void main() {
  test('uintptr_t', () {
    expect(sizeOf<UintPtr>(), sizeOf<IntPtr>());
  });

  test('wchar_t', () {
    expect(sizeOf<WChar>(), Platform.isWindows ? 2 : 4);
  });

  test('long', () {
    expect(sizeOf<Long>(), Platform.isWindows ? 4 : sizeOf<IntPtr>());
  });

  test('unsigned long', () {
    expect(sizeOf<UnsignedLong>(), sizeOf<Long>());
  });

  test('int', () {
    expect(sizeOf<Int>(), sizeOf<Int32>());
  });
}
