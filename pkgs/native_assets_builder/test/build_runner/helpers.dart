// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:file_testing/file_testing.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_builder/native_assets_builder.dart';
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
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  String? runPackageName,
}) async {
  StreamSubscription<LogRecord>? subscription;
  if (capturedLogs != null) {
    subscription =
        logger.onRecord.listen((event) => capturedLogs.add(event.message));
  }

  final result = await NativeAssetsBuildRunner(
    logger: logger,
    dartExecutable: dartExecutable,
  ).build(
    buildMode: BuildMode.release,
    linkModePreference: linkModePreference,
    target: Target.current,
    workingDirectory: packageUri,
    cCompilerConfig: cCompilerConfig,
    includeParentEnvironment: includeParentEnvironment,
    packageLayout: packageLayout,
    runPackageName: runPackageName,
  );
  if (result.success) {
    await expectAssetsExist(result.assets);
  }

  if (subscription != null) {
    await subscription.cancel();
  }

  return result;
}

Future<DryRunResult> dryRun(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompilerConfig,
  bool includeParentEnvironment = true,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
}) async {
  StreamSubscription<LogRecord>? subscription;
  if (capturedLogs != null) {
    subscription =
        logger.onRecord.listen((event) => capturedLogs.add(event.message));
  }

  final result = await NativeAssetsBuildRunner(
    logger: logger,
    dartExecutable: dartExecutable,
  ).dryRun(
    linkModePreference: linkModePreference,
    targetOs: Target.current.os,
    workingDirectory: packageUri,
    includeParentEnvironment: includeParentEnvironment,
    packageLayout: packageLayout,
  );

  if (subscription != null) {
    await subscription.cancel();
  }

  return result;
}

Future<void> expectAssetsExist(List<Asset> assets) async {
  for (final asset in assets) {
    final uri = (asset.path as AssetAbsolutePath).uri;
    expect(
        uri.toFilePath(),
        contains('${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}'
            'native_assets_builder${Platform.pathSeparator}'));
    final file = File.fromUri(uri);
    expect(file, exists);
  }
}

Future<void> expectSymbols({
  required Asset asset,
  required List<String> symbols,
}) async {
  if (Platform.isLinux) {
    final assetUri = (asset.path as AssetAbsolutePath).uri;
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
