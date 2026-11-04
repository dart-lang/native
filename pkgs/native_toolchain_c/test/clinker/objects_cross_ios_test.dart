// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: lines_longer_than_80_chars

@TestOn('mac-os')
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';
import 'package:test_case_selector/test_case_selector.dart';

import '../helpers.dart';
import 'objects_helper.dart';

const targetOS = OS.iOS;

/// This comment is generated. To regenerate, run:
/// `REGENERATE_TEST_CONFIGS=true dart test`
///
/// | #   | IOSSdk          | Apple Version                        |
/// |-----|-----------------|--------------------------------------|
/// | 1   | iphoneos        | AppleVersion(16, minor: 4, patch: 0) |
/// | 2   | iphonesimulator | AppleVersion(17, minor: 2, patch: 1) |
final configurations =
    TestCaseSelector(
      dimensions: {
        IOSSdk: [IOSSdk.iPhoneOS, IOSSdk.iPhoneSimulator],
        AppleVersion: [
          AppleVersion(16, minor: 4),
          AppleVersion(17, minor: 2, patch: 1),
        ],
      },
      interactionGroups: [],
    ).selectAndValidate(
      tableUri: packageUri.resolve('test/clinker/objects_cross_ios_test.dart'),
    );

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  for (final config in configurations) {
    final iOSTargetSdk = config.get<IOSSdk>();
    final iOSVersion = config.get<AppleVersion>();

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
