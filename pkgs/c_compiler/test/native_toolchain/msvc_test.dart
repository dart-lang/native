// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('windows')
library;

import 'dart:io';

import 'package:c_compiler/src/native_toolchain/msvc.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isWindows) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  test('vswhere', () async {
    final instances = await vswhere.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
  });

  test('msvc', () async {
    final instances = await msvc.defaultResolver!.resolve(logger: logger);
    expect(instances.isNotEmpty, true);
  });
}
