// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// The contents of a native zero-terminated array of UTF-8 code units.
///
/// The Utf8 type itself has no functionality, it's only intended to be used
/// through a `Pointer<Utf8>` representing the entire array. This pointer is
/// the equivalent of a char pointer (`const char*`) in C code.
class Utf8 extends Opaque {}

/// Extension method for converting a`Pointer<Utf8>` to a [String].
extension Utf8Pointer on Pointer<Utf8> {
  /// The number of UTF-8 code units in this zero-terminated UTF-8 string.
  ///
  /// The UTF-8 code units of the strings are the non-zero code units up to the
  /// first zero code unit.
  int get length {
    final Pointer<Uint8> array = cast<Uint8>();
    int length = 0;
    while (array[length] != 0) {
      length++;
    }
    return length;
  }

  /// Converts this UTF-8 encoded string to a Dart string.
  ///
  /// Decodes the UTF-8 code units of this zero-terminated byte array as
  /// Unicode code points and creates a Dart string containing those code
  /// points.
  ///
  /// If [length] is provided, zero-termination is ignored and the result can
  /// contain NUL characters.
  String toDartString({int? length}) {
    if (length != null) {
      RangeError.checkNotNegative(length, 'length');
    } else {
      length = this.length;
    }
    return utf8.decode(cast<Uint8>().asTypedList(length));
  }
}

/// Extension method for converting a [String] to a `Pointer<Utf8>`.
extension StringUtf8Pointer on String {
  /// Creates a zero-terminated [Utf8] code-unit array from this String.
  ///
  /// If this [String] contains NUL characters, converting it back to a string
  /// using [Utf8Pointer.toDartString] will truncate the result if a length is
  /// not passed.
  ///
  /// Unpaired surrogate code points in this [String] will be encoded as
  /// replacement characters (U+FFFD, encoded as the bytes 0xEF 0xBF 0xBD) in
  /// the UTF-8 encoded result. See [Utf8Encoder] for details on encoding.
  ///
  /// Returns an [allocator]-allocated pointer to the result.
  Pointer<Utf8> toNativeUtf8({Allocator allocator = malloc}) {
    final units = utf8.encode(this);
    final Pointer<Uint8> result = allocator<Uint8>(units.length + 1);
    final Uint8List nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}
