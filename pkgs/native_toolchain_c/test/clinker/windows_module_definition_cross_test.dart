// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';

import '../helpers.dart';
import 'windows_module_definition_helper.dart';

void main() {
  final architectures = supportedArchitecturesFor(OS.windows)
    // See windows_module_definition_test.dart for current arch.
    ..remove(Architecture.current);
  if (!Platform.isWindows) {
    architectures.remove(Architecture.ia32);
  }
  runWindowsModuleDefinitionTests(architectures);
}
