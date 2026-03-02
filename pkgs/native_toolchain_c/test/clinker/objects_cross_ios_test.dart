// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'objects_helper.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targetOS = OS.iOS;

  // These configurations are a selection of combinations of architectures
  // and iOS versions.
  // We don't test the full cartesian product to keep the CI time manageable.
  // When adding a new configuration, consider if it tests a new combination
  // that is not yet covered by the existing tests.
  final configurations = [
    (iOSTargetSdk: IOSSdk.iPhoneOS, iOSVersion: flutteriOSHighestBestEffort),
    (
      iOSTargetSdk: IOSSdk.iPhoneSimulator,
      iOSVersion: flutteriOSHighestSupported,
    ),
    (iOSTargetSdk: IOSSdk.iPhoneOS, iOSVersion: flutteriOSHighestSupported),
  ];

  for (final (:iOSTargetSdk, :iOSVersion) in configurations) {
    group('$iOSTargetSdk $iOSVersion:', () {
      runObjectsTests(
        targetOS,
        iOSSupportedArchitecturesFor(iOSTargetSdk),
        iOSTargetVersion: iOSVersion,
        iOSTargetSdk: iOSTargetSdk,
      );
    });
  }
}
