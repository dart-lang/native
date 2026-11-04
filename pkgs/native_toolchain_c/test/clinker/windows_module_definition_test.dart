// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';

import '../helpers.dart';
import 'windows_module_definition_helper.dart';

void main() {
  if (!Platform.isWindows && !hasBundledSdkLinker) {
    // Avoid needing status files on Dart SDK CI when bundled SDK stubs are
    // unavailable.
    return;
  }
  runWindowsModuleDefinitionTests([Architecture.current]);
}
