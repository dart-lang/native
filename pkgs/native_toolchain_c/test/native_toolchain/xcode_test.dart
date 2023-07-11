// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
@OnPlatform({
  'mac-os': Timeout.factor(2),
})
library;

import 'dart:io';

import 'package:native_toolchain_c/src/native_toolchain/xcode.dart';
import 'package:native_toolchain_c/src/tool/tool.dart';
import 'package:native_toolchain_c/src/tool/tool_instance.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  test('xcrun', () async {
    final resolved = (await xcrun.defaultResolver!.resolve(logger: logger))
        .where((i) => i.tool == xcrun);
    expect(resolved.isNotEmpty, true);
  });

  test('macosxSdk', () async {
    final resolved = (await macosxSdk.defaultResolver!.resolve(logger: logger))
        .where((i) => i.tool == macosxSdk);
    expect(resolved.isNotEmpty, true);
  });

  test('iPhoneOSSdk', () async {
    final resolved =
        (await iPhoneOSSdk.defaultResolver!.resolve(logger: logger))
            .where((i) => i.tool == iPhoneOSSdk);
    expect(resolved.isNotEmpty, true);
  });

  test('iPhoneSimulatorSdk', () async {
    final resolved =
        (await iPhoneSimulatorSdk.defaultResolver!.resolve(logger: logger))
            .where((i) => i.tool == iPhoneSimulatorSdk);
    expect(resolved.isNotEmpty, true);
  });

  test('non-existing SDK', () async {
    final xcrunInstance =
        (await xcrun.defaultResolver!.resolve(logger: logger)).first;
    final tool = Tool(name: 'non-tool');
    final result = await XCodeSdkResolver.tryResolveSdk(
      xcrunInstance: xcrunInstance,
      sdk: 'doesnotexist',
      tool: tool,
      logger: logger,
    );
    expect(result, <ToolInstance>[]);
  });
}
