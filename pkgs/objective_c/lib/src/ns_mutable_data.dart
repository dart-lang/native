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
  int operator [](int index) {
    IndexError.check(index, length, indexable: this);
    return bytes.cast<Uint8>()[index];
  }

  /// Set the value at the given index.
  ///
  /// The value should be in the range 0 to 255. An integer, which is not in
  /// that range, is converted to a byte as if by `value.toUnsigned(8)`.
  void operator []=(int index, int value) {
    IndexError.check(index, length, indexable: this);
    mutableBytes.cast<Uint8>()[index] = value;
  }

  /// Appends all objects of `iterable` to the end of this [NSMutableData].
  ///
  /// The elements of the `iterable` should be integers in the range 0 to 255.
  /// Any integer, which is not in that range, is converted to a byte as if by
  /// `value.toUnsigned(8)`.
  void addAll(Iterable<int> iterable) {
    final f = malloc<Uint8>(iterable.length);
    try {
      f.asTypedList(iterable.length).setAll(0, iterable);
      appendBytes_length_(f.cast(), iterable.length);
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
      return NSMutableData();
    }
    final buffer = malloc<Uint8>(length);
    buffer.asTypedList(length).setAll(0, this);

    final data = NSMutableData.dataWithBytes_length_(buffer.cast(), length);
    malloc.free(buffer);

    return data;
  }
}
