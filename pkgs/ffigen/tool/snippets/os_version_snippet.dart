// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

// ignore_for_file: avoid_print, unused_local_variable

import 'package:objective_c/objective_c.dart';

void checkOsVersionExample() {
  // snippet-start
  // If you only need to support iOS:
  if (checkOSVersion(iOS: Version(18, 0, 0))) {
    // Use newer iOS 18 API.
  } else {
    // Fallback to old API.
  }

  // If you need to support iOS and macOS:
  if (checkOSVersion(iOS: Version(18, 0, 0), macOS: Version(15, 3, 0))) {
    // Use newer API available in iOS 18 and macOS 15.3.
  } else {
    // Fallback to old API.
  }
  // snippet-end
}
