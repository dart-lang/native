// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

void main() {
  // Allocate and free some native memory with calloc and free.
  final pointer = calloc<Uint8>();
  pointer.value = 3;
  print(pointer.value);
  calloc.free(pointer);

  // Use the Utf8 helper to encode zero-terminated UTF-8 strings in native
  // memory.
  final myString = '😎👿💬';
  final charPointer = myString.toNativeUtf8();
  print('First byte is: ${charPointer.cast<Uint8>().value}');
  print(charPointer.toDartString());
  calloc.free(charPointer);
}
