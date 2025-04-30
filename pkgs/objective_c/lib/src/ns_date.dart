// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffi/ffi.dart';
import 'objective_c_bindings_generated.dart';

extension DateTimeToNSDate on DateTime {
  NSDate toNSDate() => NSDate.dateWithTimeIntervalSince1970_(
      millisecondsSinceEpoch / Duration.millisecondsPerSecond);
}

extension NSDateToDateTime on NSDate {
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(
      (timeIntervalSince1970 * Duration.millisecondsPerSecond).toInt());
}
