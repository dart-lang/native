// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@ffi.DefaultAsset('package:treeshaking_dylib_record_use/multiply')
library;

import 'dart:ffi' as ffi;

// Manually copied and removed the record use annotation. So that we can try to
// call it from tests and see the test invocation fail.
@ffi.Native<ffi.Int32 Function(ffi.Int32, ffi.Int32)>()
external int multiplyNotRecorded(
  int a,
  int b,
);
