// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Declarations inside an `extern "C"` block are wrapped in a LinkageSpec
// cursor when parsing in C++ mode, and must be dispatched like top-level
// declarations rather than skipped.

extern "C" {

enum Fruit { apple = 1, banana = 2 };

struct Pair {
  int a;
  int b;
};

union Number {
  int i;
  float f;
};

int add(int a, int b);

extern int counter;

// A linkage spec nested inside another linkage spec.
extern "C" {
int deep(void);
}

}  // extern "C"

// Single-declaration form, without braces.
extern "C" void reset(void);

// A linkage spec nested inside a namespace.
namespace ns {
extern "C" {
enum Flag { off = 0, on = 1 };
}
}  // namespace ns

// A declaration outside any linkage spec, to check that regular declarations
// still parse alongside `extern "C"` blocks.
int outside(double d);
