// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('!kernel')
library;

import 'dart:ffi';
import 'package:test/test.dart';
import 'package:treeshaking_dylib_record_use/treeshaking_dylib_record_use.dart';

void main() {
  test('multiply', () {
    expect(multiply(14, 3), equals(42));

    final process = DynamicLibrary.process();
    expect(
      process.lookup<NativeFunction<Int32 Function(Int32, Int32)>>('multiply'),
      isNotNull,
    );

    expect(
      () => process.lookup<NativeFunction<Int32 Function(Int32, Int32)>>(
        'divide',
      ),
      throwsArgumentError,
    );
  });
}
