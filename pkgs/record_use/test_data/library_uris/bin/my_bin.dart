// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:library_uris/library_uris.dart';
import 'package:library_uris_helper/library_uris_helper.dart';
import 'package:meta/meta.dart';

void main() {
  helloFoo();
  MyClass.myMethod('bar');
  helloBar();
  ClassInHelper.methodInHelper('bar');
  methodInBin();
}

// ignore: experimental_member_use
@RecordUse()
void methodInBin() {
  print('The answer to the universe, life, and everything.');
}
