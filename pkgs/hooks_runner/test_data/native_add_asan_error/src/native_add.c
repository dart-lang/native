// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "native_add.h"

#include <stdlib.h>

int32_t add(int32_t a, int32_t b) {
   volatile char* buffer = malloc(1);
   buffer[1] = 0;
   free((void*)buffer);
   return a + b;
}
