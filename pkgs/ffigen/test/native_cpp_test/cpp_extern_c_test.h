// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Declarations inside an `extern "C"` block are wrapped in a LinkageSpec
// cursor when parsing in C++ mode, and must be dispatched like top-level
// declarations rather than skipped. Declarations outside any `extern "C"`
// block are reached through generated `extern "C"` wrappers.

// C-linkage declarations are looked up directly, so they must be exported.
#if defined(_WIN32)
#define EXTERN_C_TEST_EXPORT __declspec(dllexport)
#else
#define EXTERN_C_TEST_EXPORT
#endif

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

EXTERN_C_TEST_EXPORT int add(int a, int b);

EXTERN_C_TEST_EXPORT extern int counter;

// A linkage spec nested inside another linkage spec.
extern "C" {
EXTERN_C_TEST_EXPORT int deep(void);
}

// The innermost linkage spec wins.
extern "C++" int nestedCpp(int x);

}  // extern "C"

// Single-declaration form, without braces.
extern "C" EXTERN_C_TEST_EXPORT void reset(void);

// A linkage spec nested inside a namespace.
namespace ns {
extern "C" {
enum Flag { off = 0, on = 1 };
}
}  // namespace ns

// Declarations outside any linkage spec have C++ linkage.
int outside(double d);

extern int outsideCounter;

// A function pointer parameter in a wrapper.
int applyTwice(int (*fn)(int), int x);
