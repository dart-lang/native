// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'third_party/unix.dart' as unix;
import 'third_party/windows.dart' as windows;

/// The machine's hostname.
///
/// Returns `null` if looking up the machines host name fails.
String? get hostName => using((arena) {
  const maxHostNameLength = 256;
  final buffer = arena<Char>(maxHostNameLength);
  final result = Platform.isWindows
      ? windows.gethostname(buffer, maxHostNameLength)
      : unix.gethostname(buffer, maxHostNameLength);

  if (result != 0) {
    // The `errno` or `WSAGetLastError` are not preserved currently.
    // https://github.com/dart-lang/sdk/issues/38832 So, simply return null
    // instead of throwing an exception with the system error message. (A
    // possible workaround is to do the `errno` and `WSAGetLastError` in C
    // wrapper functions. However, this example project is meant to show an
    // example without compiling C code.)
    return null;
  }

  return buffer.cast<Utf8>().toDartString();
});
