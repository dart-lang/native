// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

Future<void> runBuild(BuildInput input, BuildOutputBuilder output) async {
  final name = createTargetName(
    input.config.code.targetOS.name,
    input.config.code.targetArchitecture.name,
    input.config.code.targetOS == OS.iOS
        ? input.config.code.iOS.targetSdk.type
        : null,
  );
  final cbuilder = CBuilder.library(
    name: name,
    assetName: 'native_add.dart',
    sources: [
      'src/native_add.c',
    ],
  );
  await cbuilder.run(
    input: input,
    output: output,
    logger: Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) => print(record.message)),
  );
}

String createTargetName(String osString, String architecture, String? iOSSdk) {
  var targetName = 'native_add_${osString}_$architecture';
  if (iOSSdk != null) {
    targetName += '_$iOSSdk';
  }
  return targetName;
}
