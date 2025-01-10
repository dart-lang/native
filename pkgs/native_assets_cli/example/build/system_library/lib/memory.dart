// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Example of using system libraries.
@DefaultAsset('package:system_library/memory.dart')
library;

import 'dart:ffi';

@Native<Pointer Function(IntPtr)>()
external Pointer malloc(int size);

@Native<Void Function(Pointer)>()
external void free(Pointer pointer);

@Native<Pointer Function(Size)>()
external Pointer coTaskMemAlloc(int cb);

@Native<Void Function(Pointer)>()
external void coTaskMemFree(Pointer pv);
