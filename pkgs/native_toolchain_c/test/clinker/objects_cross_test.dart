// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';

import '../helpers.dart';
import 'objects_helper.dart';

void main() {
  final architectures = supportedArchitecturesFor(OS.current)
    ..remove(Architecture.current); // See objects_test.dart for current arch.

  runObjectsTests(
    OS.current,
    architectures,
    macOSTargetVersion: OS.current == OS.macOS ? defaultMacOSVersion : null,
  );
}
