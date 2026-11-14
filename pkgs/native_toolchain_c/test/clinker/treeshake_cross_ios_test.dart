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
import 'treeshake_helper.dart';

const targetOS = OS.iOS;

/// This comment is generated. To regenerate, run:
/// `REGENERATE_TEST_CONFIGS=true dart test`
///
/// | #   | Architecture | IOSSdk          | Apple Version                        |
/// |-----|--------------|-----------------|--------------------------------------|
/// | 1   | arm64        | iphoneos        | AppleVersion(26, minor: 7, patch: 1) |
/// | 2   | arm64        | iphonesimulator | AppleVersion(27, minor: 0, patch: 0) |
/// | 3   | arm64e       | iphoneos        | AppleVersion(27, minor: 0, patch: 0) |
/// | 4   | arm64e       | iphonesimulator | AppleVersion(26, minor: 7, patch: 1) |
/// | 5   | x64          | iphonesimulator | AppleVersion(26, minor: 7, patch: 1) |
final configurations =
    TestCaseSelector(
      dimensions: {
        Architecture: [
          Architecture.arm64,
          Architecture.arm64e,
          Architecture.x64,
        ],
        IOSSdk: [IOSSdk.iPhoneOS, IOSSdk.iPhoneSimulator],
        AppleVersion: [
          IOSVersion.flutterHighestBestEffort,
          IOSVersion.flutterHighestSupported,
        ],
      },
      interactionGroups: [
        {Architecture, IOSSdk},
        {IOSSdk, AppleVersion},
      ],
      isValid: (config) {
        if (config.get<IOSSdk>() == IOSSdk.iPhoneOS &&
            config.get<Architecture>() == Architecture.x64) {
          return false;
        }
        return true;
      },
    ).selectAndValidate(
      tableUri: packageUri.resolve(
        'test/clinker/treeshake_cross_ios_test.dart',
      ),
    );

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  for (final config in configurations) {
    final architecture = config.get<Architecture>();
    final iOSTargetSdk = config.get<IOSSdk>();
    final iOSVersion = config.get<AppleVersion>();

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
