// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:file/local.dart';
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

Future<BuildResult?> buildCodeAssets(
  Uri packageUri, {
  String? runPackageName,
  List<String>? capturedLogs,
}) =>
    build(
      packageUri,
      logger,
      dartExecutable,
      capturedLogs: capturedLogs,
      inputValidator: validateCodeAssetBuildInput,
      buildAssetTypes: [CodeAsset.type],
      buildValidator: validateCodeAssetBuildOutput,
      applicationAssetValidator: validateCodeAssetInApplication,
      runPackageName: runPackageName,
    );

Future<BuildResult?> build(
  Uri packageUri,
  Logger logger,
  Uri dartExecutable, {
  required BuildInputValidator inputValidator,
  required BuildValidator buildValidator,
  required ApplicationAssetValidator applicationAssetValidator,
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompiler,
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
  Map<String, String>? hookEnvironment,
}) async {
  final targetOS = target?.os ?? OS.current;
  final runPackageName_ =
      runPackageName ?? packageUri.pathSegments.lastWhere((e) => e.isNotEmpty);
  return await runWithLog(capturedLogs, () async {
    final result = await NativeAssetsBuildRunner(
      logger: logger,
      dartExecutable: dartExecutable,
      fileSystem: const LocalFileSystem(),
      hookEnvironment: hookEnvironment,
    ).build(
      inputCreator: () {
        final inputBuilder = BuildInputBuilder();
        if (buildAssetTypes.contains(CodeAsset.type)) {
          inputBuilder.config.setupCode(
            targetArchitecture: target?.architecture ?? Architecture.current,
            targetOS: targetOS,
            linkModePreference: linkModePreference,
            cCompiler: cCompiler ?? dartCICompilerConfig,
            iOS: targetOS == OS.iOS
                ? IOSCodeConfig(
                    targetSdk: targetIOSSdk!,
                    targetVersion: targetIOSVersion!,
                  )
                : null,
            macOS: targetOS == OS.macOS
                ? MacOSCodeConfig(
                    targetVersion: targetMacOSVersion ?? defaultMacOSVersion)
                : null,
            android: targetOS == OS.android
                ? AndroidCodeConfig(targetNdkApi: targetAndroidNdkApi!)
                : null,
          );
        }
        return inputBuilder;
      },
      inputValidator: inputValidator,
      workingDirectory: packageUri,
      packageLayout: packageLayout,
      runPackageName: runPackageName_,
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
  required LinkInputValidator inputValidator,
  required LinkValidator linkValidator,
  required ApplicationAssetValidator applicationAssetValidator,
  LinkModePreference linkModePreference = LinkModePreference.dynamic,
  CCompilerConfig? cCompiler,
  List<String>? capturedLogs,
  PackageLayout? packageLayout,
  String? runPackageName,
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
  final runPackageName_ =
      runPackageName ?? packageUri.pathSegments.lastWhere((e) => e.isNotEmpty);
  return await runWithLog(capturedLogs, () async {
    final result = await NativeAssetsBuildRunner(
      logger: logger,
      dartExecutable: dartExecutable,
      fileSystem: const LocalFileSystem(),
    ).link(
      inputCreator: () {
        final inputBuilder = LinkInputBuilder();
        if (buildAssetTypes.contains(CodeAsset.type)) {
          inputBuilder.config.setupCode(
            targetArchitecture: target?.architecture ?? Architecture.current,
            targetOS: target?.os ?? OS.current,
            linkModePreference: linkModePreference,
            cCompiler: cCompiler ?? dartCICompilerConfig,
            iOS: targetOS == OS.iOS
                ? IOSCodeConfig(
                    targetSdk: targetIOSSdk!,
                    targetVersion: targetIOSVersion!,
                  )
                : null,
            macOS: targetOS == OS.macOS
                ? MacOSCodeConfig(
                    targetVersion: targetMacOSVersion ?? defaultMacOSVersion)
                : null,
            android: targetOS == OS.android
                ? AndroidCodeConfig(targetNdkApi: targetAndroidNdkApi!)
                : null,
          );
        }
        return inputBuilder;
      },
      inputValidator: inputValidator,
      workingDirectory: packageUri,
      packageLayout: packageLayout,
      buildResult: buildResult,
      resourceIdentifiers: resourceIdentifiers,
      buildAssetTypes: buildAssetTypes,
      linkValidator: linkValidator,
      applicationAssetValidator: applicationAssetValidator,
      runPackageName: runPackageName_,
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
  CCompilerConfig? cCompiler,
  required BuildInputValidator buildInputValidator,
  required LinkInputValidator linkInputValidator,
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
      final runPackageName_ = runPackageName ??
          packageUri.pathSegments.lastWhere((e) => e.isNotEmpty);
      final buildRunner = NativeAssetsBuildRunner(
        logger: logger,
        dartExecutable: dartExecutable,
        fileSystem: const LocalFileSystem(),
      );
      final targetOS = target?.os ?? OS.current;
      final buildResult = await buildRunner.build(
        inputCreator: () {
          final inputBuilder = BuildInputBuilder();
          if (buildAssetTypes.contains(CodeAsset.type)) {
            inputBuilder.config.setupCode(
              targetArchitecture: target?.architecture ?? Architecture.current,
              targetOS: target?.os ?? OS.current,
              linkModePreference: linkModePreference,
              cCompiler: cCompiler ?? dartCICompilerConfig,
              iOS: targetOS == OS.iOS
                  ? IOSCodeConfig(
                      targetSdk: targetIOSSdk!,
                      targetVersion: targetIOSVersion!,
                    )
                  : null,
              macOS: targetOS == OS.macOS
                  ? MacOSCodeConfig(
                      targetVersion: targetMacOSVersion ?? defaultMacOSVersion)
                  : null,
              android: targetOS == OS.android
                  ? AndroidCodeConfig(targetNdkApi: targetAndroidNdkApi!)
                  : null,
            );
          }
          return inputBuilder;
        },
        inputValidator: buildInputValidator,
        workingDirectory: packageUri,
        packageLayout: packageLayout,
        runPackageName: runPackageName_,
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
        inputCreator: () {
          final inputBuilder = LinkInputBuilder();
          if (buildAssetTypes.contains(CodeAsset.type)) {
            inputBuilder.config.setupCode(
              targetArchitecture: target?.architecture ?? Architecture.current,
              targetOS: target?.os ?? OS.current,
              linkModePreference: linkModePreference,
              cCompiler: cCompiler ?? dartCICompilerConfig,
              iOS: targetOS == OS.iOS
                  ? IOSCodeConfig(
                      targetSdk: targetIOSSdk!,
                      targetVersion: targetIOSVersion!,
                    )
                  : null,
              macOS: targetOS == OS.macOS
                  ? MacOSCodeConfig(
                      targetVersion: targetMacOSVersion ?? defaultMacOSVersion)
                  : null,
              android: targetOS == OS.android
                  ? AndroidCodeConfig(targetNdkApi: targetAndroidNdkApi!)
                  : null,
            );
          }
          return inputBuilder;
        },
        inputValidator: linkInputValidator,
        workingDirectory: packageUri,
        packageLayout: packageLayout,
        buildResult: buildResult,
        resourceIdentifiers: resourceIdentifiers,
        buildAssetTypes: buildAssetTypes,
        linkValidator: linkValidator,
        applicationAssetValidator: applicationAssetValidator,
        runPackageName: runPackageName_,
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

  if (cc != null && ar != null && ld != null) {
    return CCompilerConfig(
      archiver: Uri.file(ar),
      compiler: Uri.file(cc),
      linker: Uri.file(ld),
      windows: WindowsCCompilerConfig(
          developerCommandPrompt: envScript == null
              ? null
              : DeveloperCommandPrompt(
                  script: Uri.file(envScript),
                  arguments: envScriptArgs ?? [],
                )),
    );
  }
  return null;
})();

int defaultMacOSVersion = 13;
