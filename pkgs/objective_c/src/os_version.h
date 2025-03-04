// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_OS_VERSION_H_
#define OBJECTIVE_C_SRC_OS_VERSION_H_

#include "ffi.h"

typedef struct _Version {
  int major;
  int minor;
  int patch;
} Version;

/// Returns the MacOS/iOS version we're running on.
FFI_EXPORT Version DOBJC_getOsVesion(void);

#endif // OBJECTIVE_C_SRC_OS_VERSION_H_
