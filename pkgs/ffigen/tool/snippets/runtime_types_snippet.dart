// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable, prefer_final_locals

// snippet-start#static_vs_runtime_type
class Base {}

class Child extends Base {}

void main() {
  Base x = Child(); // x has a static type of Base
  print(x.runtimeType); // but a runtime type of Child
}
// snippet-end#static_vs_runtime_type
