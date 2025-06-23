// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Example of using system libraries.
@DefaultAsset('package:system_library/memory.dart')
library;

import 'dart:ffi';

/// Allocates [size] bytes of memory.
///
/// Corresponds to `malloc` on POSIX systems.
@Native<Pointer Function(IntPtr)>()
external Pointer malloc(int size);

/// Frees memory previously allocated by [malloc].
@Native<Void Function(Pointer)>()
external void free(Pointer pointer);

/// Allocates a block of task memory in the same way that `CoTaskMemAlloc` does.
///
/// Only available on Windows.
@Native<Pointer Function(Size)>(symbol: 'CoTaskMemAlloc')
external Pointer coTaskMemAlloc(int cb);

/// Frees a block of task memory previously allocated through [coTaskMemAlloc].
///
/// Only available on Windows.
@Native<Void Function(Pointer)>(symbol: 'CoTaskMemFree')
external void coTaskMemFree(Pointer pv);
