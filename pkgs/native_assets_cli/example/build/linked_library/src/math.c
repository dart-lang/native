// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "math.h"

#ifdef DEBUG
#include <stdio.h>
#endif

int32_t math_add(int32_t a, int32_t b) {
#ifdef DEBUG
  printf("Adding %i and %i.\n", a, b);
#endif
  return a + b;
}
