// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:treeshaking_native_libs/treeshaking_native_libs.dart';

void main() {
  test('native add test', () {
    final result = add(4, 6);
    expect(result, equals(10));
  });
}
