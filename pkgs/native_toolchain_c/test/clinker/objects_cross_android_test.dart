// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';
import 'package:test_case_selector/test_case_selector.dart';

import '../helpers.dart';
import 'objects_helper.dart';

const Timeout longTimeout = Timeout(Duration(minutes: 5));
const targetOS = OS.android;

/// This comment is generated. To regenerate, run:
/// `REGENERATE_TEST_CONFIGS=true dart test`
///
/// | #   | Architecture | Android Api Level |
/// |-----|--------------|-------------------|
/// | 1   | arm          | 34                |
/// | 2   | arm64        | 34                |
/// | 3   | ia32         | 34                |
/// | 4   | riscv64      | 21                |
/// | 5   | x64          | 34                |
final configurations =
    TestCaseSelector(
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
    ).selectAndValidate(
      tableUri: packageUri.resolve(
        'test/clinker/objects_cross_android_test.dart',
      ),
    );

void main() {
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
