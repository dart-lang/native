// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import '../../code_assets_builder.dart';
import '../../test.dart';
import '../validation.dart';

/// Validate a code build hook; this will throw an exception on validation
/// errors.
///
/// This is intended to be used from tests, e.g.:
///
/// ```
/// test('test my build hook', () async {
///   await testCodeBuildHook(
///     ...
///   );
/// });
/// ```
Future<void> testCodeBuildHook({
  // ignore: inference_failure_on_function_return_type
  required Function(List<String> arguments) mainMethod,
  required FutureOr<void> Function(BuildConfig, BuildOutput) check,
  Architecture? targetArchitecture,
  OS? targetOS,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  CCompilerConfig? cCompiler,
  LinkModePreference? linkModePreference,
  required List<String> buildAssetTypes,
  bool? linkingEnabled,
}) async {
  await testBuildHook(
    mainMethod: mainMethod,
    extraConfigSetup: (config) {
      config.setupCodeConfig(
        linkModePreference: linkModePreference ?? LinkModePreference.dynamic,
        cCompilerConfig: cCompiler,
        targetArchitecture: targetArchitecture ?? Architecture.current,
        targetOS: targetOS ?? OS.current,
        targetIOSSdk: targetIOSSdk,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        targetAndroidNdkApi: targetAndroidNdkApi,
      );
    },
    check: (config, output) async {
      final validationErrors =
          await validateCodeAssetBuildOutput(config, output);
      if (validationErrors.isNotEmpty) {
        throw ValidationFailure(
            'encountered build output validation issues: $validationErrors');
      }

      await check(config, output);
    },
    buildAssetTypes: buildAssetTypes,
    linkingEnabled: linkingEnabled,
  );
}
