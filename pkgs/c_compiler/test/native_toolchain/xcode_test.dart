// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
library;

import 'package:c_compiler/src/native_toolchain/xcode.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('xcrun', () async {
    final resolved = await xcrun.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
  });

  test('iPhoneOSSdk', () async {
    final resolved = await iPhoneOSSdk.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
  });

  test('iPhoneSimulatorSdk', () async {
    final resolved =
        await iPhoneSimulatorSdk.defaultResolver!.resolve(logger: logger);
    expect(resolved.isNotEmpty, true);
  });
}
