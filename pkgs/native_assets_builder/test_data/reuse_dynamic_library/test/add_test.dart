// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:reuse_dynamic_library/my_add.dart';
import 'package:test/test.dart';

void main() {
  test('invoke native function', () {
    expect(my_add(24, 18), 42);
  });
}
