// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffi/ffi.dart';
import 'objective_c_bindings_generated.dart';

extension IntToNSNumber on int {
  NSNumber toNSNumber() => NSNumber.alloc().initWithLongLong_(this);
}

extension DoubleToNSNumber on double {
  NSNumber toNSNumber() => NSNumber.alloc().initWithDouble_(this);
}

extension NumToNSNumber on num {
  NSNumber toNSNumber() {
    final value = this;
    return switch (value) {
      int() => NSNumber.alloc().initWithLongLong_(value),
      double() => NSNumber.alloc().initWithDouble_(value),
    };
  }
}
