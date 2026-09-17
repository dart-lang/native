// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A type named through a using-declaration has no `CXTypeKind` of its own, so
// libclang reports it as unexposed with no modified type. Such a type must
// still resolve to the type it names, otherwise every function mentioning it
// is dropped from the bindings. This is how `std::uint16_t` and friends reach
// the parser, without needing the C++ standard library to reproduce it.

namespace base {
typedef unsigned short u16;
using u32 = unsigned int;

struct Point {
  int x;
  int y;
};

enum Color { red, green, blue };
}  // namespace base

// using-declarations bringing the names into the global scope.
using base::Color;
using base::Point;
using base::u16;
using base::u32;

u16 take_u16(u16 v);
u32 take_u32(u32 v);
Point take_point(Point p);
Color take_color(Color c);

// Controls: the same types, named through their namespace instead of a
// using-declaration. These were never affected.
base::u16 control_u16(base::u16 v);
base::Point control_point(base::Point p);

// Controls spelling the underlying types directly, for comparing against what
// the using-declared ones resolve to.
unsigned short control_ushort(unsigned short v);
unsigned int control_uint(unsigned int v);
