// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_toolchain_c/src/native_toolchain/android_ndk.dart';
import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/tool/tool.dart';
import 'package:native_toolchain_c/src/tool/tool_resolver.dart';
import 'package:test/test.dart';

void main() {
  test('equals and hashCode', () async {
    expect(clang, clang);
    expect(clang != androidNdk, true);
    expect(
      Tool(name: 'foo'),
      Tool(name: 'foo', defaultResolver: PathToolResolver(toolName: 'foo')),
    );
    expect(Tool(name: 'foo') != Tool(name: 'bar'), true);
    expect(
      Tool(name: 'foo').hashCode,
      Tool(
        name: 'foo',
        defaultResolver: PathToolResolver(toolName: 'foo'),
      ).hashCode,
    );
    expect(Tool(name: 'foo').hashCode != Tool(name: 'bar').hashCode, true);
  });
}
