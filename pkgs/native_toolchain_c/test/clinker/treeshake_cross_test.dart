// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'treeshake_helper.dart';

void main() {
  final architectures = supportedArchitecturesFor(OS.current)
    ..remove(Architecture.current); // See treeshake_test.dart for current arch.
  for (final architecture in architectures) {
    group('${OS.current} ($architecture):', () {
      runTreeshakeTests(
        OS.current,
        architecture,
        macOSTargetVersion: OS.current == OS.macOS ? defaultMacOSVersion : null,
      );
    });
  }

  for (final architecture in supportedArchitecturesFor(OS.android)) {
    group('android ($architecture):', () {
      runTreeshakeTests(
        OS.android,
        architecture,
        androidTargetNdkApi: architecture == Architecture.riscv64
            ? AndroidApiLevel.flutterHighestSupported.value
            : AndroidApiLevel.flutterLowestSupported.value,
      );
    });
  }

  for (final architecture in [Architecture.arm64, Architecture.x64]) {
    if (OS.current != OS.macOS) {
      group('macOS ($architecture):', () {
        runTreeshakeTests(
          OS.macOS,
          architecture,
          macOSTargetVersion: defaultMacOSVersion,
        );
      });
    }
    if (OS.current != OS.windows) {
      group('windows ($architecture):', () {
        runTreeshakeTests(OS.windows, architecture);
      });
    }
  }

  for (final (sdk, architecture) in [
    (IOSSdk.iPhoneOS, Architecture.arm64),
    (IOSSdk.iPhoneSimulator, Architecture.arm64),
    (IOSSdk.iPhoneSimulator, Architecture.x64),
  ]) {
    group('iOS $sdk ($architecture):', () {
      runTreeshakeTests(
        OS.iOS,
        architecture,
        iOSTargetVersion: IOSVersion.flutterHighestSupported.value,
        iOSTargetSdk: sdk,
      );
    });
  }
}
