// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:math' show Random;

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';

const testRuns = 1000;

void main() async {
  test('calloc', () {
    // Tests that calloc successfully zeroes out memory.
    for (var i = 0; i < testRuns; i++) {
      final allocBytes = Random().nextInt(1000);
      final mem = calloc<Uint8>(allocBytes);
      expect(mem.asTypedList(allocBytes).where(((element) => element != 0)),
          isEmpty);
      calloc.free(mem);
    }
  });
}
