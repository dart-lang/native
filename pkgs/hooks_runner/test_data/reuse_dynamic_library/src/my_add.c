// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "my_add.h"
#include "add.h"

int32_t my_add(int32_t a, int32_t b) {
  // Here we are calling a function from a dynamically linked library.
  return add(a, b);
}
