// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_add_library/native_add_library.dart';

void main() {
  print('Invoking a native function to calculate 1 + 2.');
  final result = add(1, 2);
  print('Invocation success: 1 + 2 = $result.');
}
