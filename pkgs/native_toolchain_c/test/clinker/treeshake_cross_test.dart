// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'treeshake_helper.dart';

void main() {
  final architectures = supportedArchitecturesFor(OS.current)
    ..remove(Architecture.current); // See treeshake_test.dart for current arch.
  for (final architecture in architectures) {
    group('${OS.current} ($architecture):', () {
      runTreeshakeTests(
        OS.current,
        architecture,
        macOSTargetVersion: OS.current == OS.macOS ? defaultMacOSVersion : null,
      );
    });
  }
}
