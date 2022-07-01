// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:jni_gen/jni_gen.dart';

void main() {
  test('dummy test', () {
    final result = mySum(2, 40);
    expect(result, 42);
  });
}
