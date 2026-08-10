// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('!kernel')
library;

import 'dart:ffi';
import 'dart:io';
import 'package:test/test.dart';
import 'package:treeshaking_dylib_record_use/treeshaking_dylib_record_use.dart';

void main() {
  test('subtract works, but add and multiply are tree-shaken', () {
    // Dynamic lookup via Process only works on platforms where the dynamic
    // linker searches RTLD_LOCAL loaded libraries (like macOS and Windows).
    // TODO(https://github.com/dart-lang/sdk/issues/63295): Use
    // DynamicLibrary.openAsset when available.
    final skipDynamicLookup = (Platform.isLinux || Platform.isAndroid)
        ? 'DynamicLibrary.process() does not search RTLD_LOCAL libraries on Linux/Android'
        : null;

    // 1. Statically call `subtract`, which records it as used and keeps it.
    expect(subtract(10, 5), equals(5));

    // 2. Look up 'subtract' dynamically; it should succeed.
    final process = DynamicLibrary.process();
    expect(
      () => process.lookup<NativeFunction<Int32 Function(Int32, Int32)>>(
        'subtract',
      ),
      returnsNormally,
      skip: skipDynamicLookup,
    );

    // 3. 'add' is not statically called, so it should be tree-shaken
    // and not available in the process.
    expect(
      () => process.lookup<NativeFunction<Int32 Function(Int32, Int32)>>('add'),
      throwsArgumentError,
      skip: skipDynamicLookup,
    );

    // 4. 'multiply' is completely unused, so the entire multiply library
    // is omitted.
    expect(
      () => multiplyNotRecorded(3, 10),
      throwsArgumentError,
    );
  });
}
