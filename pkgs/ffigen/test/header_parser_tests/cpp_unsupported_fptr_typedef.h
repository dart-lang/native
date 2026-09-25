// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

struct Widget;

// A function pointer whose parameters include a C++ reference, which has no
// Dart mapping, reached through one or two typedefs.
typedef void (*BadCallback)(int, Widget&, int);
typedef BadCallback BadCallbackAlias;

// Bindable: the same shape with only pointers and primitives.
typedef void (*GoodCallback)(int, Widget*, int);

// Only reaches the unsupported function pointer through the typedefs.
struct Holder {
  int id;
  GoodCallback good;
  BadCallback bad;
  BadCallbackAlias badAlias;
};

// Control: spells the unsupported function pointer out directly.
struct DirectHolder {
  int id;
  void (*badDirect)(int, Widget&, int);
};

// Regular functions taking the typedefs.
void useGood(GoodCallback cb);
void useBad(BadCallback cb);
void useBadAlias(BadCallbackAlias cb);
