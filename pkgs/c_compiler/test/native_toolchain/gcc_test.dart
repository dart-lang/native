// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:c_compiler/src/native_toolchain/gcc.dart';
import 'package:c_compiler/src/tool/tool.dart';
import 'package:c_compiler/src/tool/tool_requirement.dart';
import 'package:c_compiler/src/tool/tool_resolver.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  void testToolSet(String name, List<Tool> tools) {
    test('gcc cross compilation $name smoke test', () async {
      final resolver = ToolResolvers([
        for (final tool in tools) tool.defaultResolver!,
      ]);

      final resolved = await resolver.resolve(logger: logger);
      printOnFailure(resolved.toString());
      expect(resolved.isNotEmpty, true);

      final requirement = RequireAll([
        for (final tool in tools) ToolRequirement(tool),
      ]);

      final satisfied = requirement.satisfy(resolved);
      printOnFailure(tools.toString());
      printOnFailure(satisfied.toString());
      expect(satisfied?.length, tools.length);
    });
  }

  testToolSet('aarch64LinuxGnuGcc', [
    aarch64LinuxGnuGcc,
    aarch64LinuxGnuGccAr,
    aarch64LinuxGnuLd,
  ]);

  testToolSet('armLinuxGnueabihfGcc', [
    armLinuxGnueabihfGcc,
    armLinuxGnueabihfGccAr,
    armLinuxGnueabihfLd,
  ]);

  testToolSet('i686LinuxGnuGcc', [
    i686LinuxGnuGcc,
    i686LinuxGnuGccAr,
    i686LinuxGnuLd,
  ]);
}
