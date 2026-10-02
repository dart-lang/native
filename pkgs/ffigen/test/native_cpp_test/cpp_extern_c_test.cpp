// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "cpp_extern_c_test.h"

int add(int a, int b) { return a + b; }

int counter = 7;

int deep(void) { return 42; }

int nestedCpp(int x) { return x * 2; }

void reset(void) {
  counter = 0;
  outsideCounter = 0;
}

int outside(double d) { return outsideCounter + static_cast<int>(d); }

int outsideCounter = 100;

int applyTwice(int (*fn)(int), int x) { return fn(fn(x)); }
