// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:hooks/hooks.dart';

import 'architecture.dart';
import 'c_compiler_config.dart';
import 'code_asset.dart';
import 'config.dart';
import 'extension.dart';
import 'ios_sdk.dart';
import 'link_mode_preference.dart';
import 'os.dart';

/// Tests the main function of a `hook/build.dart` with [CodeAsset]s.
///
/// This method will throw an exception on validation errors.
///
/// This is intended to be used from tests, e.g.:
///
/// <!-- file://./../../../example/api/test_snippet.dart -->
/// ```dart
/// import 'package:code_assets/code_assets.dart';
/// import 'package:test/test.dart';
///
/// void main() {
///   test('test my build hook', () async {
///     await testCodeBuildHook(
///       mainMethod: (args) {},
///       check: (input, output) {},
///     );
///   });
/// }
/// ```
///
/// The hook is run in isolation. No user-defines are read from the pubspec,
/// they must be provided via [userDefines]. No other hooks are run, if the hook
/// requires assets from other build hooks, the must be provided in [assets].
Future<void> testCodeBuildHook({
  required FutureOr<void> Function(List<String> arguments) mainMethod,
  required FutureOr<void> Function(BuildInput, BuildOutput) check,
  bool? linkingEnabled,
  Architecture? targetArchitecture,
  OS? targetOS,
  IOSSdk? targetIOSSdk = .iPhoneOS,
  int? targetIOSVersion = 17,
  int? targetMacOSVersion = 13,
  int? targetAndroidNdkApi = 30,
  CCompilerConfig? cCompiler,
  LinkModePreference? linkModePreference = .dynamic,
  // TODO(https://github.com/dart-lang/native/issues/2241): Cleanup how the
  // following parameters are passed in.
  PackageUserDefines? userDefines,
  Map<String, List<EncodedAsset>>? assets,
}) async {
  targetOS ??= .current;
  final extension = CodeAssetExtension(
    linkModePreference: linkModePreference!,
    cCompiler: cCompiler,
    targetArchitecture: targetArchitecture ?? .current,
    targetOS: targetOS,
    iOS: targetOS == .iOS
        ? IOSCodeConfig(
            targetSdk: targetIOSSdk!,
            targetVersion: targetIOSVersion!,
          )
        : null,
    macOS: targetOS == .macOS
        ? MacOSCodeConfig(targetVersion: targetMacOSVersion!)
        : null,
    android: targetOS == .android
        ? AndroidCodeConfig(targetNdkApi: targetAndroidNdkApi!)
        : null,
  );
  await testBuildHook(
    mainMethod: mainMethod,
    check: check,
    linkingEnabled: linkingEnabled,
    userDefines: userDefines,
    assets: assets,
    extensions: [extension],
  );
}
