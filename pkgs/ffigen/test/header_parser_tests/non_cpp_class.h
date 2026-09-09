// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A C++ header parsed without C++ support configured: classes must still be
// usable through pointers, like opaque structs, so that functions mentioning
// them are not dropped from the bindings.

// A class with a definition.
class Widget {
 public:
  Widget(int size);
  int size() const;

 private:
  int size_;
};

// A forward-declared (definition-less) class.
class Gadget;

Widget* widget_create(int size);
int widget_size(Widget* widget);
void widget_destroy(Widget* widget);
Gadget* gadget_create(void);
