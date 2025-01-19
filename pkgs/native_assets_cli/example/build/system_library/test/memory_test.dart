// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:system_library/memory.dart';
import 'package:test/test.dart';

void main() {
  test('invoke native function', () {
    if (Platform.isWindows) {
      final pointer = coTaskMemAlloc(8);
      expect(pointer, isNot(nullptr));
      coTaskMemFree(pointer);
    } else {
      final pointer = malloc(8);
      expect(pointer, isNot(nullptr));
      free(pointer);
    }
  });
}
