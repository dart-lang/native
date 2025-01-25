// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('linux')
library;

import 'dart:io';

import 'package:native_toolchain_c/src/native_toolchain/clang.dart';
import 'package:native_toolchain_c/src/tool/tool_instance.dart';
import 'package:native_toolchain_c/src/tool/tool_requirement.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (Platform.isMacOS ||
      (Platform.isWindows &&
          Platform.environment['DART_HOOK_TESTING_C_COMPILER__CC']
                  ?.endsWith('cl.exe') ==
              true)) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  test('clang smoke test', () async {
    final requirement =
        ToolRequirement(clang, minimumVersion: Version(14, 0, 0, pre: '0'));
    final resolved = await clang.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, 1);
  });

  test('clang versions', () {
    final clangInstance = ToolInstance(
      tool: clang,
      uri: Uri.file('some/path'),
      version: Version.parse('14.0.0-1'),
    );
    final requirement =
        ToolRequirement(clang, minimumVersion: Version(14, 0, 0, pre: '0'));
    final satisfied = requirement.satisfy([clangInstance]);
    expect(satisfied?.length, 1);
  });

  test('llvm-ar smoke test', () async {
    final requirement = ToolRequirement(llvmAr);
    final resolved = await llvmAr.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, 1);
  });

  test('ld test', () async {
    final requirement = ToolRequirement(lld);
    final resolved = await lld.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, 1);
  });
}
