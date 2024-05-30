// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'objective_c_bindings_generated.dart';

extension NSMutableDataExtensions on NSMutableData {
  /// Return the value of [bytes] at the given index.
  ///
  /// The returned value will be in the range 0 to 255.
  void operator []=(int index, int value) {
    IndexError.check(index, length, indexable: this);
    mutableBytes.cast<Uint8>()[index] = value;
  }

  void addAll(Iterable<int> l) {
    final f = malloc<Uint8>(l.length);
    try {
      f.asTypedList(l.length).setAll(0, l);
      appendBytes_length_(f.cast(), l.length);
    } finally {
      malloc.free(f);
    }
  }
}

extension NSMutableDataListExtension on List<int> {
  /// Return a [NSMutableData] containing the contents of the [List] interpreted
  /// as bytes.
  ///
  /// The elements of the [List] should be integers in the range 0 to 255. Any
  /// integer, which is not in that range, is converted to a byte as if by
  /// `value.toUnsigned(8)`.
  NSMutableData toNSMutableData() {
    if (length == 0) {
      return NSMutableData.new1();
    }
    final buffer = malloc<Uint8>(length);
    buffer.asTypedList(length).setAll(0, this);

    final data = NSMutableData.dataWithBytes_length_(buffer.cast(), length);
    malloc.free(buffer);

    return data;
  }
}
