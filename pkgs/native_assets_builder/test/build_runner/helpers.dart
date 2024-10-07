// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_builder/native_assets_builder.dart';
import 'package:native_assets_builder/src/model/hook_result.dart';
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

Future<BuildResult> build(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  required BuildValidator buildValidator,
  required ApplicationAssetValidator applicationAssetValidator,
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  String? runPackageName,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  Target? target,
  bool linkingEnabled = false,
  required Iterable<String> supportedAssetTypes,
}) async =>
    await runWithLog(capturedLogs, () async {
      final result = await NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
      ).build(
        buildMode: BuildMode.release,
        linkModePreference: linkModePreference,
        target: target ?? Target.current,
        workingDirectory: packageUri,
        cCompilerConfig: cCompilerConfig,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        runPackageName: runPackageName,
        targetIOSSdk: targetIOSSdk,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        targetAndroidNdkApi: targetAndroidNdkApi,
        linkingEnabled: linkingEnabled,
        supportedAssetTypes: supportedAssetTypes,
        buildValidator: buildValidator,
        applicationAssetValidator: applicationAssetValidator,
      );

      if (result.success) {
        expect(await result.encodedAssets.allExist(), true);
        for (final encodedAssetsForLinking
            in result.encodedAssetsForLinking.values) {
          expect(await encodedAssetsForLinking.allExist(), true);
        }
      }

      return result;
    });

Future<LinkResult> link(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  required LinkValidator linkValidator,
  required ApplicationAssetValidator applicationAssetValidator,
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  required BuildResult buildResult,
  Uri? resourceIdentifiers,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  Target? target,
  required Iterable<String> supportedAssetTypes,
}) async =>
    await runWithLog(capturedLogs, () async {
      final result = await NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
      ).link(
        linkModePreference: linkModePreference,
        buildMode: BuildMode.release,
        target: target ?? Target.current,
        workingDirectory: packageUri,
        cCompilerConfig: cCompilerConfig,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        buildResult: buildResult,
        resourceIdentifiers: resourceIdentifiers,
        targetIOSSdk: targetIOSSdk,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        targetAndroidNdkApi: targetAndroidNdkApi,
        supportedAssetTypes: supportedAssetTypes,
        linkValidator: linkValidator,
        applicationAssetValidator: applicationAssetValidator,
      );

      if (result.success) {
        expect(await result.encodedAssets.allExist(), true);
      }

      return result;
    });

Future<(BuildResult, LinkResult)> buildAndLink(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  required LinkValidator linkValidator,
  required BuildValidator buildValidator,
  required ApplicationAssetValidator applicationAssetValidator,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  String? runPackageName,
  IOSSdk? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  Target? target,
  Uri? resourceIdentifiers,
  required Iterable<String> supportedAssetTypes,
}) async =>
    await runWithLog(capturedLogs, () async {
      final buildRunner = NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
      );
      final buildResult = await buildRunner.build(
        buildMode: BuildMode.release,
        linkModePreference: linkModePreference,
        target: target ?? Target.current,
        workingDirectory: packageUri,
        cCompilerConfig: cCompilerConfig,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        runPackageName: runPackageName,
        targetIOSSdk: targetIOSSdk,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        targetAndroidNdkApi: targetAndroidNdkApi,
        linkingEnabled: true,
        supportedAssetTypes: supportedAssetTypes,
        buildValidator: buildValidator,
        applicationAssetValidator: applicationAssetValidator,
      );

      if (!buildResult.success) {
        return (buildResult, HookResult());
      }

      expect(await buildResult.encodedAssets.allExist(), true);
      for (final encodedAssetsForLinking
          in buildResult.encodedAssetsForLinking.values) {
        expect(await encodedAssetsForLinking.allExist(), true);
      }

      final linkResult = await buildRunner.link(
        linkModePreference: linkModePreference,
        buildMode: BuildMode.release,
        target: target ?? Target.current,
        workingDirectory: packageUri,
        cCompilerConfig: cCompilerConfig,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        buildResult: buildResult,
        resourceIdentifiers: resourceIdentifiers,
        targetIOSSdk: targetIOSSdk,
        targetIOSVersion: targetIOSVersion,
        targetMacOSVersion: targetMacOSVersion,
        targetAndroidNdkApi: targetAndroidNdkApi,
        supportedAssetTypes: supportedAssetTypes,
        linkValidator: linkValidator,
        applicationAssetValidator: applicationAssetValidator,
      );

      if (linkResult.success) {
        expect(await buildResult.encodedAssets.allExist(), true);
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

Future<BuildDryRunResult> buildDryRun(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  required BuildValidator buildValidator,
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  required bool linkingEnabled,
  required Iterable<String> supportedAssetTypes,
}) async =>
    runWithLog(capturedLogs, () async {
      final result = await NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
      ).buildDryRun(
        linkModePreference: linkModePreference,
        targetOS: Target.current.os,
        workingDirectory: packageUri,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        linkingEnabled: linkingEnabled,
        supportedAssetTypes: supportedAssetTypes,
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
