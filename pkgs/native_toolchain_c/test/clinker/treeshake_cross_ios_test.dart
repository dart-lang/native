// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'treeshake_helper.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targetOS = OS.iOS;

  for (final iOSVersion in [
    flutteriOSHighestBestEffort,
    flutteriOSHighestSupported,
  ]) {
    for (final iOSTargetSdk in IOSSdk.values) {
      for (final architecture in iOSSupportedArchitecturesFor(iOSTargetSdk)) {
        group('$iOSTargetSdk $iOSVersion ($architecture):', () {
          runTreeshakeTests(
            targetOS,
            architecture,
            iOSTargetVersion: iOSVersion,
            iOSTargetSdk: iOSTargetSdk,
          );
        });
      }
    }
  }
}
