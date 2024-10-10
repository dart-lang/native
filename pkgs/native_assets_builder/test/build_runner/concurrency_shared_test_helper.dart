// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

  final result = await NativeAssetsBuildRunner(
    logger: logger,
    dartExecutable: dartExecutable,
  ).build(
    configCreator: () => BuildConfigBuilder()
      ..setupCodeConfig(
        targetArchitecture: target.architecture,
        linkModePreference: LinkModePreference.dynamic,
        targetAndroidNdkApi: target.os == OS.android ? 30 : null,
      ),
    buildMode: BuildMode.release,
    targetOS: target.os,
    workingDirectory: packageUri,
    includeParentEnvironment: true,
    linkingEnabled: false,
    supportedAssetTypes: [DataAsset.type],
    buildValidator: (config, output) async =>
        await validateDataAssetBuildOutput(config, output),
    applicationAssetValidator: (_) async => [],
  );
  if (result == null) {
    throw Error();
  }
  print('done');
}
