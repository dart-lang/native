// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

Future<void> runBuild(BuildConfig config, BuildOutputBuilder output) async {
  final target = createTargetName(
    config.codeConfig.targetOS.name,
    config.codeConfig.targetArchitecture.name,
    config.codeConfig.targetOS == OS.iOS
        ? config.codeConfig.iOSConfig.targetSdk.type
        : null,
  );
  final cbuilder = CBuilder.library(
    name: 'native_add_$target',
    assetName: 'native_add.dart',
    sources: [
      'src/native_add.c',
    ],
  );
  await cbuilder.run(
    config: config,
    output: output,
    logger: Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) => print(record.message)),
  );
}

String createTargetName(String osString, String architecture, String? iOSSdk) {
  var targetName = '${osString}_$architecture';
  if (iOSSdk != null) {
    targetName += '_$iOSSdk';
  }
  return targetName;
}
