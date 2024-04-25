// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'objective_c_bindings_generated.dart';

extension NSDataExtensions on NSData {
  /// Return the value of [bytes] at the given index.
  ///
  /// The returned value will be in the range 0 to 255.
  int operator [](int index) {
    IndexError.check(index, length, indexable: this);
    return bytes.cast<Uint8>()[index];
  }

  /// Return a list containing the contents of the [NSData].
  Uint8List toList() {
    if (bytes.address == 0 || length == 0) {
      return Uint8List(0);
    } else {
      return Uint8List.fromList(bytes.cast<Uint8>().asTypedList(length));
    }
  }
}

extension NSDataListExtension on List<int> {
  /// Return a [NSData] containing the contents of the [List] interpreted as
  /// bytes.
  ///
  /// The elements of the [List] should be integers in the range 0 to 255. Any
  /// integer, which is not in that range, is converted to a byte as if by
  /// `value.toUnsigned(8)`.
  NSData toNSData() {
    if (length == 0) {
      return NSData.new1();
    }
    final buffer = malloc<Uint8>(length);
    buffer.asTypedList(length).setAll(0, this);

    return NSData.dataWithBytesNoCopy_length_(buffer.cast(), length);
  }
}
