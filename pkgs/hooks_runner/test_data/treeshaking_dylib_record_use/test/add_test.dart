// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('!kernel')
library;

import 'dart:ffi';
import 'package:test/test.dart';
import 'package:treeshaking_dylib_record_use/treeshaking_dylib_record_use.dart';

void main() {
  test('add works, but subtract and multiply are tree-shaken', () {
    // 1. Statically call `add`, which records it as used and keeps it.
    expect(add(10, 5), equals(15));

    // 2. Look up 'add' dynamically; it should succeed.
    final process = DynamicLibrary.process();
    expect(
      process.lookup<NativeFunction<Int32 Function(Int32, Int32)>>('add'),
      isNotNull,
    );

    // 3. 'subtract' is not statically called, so it should be tree-shaken
    // and not available in the process.
    expect(
      () => process.lookup<NativeFunction<Int32 Function(Int32, Int32)>>(
        'subtract',
      ),
      throwsArgumentError,
    );

    // 4. 'multiply' is completely unused, so the entire multiply library
    // is omitted.
    expect(
      () => multiplyNotRecorded(3, 10),
      throwsArgumentError,
    );
  });
}
