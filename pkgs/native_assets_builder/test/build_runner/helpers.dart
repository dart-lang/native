// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:file_testing/file_testing.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_builder/native_assets_builder.dart';
import 'package:native_assets_builder/src/model/hook_result.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
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
  LinkModePreferenceImpl linkModePreference = LinkModePreferenceImpl.dynamic,
  CCompilerConfigImpl? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  String? runPackageName,
  IOSSdkImpl? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  Target? target,
  bool linkingEnabled = false,
}) async =>
    await runWithLog(capturedLogs, () async {
      final result = await NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        progressLogger: logger.info,
      ).build(
        buildMode: BuildModeImpl.release,
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
      );

      if (result.success) {
        await expectAssetsExist(result.assets);
        for (final assetsForLinking in result.assetsForLinking.values) {
          await expectAssetsExist(assetsForLinking);
        }
      }

      return result;
    });

Future<LinkResult> link(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  LinkModePreferenceImpl linkModePreference = LinkModePreferenceImpl.dynamic,
  CCompilerConfigImpl? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  required BuildResult buildResult,
  Uri? resourceIdentifiers,
  IOSSdkImpl? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  Target? target,
}) async =>
    await runWithLog(capturedLogs, () async {
      final result = await NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        progressLogger: logger.info,
      ).link(
        linkModePreference: linkModePreference,
        buildMode: BuildModeImpl.release,
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
      );

      if (result.success) {
        await expectAssetsExist(result.assets);
      }

      return result;
    });

Future<(BuildResult, LinkResult)> buildAndLink(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  LinkModePreferenceImpl linkModePreference = LinkModePreferenceImpl.dynamic,
  CCompilerConfigImpl? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  String? runPackageName,
  IOSSdkImpl? targetIOSSdk,
  int? targetIOSVersion,
  int? targetMacOSVersion,
  int? targetAndroidNdkApi,
  Target? target,
  Uri? resourceIdentifiers,
}) async =>
    await runWithLog(capturedLogs, () async {
      final buildRunner = NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        progressLogger: logger.info,
      );
      final buildResult = await buildRunner.build(
        buildMode: BuildModeImpl.release,
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
      );

      if (!buildResult.success) {
        return (buildResult, HookResult());
      }

      await expectAssetsExist(buildResult.assets);
      for (final assetsForLinking in buildResult.assetsForLinking.values) {
        await expectAssetsExist(assetsForLinking);
      }

      final linkResult = await buildRunner.link(
        linkModePreference: linkModePreference,
        buildMode: BuildModeImpl.release,
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
      );

      if (linkResult.success) {
        await expectAssetsExist(buildResult.assets);
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
  LinkModePreferenceImpl linkModePreference = LinkModePreferenceImpl.dynamic,
  CCompilerConfigImpl? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  required bool linkingEnabled,
}) async =>
    runWithLog(capturedLogs, () async {
      final result = await NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        progressLogger: logger.info,
      ).buildDryRun(
        linkModePreference: linkModePreference,
        targetOS: Target.current.os,
        workingDirectory: packageUri,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        linkingEnabled: linkingEnabled,
      );
      return result;
    });

Future<LinkDryRunResult> linkDryRun(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  LinkModePreferenceImpl linkModePreference = LinkModePreferenceImpl.dynamic,
  CCompilerConfigImpl? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  required BuildDryRunResult buildDryRunResult,
}) async =>
    runWithLog(capturedLogs, () async {
      final result = await NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        progressLogger: logger.info,
      ).linkDryRun(
        linkModePreference: linkModePreference,
        targetOS: Target.current.os,
        workingDirectory: packageUri,
        includeParentEnvironment: includeParentEnvironment,
        packageLayout: packageLayout,
        buildDryRunResult: buildDryRunResult,
      );
      return result;
    });

Future<void> expectAssetsExist(List<AssetImpl> assets) async {
  for (final asset in assets) {
    expect(File.fromUri(asset.file!), exists);
  }
}

Future<void> expectSymbols({
  required NativeCodeAssetImpl asset,
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
