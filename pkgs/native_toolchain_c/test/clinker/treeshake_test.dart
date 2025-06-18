// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'treeshake_helper.dart';

void main() {
  runTreeshakeTests(
    OS.current,
    Architecture.current,
    macOSTargetVersion: OS.current == OS.macOS ? defaultMacOSVersion : null,
  );
}
