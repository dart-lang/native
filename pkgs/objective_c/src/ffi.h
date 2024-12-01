// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_FFI_H_
#define OBJECTIVE_C_SRC_FFI_H_

// Ensure that an FFI function, that will appear unused by the linker, will
// not be removed.
#define FFI_EXPORT __attribute__((visibility("default"))) __attribute__((used))

#endif // OBJECTIVE_C_SRC_FFI_H_
