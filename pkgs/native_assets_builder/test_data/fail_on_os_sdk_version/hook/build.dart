// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/code_assets.dart';

// Simulate needing some version of the API.
//
// Something reasonable w.r.t.:
// https://docs.flutter.dev/reference/supported-platforms
const minNdkApiVersionForThisPackage = 28;
const minIosVersionForThisPackage = 16;
const minMacOSVersionForThisPackage = 13;

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    if (config.code.targetOS == OS.android) {
      if (config.code.android.targetNdkApi < minNdkApiVersionForThisPackage) {
        throw UnsupportedError(
          'The native assets for this package require at '
          'least Android NDK API level $minNdkApiVersionForThisPackage.',
        );
      }
    } else if (config.code.targetOS == OS.iOS) {
      final iosVersion = config.code.iOS.targetVersion;
      // iosVersion is nullable to deal with version skew.
      if (iosVersion < minIosVersionForThisPackage) {
        throw UnsupportedError(
          'The native assets for this package require at '
          'least iOS version $minIosVersionForThisPackage.',
        );
      }
    } else if (config.code.targetOS == OS.macOS) {
      final macosVersion = config.code.macOS.targetVersion;
      // macosVersion is nullable to deal with version skew.
      if (macosVersion < minMacOSVersionForThisPackage) {
        throw UnsupportedError(
          'The native assets for this package require at '
          'least MacOS version $minMacOSVersionForThisPackage.',
        );
      }
    }
    // Else just succeed.
  });
}
