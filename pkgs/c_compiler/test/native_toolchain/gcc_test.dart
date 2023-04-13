// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:c_compiler/src/native_toolchain/gcc.dart';
import 'package:c_compiler/src/tool/tool_requirement.dart';
import 'package:c_compiler/src/tool/tool_resolver.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('gcc cross compilation smoke test', () async {
    final tools = [
      aarch64LinuxGnuGcc,
      aarch64LinuxGnuGccAr,
      aarch64LinuxGnuGccLd,
      armLinuxGnueabihfGcc,
      armLinuxGnueabihfGccAr,
      armLinuxGnueabihfGccLd,
      i686LinuxGnuGcc,
      i686LinuxGnuGccAr,
      i686LinuxGnuGccLd,
    ];

    final resolver = ToolResolvers([
      for (final tool in tools) tool.defaultResolver!,
    ]);

    final resolved = await resolver.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);

    final requirement = RequireAll([
      for (final tool in tools) ToolRequirement(tool),
    ]);

    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, tools.length);
  });
}
