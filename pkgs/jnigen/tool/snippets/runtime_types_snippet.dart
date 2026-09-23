// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:jni/jni.dart';

// snippet-start#static_vs_runtime_type
class Base {}

class Child extends Base {}

void main() {
  Base x = Child(); // x has a static type of Base
  print(x.runtimeType); // but a runtime type of Child
}
// snippet-end#static_vs_runtime_type

void castExample(dynamic foo) {
  // snippet-start#cast_memory
  final JNumber num = foo.someJNumber();
  // Cast to JInteger and release the original JNumber reference.
  final JInteger jint = num.as(JInteger.type, releaseOriginal: true);
  // It's not safe to use num after this.
  // snippet-end#cast_memory
}
