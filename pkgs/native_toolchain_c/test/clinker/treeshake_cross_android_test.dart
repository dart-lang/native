// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'treeshake_helper.dart';

void main() {
  const targetOS = OS.android;

  for (final apiLevel in [
    flutterAndroidNdkVersionLowestSupported,
    flutterAndroidNdkVersionHighestSupported,
  ]) {
    for (final architecture in supportedArchitecturesFor(targetOS)) {
      group('Android API$apiLevel ($architecture):', () {
        runTreeshakeTests(
          targetOS,
          architecture,
          androidTargetNdkApi: apiLevel,
        );
      });
    }
  }
}
