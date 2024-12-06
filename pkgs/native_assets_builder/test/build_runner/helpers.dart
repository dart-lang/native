// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_builder/native_assets_builder.dart';
import 'package:test/test.dart';

import '../helpers.dart';

Future<void> runPubGet({
  required Uri workingDirectory,
  required Logger logger,
}) async {
  final result = await runProcess(
    executable: Uri.file(Platform.resolvedExecutable),
    arguments: [
      'pub',
      '--suppress-analytics', // Prevent extra log entries.
      'get',
    ],
    workingDirectory: workingDirectory,
    logger: logger,
  );
  expect(result.exitCode, 0);
}

Future<BuildResult?> build(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  required BuildConfigValidator configValidator,
  required BuildValidator buildValidator,
  required ApplicationAssetValidator applicationAssetValidator,
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  String? runPackageName,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  Target? target,
  bool linkingEnabled = false,
  required List<String> buildAssetTypes,
}) async {
  final targetOS = target?.os ?? OS.current;
  return await runWithLog(capturedLogs, () async {
    final result = await NativeAssetsBuildRunner(
      logger: logger,
      dartExecutable: dartExecutable,
    ).build(
      configCreator: () {
        final configBuilder = BuildConfigBuilder();
        if (buildAssetTypes.contains(CodeAsset.type)) {
          configBuilder.setupCodeConfig(
            targetArchitecture: target?.architecture ?? Architecture.current,
            linkModePreference: linkModePreference,
            cCompilerConfig: cCompilerConfig ?? dartCICompilerConfig,
            targetIOSSdk: targetIOSSdk,
            targetIOSVersion: targetIOSVersion,
            targetMacOSVersion: targetMacOSVersion ??
                (targetOS == OS.macOS ? defaultMacOSVersion : null),
            targetAndroidNdkApi: targetAndroidNdkApi,
          );
        }
        return configBuilder;
      },
      configValidator: configValidator,
      buildMode: BuildMode.release,
      targetOS: targetOS,
      workingDirectory: packageUri,
      packageLayout: packageLayout,
      runPackageName: runPackageName,
      linkingEnabled: linkingEnabled,
      buildAssetTypes: buildAssetTypes,
      buildValidator: buildValidator,
      applicationAssetValidator: applicationAssetValidator,
    );

    if (result != null) {
      expect(await result.encodedAssets.allExist(), true);
      for (final encodedAssetsForLinking
          in result.encodedAssetsForLinking.values) {
        expect(await encodedAssetsForLinking.allExist(), true);
      }
    }

    return result;
  });
}

Future<LinkResult?> link(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  required LinkConfigValidator configValidator,
  required LinkValidator linkValidator,
  required ApplicationAssetValidator applicationAssetValidator,
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  required BuildResult buildResult,
  Uri? resourceIdentifiers,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  Target? target,
  required List<String> buildAssetTypes,
}) async {
  final targetOS = target?.os ?? OS.current;
  return await runWithLog(capturedLogs, () async {
    final result = await NativeAssetsBuildRunner(
      logger: logger,
      dartExecutable: dartExecutable,
    ).link(
      configCreator: () {
        final configBuilder = LinkConfigBuilder();
        if (buildAssetTypes.contains(CodeAsset.type)) {
          configBuilder.setupCodeConfig(
            targetArchitecture: target?.architecture ?? Architecture.current,
            linkModePreference: linkModePreference,
            cCompilerConfig: cCompilerConfig ?? dartCICompilerConfig,
            targetIOSSdk: targetIOSSdk,
            targetIOSVersion: targetIOSVersion,
            targetMacOSVersion: targetMacOSVersion ??
                (targetOS == OS.macOS ? defaultMacOSVersion : null),
            targetAndroidNdkApi: targetAndroidNdkApi,
          );
        }
        return configBuilder;
      },
      configValidator: configValidator,
      buildMode: BuildMode.release,
      targetOS: target?.os ?? OS.current,
      workingDirectory: packageUri,
      packageLayout: packageLayout,
      buildResult: buildResult,
      resourceIdentifiers: resourceIdentifiers,
      buildAssetTypes: buildAssetTypes,
      linkValidator: linkValidator,
      applicationAssetValidator: applicationAssetValidator,
    );

    if (result != null) {
      expect(await result.encodedAssets.allExist(), true);
    }

    return result;
  });
}

Future<(BuildResult?, LinkResult?)> buildAndLink(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  required BuildConfigValidator buildConfigValidator,
  required LinkConfigValidator linkConfigValidator,
  required BuildValidator buildValidator,
  required LinkValidator linkValidator,
  required ApplicationAssetValidator applicationAssetValidator,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  String? runPackageName,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  Target? target,
  Uri? resourceIdentifiers,
  required List<String> buildAssetTypes,
}) async =>
    await runWithLog(capturedLogs, () async {
      final buildRunner = NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
      );
      final buildResult = await buildRunner.build(
        configCreator: () => BuildConfigBuilder()
          ..setupCodeConfig(
            targetArchitecture: target?.architecture ?? Architecture.current,
            linkModePreference: linkModePreference,
            cCompilerConfig: cCompilerConfig ?? dartCICompilerConfig,
            targetIOSSdk: targetIOSSdk,
            targetIOSVersion: targetIOSVersion,
            targetMacOSVersion: targetMacOSVersion,
            targetAndroidNdkApi: targetAndroidNdkApi,
          ),
        configValidator: buildConfigValidator,
        buildMode: BuildMode.release,
        targetOS: target?.os ?? OS.current,
        workingDirectory: packageUri,
        packageLayout: packageLayout,
        runPackageName: runPackageName,
        linkingEnabled: true,
        buildAssetTypes: buildAssetTypes,
        buildValidator: buildValidator,
        applicationAssetValidator: applicationAssetValidator,
      );

      if (buildResult == null) {
        return (null, null);
      }

      expect(await buildResult.encodedAssets.allExist(), true);
      for (final encodedAssetsForLinking
          in buildResult.encodedAssetsForLinking.values) {
        expect(await encodedAssetsForLinking.allExist(), true);
      }

      final linkResult = await buildRunner.link(
        configCreator: () => LinkConfigBuilder()
          ..setupCodeConfig(
            targetArchitecture: target?.architecture ?? Architecture.current,
            linkModePreference: linkModePreference,
            cCompilerConfig: cCompilerConfig,
            targetIOSSdk: targetIOSSdk,
            targetIOSVersion: targetIOSVersion,
            targetMacOSVersion: targetMacOSVersion,
            targetAndroidNdkApi: targetAndroidNdkApi,
          ),
        configValidator: linkConfigValidator,
        buildMode: BuildMode.release,
        targetOS: target?.os ?? OS.current,
        workingDirectory: packageUri,
        packageLayout: packageLayout,
        buildResult: buildResult,
        resourceIdentifiers: resourceIdentifiers,
        buildAssetTypes: buildAssetTypes,
        linkValidator: linkValidator,
        applicationAssetValidator: applicationAssetValidator,
      );

      if (linkResult != null) {
        expect(await linkResult.encodedAssets.allExist(), true);
      }

      return (buildResult, linkResult);
    });

Future<T> runWithLog<T>(
  List<String>? capturedLogs,
  Future<T> Function() f,
) async {
  StreamSubscription<LogRecord>? subscription;
  if (capturedLogs != null) {
    subscription =
        logger.onRecord.listen((event) => capturedLogs.add(event.message));
  }

  final result = await f();

  if (subscription != null) {
    await subscription.cancel();
  }

  return result;
}

Future<BuildDryRunResult?> buildDryRun(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  required BuildValidator buildValidator,
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  required bool linkingEnabled,
  required List<String> buildAssetTypes,
}) async =>
    runWithLog(capturedLogs, () async {
      final result = await NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
      ).buildDryRun(
        configCreator: () => BuildConfigBuilder()
          ..setupCodeConfig(
            targetArchitecture: null,
            linkModePreference: linkModePreference,
          ),
        targetOS: Target.current.os,
        workingDirectory: packageUri,
        packageLayout: packageLayout,
        linkingEnabled: linkingEnabled,
        buildAssetTypes: buildAssetTypes,
        buildValidator: buildValidator,
      );
      return result;
    });

Future<void> expectSymbols({
  required CodeAsset asset,
  required List<String> symbols,
}) async {
  if (Platform.isLinux) {
    final assetUri = asset.file!;
    final nmResult = await runProcess(
      executable: Uri(path: 'nm'),
      arguments: [
        '-D',
        assetUri.toFilePath(),
      ],
      logger: logger,
    );

    expect(
      nmResult.stdout,
      stringContainsInOrder(symbols),
    );
  }
}

final CCompilerConfig? dartCICompilerConfig = (() {
  // Specifically for running our tests on Dart CI with the test runner, we
  // recognize specific variables to setup the C Compiler configuration.
  final env = Platform.environment;
  final cc = env['DART_HOOK_TESTING_C_COMPILER__CC'];
  final ar = env['DART_HOOK_TESTING_C_COMPILER__AR'];
  final ld = env['DART_HOOK_TESTING_C_COMPILER__LD'];
  final envScript = env['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT'];
  final envScriptArgs =
      env['DART_HOOK_TESTING_C_COMPILER__ENV_SCRIPT_ARGUMENTS']
          ?.split(' ')
          .map((arg) => arg.trim())
          .where((arg) => arg.isNotEmpty)
          .toList();
  final hasEnvScriptArgs = envScriptArgs != null && envScriptArgs.isNotEmpty;

  if (cc != null ||
      ar != null ||
      ld != null ||
      envScript != null ||
      hasEnvScriptArgs) {
    return CCompilerConfig(
      archiver: ar != null ? Uri.file(ar) : null,
      compiler: cc != null ? Uri.file(cc) : null,
      envScript: envScript != null ? Uri.file(envScript) : null,
      envScriptArgs: hasEnvScriptArgs ? envScriptArgs : null,
      linker: ld != null ? Uri.file(ld) : null,
    );
  }
  return null;
})();

int defaultMacOSVersion = 13;
