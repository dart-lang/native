// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Top-level constexpr constants of various types.
constexpr int topInt = 5;
constexpr double topDouble = 3.5;
constexpr const char* topStr = "hello";

// A constexpr that references another constexpr in its initializer.
constexpr int topDerived = topInt * 2;

namespace ns {
// Constexpr in a namespace.
constexpr int nsInt = 42;

namespace inner {
// Constexpr in a nested namespace. Shares the leaf name `nsInt` with
// `ns::nsInt` to exercise leaf-name collisions.
constexpr int nsInt = 43;
}  // namespace inner
}  // namespace ns

struct Box {
  // Static constexpr data member of a struct. Non-static fields (like `size`)
  // are not constants and must not be surfaced as such.
  static constexpr int memberInt = 7;
  static constexpr double memberDouble = 2.5;
  int size;
};

class Widget {
 public:
  // Static constexpr data member of a class.
  static constexpr int classInt = 99;
};

namespace scoped {
class Gadget {
 public:
  // Static constexpr data member of a class nested in a namespace.
  static constexpr int gadgetInt = 100;
};
}  // namespace scoped
