// Copyright (c) 2019, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

/// [Utf16] implements conversion between Dart strings and zero-terminated
/// UTF-16 encoded "char*" strings in C.
///
/// [Utf16] is represented as a struct so that `Pointer<Utf16>` can be used in
/// native function signatures.
class Utf16 extends Struct {
  /// Convert a [String] to a UTF-16 encoded zero-terminated C string.
  ///
  /// If [string] contains NULL characters, the converted string will be truncated
  /// prematurely. Unpaired surrogate code points in [string] will be preserved
  /// in the UTF-16 encoded result. See [Utf16Encoder] for details on encoding.
  ///
  /// Returns a malloc-allocated pointer to the result.
  static Pointer<Utf16> toUtf16(String string) {
    final units = string.codeUnits;
    final Pointer<Uint16> result = allocate<Uint16>(count: units.length + 1);
    final Uint16List nativeString = result.asTypedList(units.length + 1);
    nativeString.setAll(0, units);
    nativeString[units.length] = 0;
    return result.cast();
  }
}
