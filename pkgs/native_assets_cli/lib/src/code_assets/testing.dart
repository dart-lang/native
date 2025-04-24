// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import '../config.dart';
import '../test.dart';
import '../validation.dart';
import 'architecture.dart';
import 'c_compiler_config.dart';
import 'config.dart';
import 'extension.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'os.dart';

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
  required FutureOr<void> Function(BuildInput, BuildOutput) check,
  Architecture? targetArchitecture,
  OS? targetOS,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  CCompilerConfig? cCompiler,
  LinkModePreference? linkModePreference,
  bool? linkingEnabled,
}) async {
  final extension = CodeAssetExtension(
    linkModePreference: linkModePreference ?? LinkModePreference.dynamic,
    cCompiler: cCompiler,
    targetArchitecture: targetArchitecture ?? Architecture.current,
    targetOS: targetOS ?? OS.current,
    iOS: targetOS == OS.iOS
        ? IOSCodeConfig(
            targetSdk: targetIOSSdk!,
            targetVersion: targetIOSVersion!,
          )
        : null,
    macOS: targetOS == OS.macOS
        ? MacOSCodeConfig(targetVersion: targetMacOSVersion!)
        : null,
    android: targetOS == OS.android
        ? AndroidCodeConfig(targetNdkApi: targetAndroidNdkApi!)
        : null,
  );
  await testBuildHook(
    mainMethod: mainMethod,
    extraInputSetup: (input) {
      input.addExtension(extension);
    },
    check: (input, output) async {
      final validationErrors = await extension.validateBuildOutput(
        input,
        output,
      );
      if (validationErrors.isNotEmpty) {
        throw ValidationFailure(
          'encountered build output validation issues: $validationErrors',
        );
      }

      await check(input, output);
    },
    linkingEnabled: linkingEnabled,
  );
}
