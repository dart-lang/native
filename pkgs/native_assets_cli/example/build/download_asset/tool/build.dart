// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:download_asset/src/hook_helpers/c_build.dart';
import 'package:download_asset/src/hook_helpers/versions.dart';
import 'package:native_assets_cli/code_assets_builder.dart';

void main(List<String> args) async {
  final (
    os: os,
    architecture: architecture,
    iOSSdk: iOSSdk,
  ) = parseArguments(args);
  final config = createBuildConfig(os, architecture, iOSSdk);
  final output = BuildOutputBuilder();
  await runBuild(config, output);
}

({String architecture, String os, String? iOSSdk}) parseArguments(
    List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'architecture',
      abbr: 'a',
      allowed: Architecture.values.map((a) => a.name),
      mandatory: true,
    )
    ..addOption(
      'os',
      abbr: 'o',
      allowed: OS.values.map((a) => a.name),
      mandatory: true,
    )
    ..addOption(
      'iossdk',
      abbr: 'i',
      allowed: IOSSdk.values.map((a) => a.type),
      help: 'Required if OS is iOS.',
    );
  final argResults = parser.parse(args);

  final os = argResults.option('os');
  final architecture = argResults.option('architecture');
  final iOSSdk = argResults.option('iossdk');
  if (os == null ||
      architecture == null ||
      (os == OS.iOS.name && iOSSdk == null)) {
    print(parser.usage);
    exit(1);
  }
  return (
    os: os,
    architecture: architecture,
    iOSSdk: iOSSdk,
  );
}

BuildConfig createBuildConfig(
  String osString,
  String architecture,
  String? iOSSdk,
) {
  final packageRoot = Platform.script.resolve('..');
  final targetName = createTargetName(osString, architecture, iOSSdk);
  final outputDirectory =
      packageRoot.resolve('.dart_tool/download_asset/$targetName/');
  final outputDirectoryShared =
      packageRoot.resolve('.dart_tool/download_asset/shared/');

  final os = OS.fromString(osString);
  final buildConfigBuilder = BuildConfigBuilder()
    ..setupHookConfig(
      packageRoot: packageRoot,
      packageName: 'download_asset',
      buildAssetTypes: [CodeAsset.type],
    )
    ..setupBuildConfig(dryRun: false, linkingEnabled: false)
    ..setupCodeConfig(
        targetArchitecture: Architecture.fromString(architecture),
        targetOS: os,
        linkModePreference: LinkModePreference.dynamic,
        androidConfig: os != OS.android
            ? null
            : AndroidConfig(
                targetNdkApi: androidTargetNdkApi,
              ),
        iOSConfig: os != OS.iOS
            ? null
            : IOSConfig(
                targetSdk: IOSSdk.fromString(iOSSdk!),
                targetVersion: iOSTargetVersion,
              ),
        macOSConfig: MacOSConfig(targetVersion: macOSTargetVersion))
    ..setupBuildRunConfig(
        outputDirectory: outputDirectory,
        outputDirectoryShared: outputDirectoryShared);
  return BuildConfig(buildConfigBuilder.json);
}
