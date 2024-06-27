// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

// From https://docs.flutter.dev/reference/supported-platforms.
const flutterAndroidNdkVersionLowestBestEffort = 19;
const flutterAndroidNdkVersionLowestSupported = 21;
const flutterAndroidNdkVersionHighestSupported = 34;
const flutteriOSLowestBestEffort = 12;
const flutteriOSLowestSupported = 17;
const flutteriOSHighestSupported = 17;
const flutterMacOSLowestBestEffort = 12;
const flutterMacOSLowestSupported = 13;
const flutterMacOSHighestSupported = 13;

// Simulate needing some version of the API.
const minNdkApiVersionForThisPackage = 28;
const minIosVersionForThisPackage = 16;
const minMacOSVersionForThisPackage = 13;

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    if (config.targetOS == OS.android) {
      if (config.targetAndroidNdkApi! < minNdkApiVersionForThisPackage) {
        throw UnsupportedError(
          'The native assets for this package require at '
          'least Android NDK API level $minNdkApiVersionForThisPackage.',
        );
      }
    } else if (config.targetOS == OS.iOS) {
      final iosVersion = config.targetIOSVersion;
      // iosVersion is nullable to deal with version skew.
      if (iosVersion != null && iosVersion < minIosVersionForThisPackage) {
        throw UnsupportedError(
          'The native assets for this package require at '
          'least iOS version $minIosVersionForThisPackage.',
        );
      }
    } else if (config.targetOS == OS.macOS) {
      final macosVersion = config.targetMacOSVersion;
      // macosVersion is nullable to deal with version skew.
      if (macosVersion != null &&
          macosVersion < minMacOSVersionForThisPackage) {
        throw UnsupportedError(
          'The native assets for this package require at '
          'least MacOS version $minMacOSVersionForThisPackage.',
        );
      }
    }
    // Else just succeed.
  });
}
