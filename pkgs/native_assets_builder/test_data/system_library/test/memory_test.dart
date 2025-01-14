// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:system_library/memory_executable.dart' as executable;
import 'package:system_library/memory_process.dart' as process;
import 'package:system_library/memory_system.dart' as system;
import 'package:test/test.dart';

void main() {
  test('executable', () {
    if (Platform.isWindows) {
      final pointer = executable.coTaskMemAlloc(8);
      expect(pointer, isNot(nullptr));
      executable.coTaskMemFree(pointer);
    } else {
      final pointer = executable.malloc(8);
      expect(pointer, isNot(nullptr));
      executable.free(pointer);
    }
  });

  test('process', () {
    if (Platform.isWindows) {
      final pointer = process.coTaskMemAlloc(8);
      expect(pointer, isNot(nullptr));
      process.coTaskMemFree(pointer);
    } else {
      final pointer = process.malloc(8);
      expect(pointer, isNot(nullptr));
      process.free(pointer);
    }
  });

  test('system', () {
    if (Platform.isWindows) {
      final pointer = system.coTaskMemAlloc(8);
      expect(pointer, isNot(nullptr));
      system.coTaskMemFree(pointer);
    } else {
      final pointer = system.malloc(8);
      expect(pointer, isNot(nullptr));
      system.free(pointer);
    }
  });
}
