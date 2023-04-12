// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:c_compiler/src/native_toolchain/clang.dart';
import 'package:c_compiler/src/tool/tool_requirement.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

void main() {
  test('clang smoke test', () async {
    final requirement =
        ToolRequirement(clang, minimumVersion: Version(14, 0, 0));
    final resolved = await clang.defaultResolver!.resolve();
    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, 1);
  });
}
