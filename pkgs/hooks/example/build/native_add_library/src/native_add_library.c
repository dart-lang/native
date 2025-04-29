// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "native_add_library.h"

#ifdef DEBUG
#include <stdio.h>
#endif

int32_t add(int32_t a, int32_t b) {
#ifdef DEBUG
  printf("Adding %i and %i.\n", a, b);
#endif
  return a + b;
}
