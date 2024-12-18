// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//TODO(mosuem): Enable for windows and mac.
// See https://github.com/dart-lang/native/issues/1376.
@TestOn('linux')
library;

import 'dart:io';

import 'package:native_assets_cli/code_assets.dart';
import 'package:test/test.dart';

import 'treeshake_helper.dart';

Future<void> main() async {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  final architectures = [
    Architecture.arm,
    Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
    Architecture.riscv64,
  ]..remove(Architecture.current);

  await runTests(architectures);
}
