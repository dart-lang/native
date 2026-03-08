// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'treeshake_helper.dart';

void main() {
  const targetOS = OS.android;

  // These configurations are a selection of combinations of architectures
  // and API levels.
  // We don't test the full cartesian product to keep the CI time manageable.
  // When adding a new configuration, consider if it tests a new combination
  // that is not yet covered by the existing tests.
  final configurations = [
    (
      architecture: Architecture.arm,
      apiLevel: flutterAndroidNdkVersionLowestSupported,
    ),
    (
      architecture: Architecture.arm64,
      apiLevel: flutterAndroidNdkVersionHighestSupported,
    ),
    (
      architecture: Architecture.ia32,
      apiLevel: flutterAndroidNdkVersionLowestSupported,
    ),
    (
      architecture: Architecture.x64,
      apiLevel: flutterAndroidNdkVersionHighestSupported,
    ),
    (
      architecture: Architecture.riscv64,
      apiLevel: flutterAndroidNdkVersionLowestSupported,
    ),
    (
      architecture: Architecture.arm64,
      apiLevel: flutterAndroidNdkVersionLowestSupported,
    ),
  ];

  for (final (:architecture, :apiLevel) in configurations) {
    group('Android API$apiLevel ($architecture):', () {
      runTreeshakeTests(targetOS, architecture, androidTargetNdkApi: apiLevel);
    });
  }
}
