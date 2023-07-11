// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
@OnPlatform({
  'mac-os': Timeout.factor(2),
})
library;

import 'dart:io';

import 'package:native_toolchain_c/src/native_toolchain/apple_clang.dart';
import 'package:native_toolchain_c/src/tool/tool_requirement.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  test('smoke test', () async {
    final requirement = ToolRequirement(appleClang,
        minimumVersion: Version(12, 0, 0, pre: '0'));
    final resolved = await appleClang.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, 1);
  });

  test('ar test', () async {
    final requirement = ToolRequirement(appleAr);
    final resolved = await appleAr.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, 1);
  });

  test('ld test', () async {
    final requirement = ToolRequirement(appleLd);
    final resolved = await appleLd.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, 1);
  });

  test('otool test', () async {
    final requirement = ToolRequirement(otool);
    final resolved = await otool.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
    final satisfied = requirement.satisfy(resolved);
    expect(satisfied?.length, 1);
  });
}
