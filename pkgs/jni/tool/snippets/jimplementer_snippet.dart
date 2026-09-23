// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_dynamic_calls, avoid_print, undefined_method
// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'package:jni/jni.dart';

dynamic Foo;
dynamic fooImpl;
dynamic Bar;
dynamic barImpl;

void main() {
  // snippet-start
  final implementer = JImplementer();
  Foo.implementIn(implementer, fooImpl);
  Bar.implementIn(implementer, barImpl);
  final foobar = implementer.build(Foo.type); // Or `Bar.type`.
  // snippet-end
}
