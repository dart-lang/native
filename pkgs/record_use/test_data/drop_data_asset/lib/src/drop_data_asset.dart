// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: experimental_member_use

import 'package:meta/meta.dart';

class MyMath {
  @RecordUse()
  static int add(int a, int b) => a + b;

  @RecordUse()
  static int multiply(int a, int b) => a * b;
}

@RecordUse()
class Double {
  final int value;
  const Double(this.value);

  int run() => value + value;
}

@RecordUse()
class Square {
  final int value;
  const Square(this.value);

  int run() => value * value;
}
