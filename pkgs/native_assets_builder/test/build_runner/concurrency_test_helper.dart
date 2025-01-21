// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:file/local.dart';
import 'package:logging/logging.dart';
import 'package:native_assets_builder/native_assets_builder.dart';

import '../helpers.dart';
import 'helpers.dart';

// Is invoked concurrently multiple times in separate processes.
void main(List<String> args) async {
  final packageUri = Uri.directory(args[0]);
  final packageName = packageUri.pathSegments.lastWhere((e) => e.isNotEmpty);
  Duration? timeout;
  if (args.length >= 2) {
    timeout = Duration(milliseconds: int.parse(args[1]));
  }

  final logger = Logger('')
    ..level = Level.ALL
    ..onRecord.listen((event) => print(event.message));

  final targetOS = OS.current;
  final result = await NativeAssetsBuildRunner(
    logger: logger,
    dartExecutable: dartExecutable,
    singleHookTimeout: timeout,
    fileSystem: const LocalFileSystem(),
  ).build(
    inputCreator: () => BuildInputBuilder()
      ..config.setupCode(
        targetArchitecture: Architecture.current,
        targetOS: targetOS,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: dartCICompilerConfig,
        macOS: targetOS == OS.macOS
            ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
            : null,
      ),
    workingDirectory: packageUri,
    linkingEnabled: false,
    buildAssetTypes: [CodeAsset.type, DataAsset.type],
    inputValidator: (input) async => [
      ...await validateDataAssetBuildInput(input),
      ...await validateCodeAssetBuildInput(input),
    ],
    buildValidator: (input, output) async => [
      ...await validateCodeAssetBuildOutput(input, output),
      ...await validateDataAssetBuildOutput(input, output),
    ],
    applicationAssetValidator: validateCodeAssetInApplication,
    runPackageName: packageName,
  );
  if (result == null) {
    throw Error();
  }
  print('done');
}
