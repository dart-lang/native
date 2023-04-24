// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <stdint.h>

#if _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT
#endif

FFI_EXPORT int32_t add(int32_t a, int32_t b) {
   return a+b;
}
