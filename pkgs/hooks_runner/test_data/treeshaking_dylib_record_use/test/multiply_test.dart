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
  test('multiply works, but divide is tree-shaken', () {
    // Dynamic lookup via Process only works on platforms where the dynamic
    // linker searches RTLD_LOCAL loaded libraries (like macOS and Windows).
    // TODO(https://github.com/dart-lang/sdk/issues/63295): Use
    // DynamicLibrary.openAsset when available.
    final skipDynamicLookup = (Platform.isLinux || Platform.isAndroid)
        ? 'DynamicLibrary.process() does not search RTLD_LOCAL libraries on Linux/Android'
        : null;

    // 1. Statically call `multiply`, which records it as used and keeps it.
    expect(multiply(14, 3), equals(42));

    // 2. Look up 'multiply' dynamically; it should succeed.
    final process = DynamicLibrary.process();
    expect(
      () => process.lookup<NativeFunction<Int32 Function(Int32, Int32)>>(
        'multiply',
      ),
      returnsNormally,
      skip: skipDynamicLookup,
    );

    // 3. 'divide' is not statically called, so it should be tree-shaken
    // and not available in the process.
    expect(
      () => process.lookup<NativeFunction<Int32 Function(Int32, Int32)>>(
        'divide',
      ),
      throwsArgumentError,
      skip: skipDynamicLookup,
    );
  });
}
