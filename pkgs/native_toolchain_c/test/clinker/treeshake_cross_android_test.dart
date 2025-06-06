// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';

import 'treeshake_helper.dart';

Future<void> main() async {
  final architectures = [
    Architecture.arm,
    Architecture.arm64,
    Architecture.ia32,
    Architecture.x64,
    Architecture.riscv64,
  ];

  const targetOS = OS.android;

  await runTreeshakeTests(targetOS, architectures);
}
