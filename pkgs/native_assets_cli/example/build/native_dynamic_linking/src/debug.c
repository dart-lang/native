// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "debug.h"

#ifdef DEBUG
#include <stdio.h>
#endif

int debug_printf(const char* format, ...) {
#ifdef DEBUG
  va_list args;
  va_start(args, format);
  int ret = vprintf(format, args);
  va_end(args);
  return ret;
#endif
}
