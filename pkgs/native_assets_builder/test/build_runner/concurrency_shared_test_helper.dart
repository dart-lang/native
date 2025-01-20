// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/local.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_builder/native_assets_builder.dart';

import '../helpers.dart';

// Is invoked concurrently multiple times in separate processes.
void main(List<String> args) async {
  final packageUri = Uri.directory(args[0]);
  final target = Target.fromString(args[1]);

  final logger = Logger('')
    ..level = Level.ALL
    ..onRecord.listen((event) => print(event.message));

  final targetOS = target.os;
  final result = await NativeAssetsBuildRunner(
    logger: logger,
    dartExecutable: dartExecutable,
    fileSystem: const LocalFileSystem(),
  ).build(
    // Set up the code input, so that the builds for different targets are
    // in different directories.
    inputCreator: () => BuildInputBuilder()
      ..config.setupCode(
        targetArchitecture: target.architecture,
        targetOS: targetOS,
        macOS: targetOS == OS.macOS
            ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
            : null,
        android:
            targetOS == OS.android ? AndroidCodeConfig(targetNdkApi: 30) : null,
        linkModePreference: LinkModePreference.dynamic,
      ),

    workingDirectory: packageUri,
    linkingEnabled: false,
    buildAssetTypes: [DataAsset.type, CodeAsset.type],
    inputValidator: (input) async => [
      ...await validateDataAssetBuildInput(input),
      ...await validateCodeAssetBuildInput(input),
    ],
    buildValidator: (input, output) async => [
      ...await validateDataAssetBuildOutput(input, output),
      ...await validateCodeAssetBuildOutput(input, output),
    ],
    applicationAssetValidator: validateCodeAssetInApplication,
  );
  if (result == null) {
    throw Error();
  }
  print('done');
}

int defaultMacOSVersion = 13;
