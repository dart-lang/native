// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file uses C++ standard library types whose typeinfo and vtable symbols
// are provided by libc++abi on Android. Building a shared library from this
// file with c++_static requires linking libc++abi in addition to libc++_static.

#include <stdexcept>

#if _WIN32
#define FFI_EXPORT __declspec(dllexport)
#else
#define FFI_EXPORT
#endif

FFI_EXPORT void throw_runtime_error() {
  throw std::runtime_error("test");
}
