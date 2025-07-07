// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('windows')
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'windows_module_definition_helper.dart';

void main() {
  if (!Platform.isWindows) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  final architectures = supportedArchitecturesFor(OS.current)
    // See windows_module_definition_test.dart for current arch.
    ..remove(Architecture.current);
  runWindowsModuleDefinitionTests(architectures);
}
