// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Whether a record is bound as a plain C struct or as a C++ class is decided
// by whether it is POD (plain old data), not by the `class`/`struct` keyword:
// the two keywords differ only in default member access.

// A POD record declared with the `class` keyword. It is bound as a plain C
// struct with its fields modelled.
class PodPoint {
 public:
  int x;
  int y;
};

// A POD record declared with the `struct` keyword, for parity.
struct PodPair {
  int a;
  int b;
};

// A record declared with the `struct` keyword that is not POD: the
// user-declared constructor and the private field both disqualify it, so it
// gets the C++ class treatment instead.
struct NonPodCounter {
  NonPodCounter(int start);
  int next();

 private:
  int value_;
};
