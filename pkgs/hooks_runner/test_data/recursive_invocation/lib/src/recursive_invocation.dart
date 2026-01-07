// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:ffi/ffi.dart';

String get someString {
  final nativeString = _returnAStringNative();
  return nativeString.cast<Utf8>().toDartString();
}

@Native<Pointer<Char> Function()>(symbol: 'return_a_string')
external Pointer<Char> _returnAStringNative();
