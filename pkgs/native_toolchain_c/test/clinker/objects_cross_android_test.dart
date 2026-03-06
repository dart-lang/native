// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import '../utils/test_configuration_generator.dart';
import 'objects_helper.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));

void main() {
  const targetOS = OS.android;

  final configurations =
      TestConfigurationGenerator(
        dimensions: {
          Architecture: [
            Architecture.arm,
            Architecture.arm64,
            Architecture.ia32,
            Architecture.x64,
            Architecture.riscv64,
          ],
          AndroidApiLevel: [
            AndroidApiLevel.flutterLowestSupported,
            AndroidApiLevel.flutterHighestSupported,
          ],
        },
        interactionGroups: [],
      ).generateAndValidate(
        tableUri: packageUri.resolve(
          'test/clinker/objects_cross_android_test.md',
        ),
      );

  for (final config in configurations) {
    final architecture = config.get<Architecture>();
    final apiLevel = config.get<AndroidApiLevel>().value;

    group('Android API$apiLevel ($architecture):', () {
      runObjectsTests(
        targetOS,
        [architecture],
        androidTargetNdkApi: apiLevel,
        timeout: longTimeout,
      );
    });
  }
}
