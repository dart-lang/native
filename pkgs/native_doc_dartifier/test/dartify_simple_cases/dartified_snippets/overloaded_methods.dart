// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../bindings.dart';

int overloadedMethods() {
  final acc1 = Accumulator();
  acc1.add(10);
  acc1.add$1(10, 10);
  acc1.add$2(10, 10, 10);

  final acc2 = Accumulator.new$1(20);
  acc2.add$3(acc1);

  final acc3 = Accumulator.new$2(acc2);
  return acc3.accumulator;
}
