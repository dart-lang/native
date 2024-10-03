// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_builder/native_assets_builder.dart';

import '../helpers.dart';

// Is invoked concurrently multiple times in separate processes.
void main(List<String> args) async {
  final packageUri = Uri.directory(args[0]);
  Duration? timeout;
  if (args.length >= 2) {
    timeout = Duration(milliseconds: int.parse(args[1]));
  }

  final logger = Logger('')
    ..level = Level.ALL
    ..onRecord.listen((event) => print(event.message));

  final result = await NativeAssetsBuildRunner(
    logger: logger,
    dartExecutable: dartExecutable,
    singleHookTimeout: timeout,
  ).build(
    configCreator: () => BuildConfigBuilder()
      ..setupCodeConfig(
        targetArchitecture: Architecture.current,
        linkModePreference: LinkModePreference.dynamic,
      ),
    buildMode: BuildMode.release,
    targetOS: OS.current,
    workingDirectory: packageUri,
    includeParentEnvironment: true,
    linkingEnabled: false,
    supportedAssetTypes: [CodeAsset.type, DataAsset.type],
    buildValidator: (config, output) async => [
      ...await validateCodeAssetBuildOutput(config, output),
      ...await validateDataAssetBuildOutput(config, output),
    ],
    applicationAssetValidator: validateCodeAssetsInApplication,
  );
  if (result == null) {
    throw Error();
  }
  print('done');
}
