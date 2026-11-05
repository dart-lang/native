// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:objective_c/objective_c.dart';

void main() {
  // Objective-C is only supported on macOS and iOS.
  assert(Platform.isMacOS || Platform.isIOS);

  print('Hello World'.toNSString().toDartString());
}
