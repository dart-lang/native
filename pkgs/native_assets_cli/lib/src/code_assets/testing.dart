// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:meta/meta.dart' show isTest;
import 'package:test/test.dart';

import '../../test.dart';

@isTest
Future<void> testCodeBuildHook({
  required String description,
  // ignore: inference_failure_on_function_return_type
  required Function(List<String> arguments) mainMethod,
  required FutureOr<void> Function(BuildConfig, BuildOutput) check,
  BuildMode? buildMode,
  Architecture? targetArchitecture,
  OS? targetOS,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  CCompilerConfig? cCompiler,
  LinkModePreference? linkModePreference,
  required List<String> supportedAssetTypes,
  bool? linkingEnabled,
}) async {
  await testBuildHook(
    description: description,
    mainMethod: mainMethod,
    extraConfigSetup: (config) {
      config.setupCodeConfig(
        linkModePreference: linkModePreference ?? LinkModePreference.dynamic,
        cCompilerConfig: cCompiler,
        targetArchitecture: targetArchitecture ?? Architecture.current,
        targetIOSSdk: targetIOSSdk,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        targetAndroidNdkApi: targetAndroidNdkApi,
      );
    },
    check: (config, output) async {
      expect(await validateCodeAssetBuildOutput(config, output), isEmpty);
      await check(config, output);
    },
    buildMode: buildMode,
    targetOS: targetOS,
    supportedAssetTypes: supportedAssetTypes,
    linkingEnabled: linkingEnabled,
  );
}
