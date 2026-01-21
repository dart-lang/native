// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:library_uris_helper/library_uris_helper.dart';

import 'definition.dart';

void helloFoo() {
  MyClass.myMethod('foo');
  ClassInHelper.methodInHelper('foo');
  helloBar();
}
