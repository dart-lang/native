// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:treeshaking_dylib_record_use/treeshaking_dylib_record_use.dart';

void main() {
  testNativeAdd();
  testNativeSubtract();
}

void testNativeAdd() {
  final answer = add(5, 6);
  if (answer != 5 + 6) {
    throw Exception('Wrong answer');
  }
  print('add(5, 6) = $answer');
}

void testNativeSubtract() {
  final answer = subtract(5, 6);
  if (answer != 5 - 6) {
    throw Exception('Wrong answer');
  }
  print('subtract(5, 6) = $answer');
}
