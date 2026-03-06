// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('mac-os')
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import '../utils/test_configuration_generator.dart';
import 'objects_helper.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  const targetOS = OS.iOS;

  final configurations =
      TestConfigurationGenerator(
        dimensions: {
          IOSSdk: [IOSSdk.iPhoneOS, IOSSdk.iPhoneSimulator],
          IOSVersion: [
            IOSVersion.flutterHighestBestEffort,
            IOSVersion.flutterHighestSupported,
          ],
        },
        interactionGroups: [],
      ).generateAndValidate(
        tableUri: packageUri.resolve('test/clinker/objects_cross_ios_test.md'),
      );

  for (final config in configurations) {
    final iOSTargetSdk = config.get<IOSSdk>();
    final iOSVersion = config.get<IOSVersion>().value;

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
