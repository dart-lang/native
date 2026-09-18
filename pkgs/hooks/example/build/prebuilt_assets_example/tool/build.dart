// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:prebuilt_assets_example/src/hook_helpers/c_build.dart';
import 'package:prebuilt_assets_example/src/hook_helpers/target_versions.dart';

void main(List<String> args) async {
  final (os: os, architecture: architecture, iOSSdk: iOSSdk) = parseArguments(
    args,
  );
  await buildPrebuiltAsset(
    OS.fromString(os),
    Architecture.fromString(architecture),
    iOSSdk != null ? IOSSdk.fromString(iOSSdk) : null,
  );
}

/// Builds the native asset for [os], [architecture], and optional [iOSSdk]
/// and copies the compiled dynamic library into `assets/`.
Future<File> buildPrebuiltAsset(
  OS os,
  Architecture architecture,
  IOSSdk? iOSSdk, {
  Uri? packageRoot,
}) async {
  final input = createBuildInput(
    os,
    architecture,
    iOSSdk,
    packageRoot: packageRoot,
  );
  final outputBuilder = BuildOutputBuilder();
  await runBuild(input, outputBuilder);
  final output = outputBuilder.build();
  final builtAsset = output.assets.code.single;
  final builtFile = File.fromUri(builtAsset.file!);
  final fileName = targetFileName(os, architecture, iOSSdk);
  final targetFile = File.fromUri(
    input.packageRoot.resolve('assets/$fileName'),
  );
  await targetFile.parent.create(recursive: true);
  return await builtFile.copy(targetFile.path);
}

({String architecture, String os, String? iOSSdk}) parseArguments(
  List<String> args,
) {
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
  return (os: os, architecture: architecture, iOSSdk: iOSSdk);
}

BuildInput createBuildInput(
  OS os,
  Architecture architecture,
  IOSSdk? iOSSdk, {
  Uri? packageRoot,
}) {
  final defaultRoot = Platform.script.resolve('..');
  packageRoot ??= File.fromUri(defaultRoot.resolve('pubspec.yaml')).existsSync()
      ? defaultRoot
      : Directory.current.uri;
  final outputDirectoryShared = packageRoot.resolve(
    '.dart_tool/prebuilt_assets_example/shared/',
  );
  final outputFile = packageRoot.resolve(
    '.dart_tool/prebuilt_assets_example/output.json',
  );

  final inputBuilder = BuildInputBuilder()
    ..setupShared(
      packageRoot: packageRoot,
      packageName: 'prebuilt_assets_example',
      outputFile: outputFile,
      outputDirectoryShared: outputDirectoryShared,
    )
    ..config.setupBuild(linkingEnabled: false)
    ..addExtension(
      CodeAssetExtension(
        targetArchitecture: architecture,
        targetOS: os,
        linkModePreference: LinkModePreference.dynamic,
        android: os != OS.android
            ? null
            : AndroidCodeConfig(targetNdkApi: androidTargetNdkApi),
        iOS: os != OS.iOS
            ? null
            : IOSCodeConfig(
                targetSdk: iOSSdk!,
                targetVersion: iOSTargetVersion,
              ),
        macOS: MacOSCodeConfig(targetVersion: macOSTargetVersion),
      ),
    );
  return inputBuilder.build();
}
