// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Structs and unions declared inside a namespace or a record are named by
// their enclosing scopes, flattened with `$` to form a Dart identifier.

namespace outer {
// Struct in a single namespace.
struct Point {
  int x;
  int y;
};

namespace inner {
// Struct in a nested namespace. Shares the leaf name `Point` with
// `outer::Point` and `other::Point`.
struct Point {
  float x;
  float y;
};
}  // namespace inner

class Palette {
 public:
  // Struct nested inside a class that is itself in a namespace.
  struct Entry {
    int tone;
  };
};
}  // namespace outer

namespace other {
// Another `Point`, in a different namespace, to exercise leaf-name collisions.
struct Point {
  double x;
};

// Union in a namespace.
union Value {
  int i;
  float f;
};
}  // namespace other

struct GlobalBox {
  // Struct nested inside a struct at global scope, also used as a member of
  // the enclosing struct.
  struct Lid {
    int hinge;
  };
  Lid lid;
  int size;
};
