// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

/// Builds the C code for the native_add example.
Future<void> runBuild(BuildInput input, BuildOutputBuilder output) async {
  final name = createTargetName(
    input.config.code.targetOS.name,
    input.config.code.targetArchitecture.name,
    input.config.code.targetOS == OS.iOS
        ? input.config.code.iOS.targetSdk.type
        : null,
  );
  final cbuilder = CBuilder.library(
    name: name,
    assetName: 'native_add.dart',
    sources: ['src/native_add.c'],
  );
  await cbuilder.run(input: input, output: output);
}

/// Creates a target name based on the OS, architecture, and iOS SDK.
///
/// For example, `native_add_ios_arm64_iphonesimulator` or
/// `native_add_windows_x64`.
String createTargetName(String osString, String architecture, String? iOSSdk) {
  var targetName = 'native_add_${osString}_$architecture';
  if (iOSSdk != null) {
    targetName += '_$iOSSdk';
  }
  return targetName;
}
