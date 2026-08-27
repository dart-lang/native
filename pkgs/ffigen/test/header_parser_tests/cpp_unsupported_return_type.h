// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class Widget {
 public:
  Widget();

  // Bindable: these must survive.
  int good() const;
  Widget* self();

  // A C++ reference has no Dart mapping.
  int& badRef();
  const Widget& badConstRef() const;
};
