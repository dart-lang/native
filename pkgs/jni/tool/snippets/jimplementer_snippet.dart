// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

import 'package:jni/jni.dart';

extension type Foo(JObject _) implements JObject {
  static void implementIn(JImplementer implementer, dynamic impl) {}
}

dynamic fooImpl;

extension type Bar(JObject _) implements JObject {
  static void implementIn(JImplementer implementer, dynamic impl) {}
}

dynamic barImpl;

void main() {
  // snippet-start
  final implementer = JImplementer();
  Foo.implementIn(implementer, fooImpl);
  Bar.implementIn(implementer, barImpl);
  final foobar = implementer.implement<Foo>(); // Or Bar.
  // snippet-end
  print(foobar);
}
