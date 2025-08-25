// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'unix.dart' as unix;

int _gethostnameUnix(Pointer<Uint8> name, int len) =>
    unix.gethostname(name.cast<Char>(), len);

/// Get the host name on Windows systems.
///
/// C signature:
///
/// ```
/// int gethostname(
///   [out] char *name,
///   [in]  int  namelen
/// );
/// ```
@Native<Int Function(Pointer<Uint8>, Int)>(
  symbol: 'gethostname',
  assetId: 'package:host_name/src/host_name.dart',
)
external int _gethostnameWindows(Pointer<Uint8> name, int len);

/// The machine's hostname.
///
/// Returns `null` if looking up the machines host name fails.
String? get hostName => using((arena) {
  const maxHostNameLength = 256;
  final buffer = arena<Uint8>(maxHostNameLength);
  final result = Platform.isWindows
      ? _gethostnameWindows(buffer, maxHostNameLength)
      : _gethostnameUnix(buffer, maxHostNameLength);

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
