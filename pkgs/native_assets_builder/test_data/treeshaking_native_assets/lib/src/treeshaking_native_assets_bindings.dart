// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' as ffi;

@ffi.Native<ffi.Int32 Function(ffi.Int32, ffi.Int32)>()
external int add(
  int a,
  int b,
);

@ffi.Native<ffi.Int32 Function(ffi.Int32, ffi.Int32)>()
external int multiply(
  int a,
  int b,
);
