// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'objective_c_bindings_generated.dart';

extension IntToNSNumber on int {
  NSNumber toNSNumber() => NSNumber.alloc().initWithLongLong(this);
}

extension DoubleToNSNumber on double {
  NSNumber toNSNumber() => NSNumber.alloc().initWithDouble(this);
}

extension NumToNSNumber on num {
  NSNumber toNSNumber() {
    final value = this;
    return switch (value) {
      int() => NSNumber.alloc().initWithLongLong(value),
      double() => NSNumber.alloc().initWithDouble(value),
    };
  }
}

extension BoolToNSNumber on bool {
  NSNumber toNSNumber() => NSNumber.alloc().initWithBool(this);
}

extension NSNumberToNum on NSNumber {
  num get numValue => isFloat ? doubleValue : longLongValue;
}
