// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "add.h"
#include "math.h"

int32_t add(int32_t a, int32_t b) {
  // Here we are calling a function from the math library, which will be
  // loaded by the dynamic linker.
  return math_add(a, b);
}
