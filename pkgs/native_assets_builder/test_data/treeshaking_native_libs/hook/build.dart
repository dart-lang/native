// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    final cbuilder = CBuilder.library(
      name: config.packageName + (config.linkingEnabled ? '_static' : ''),
      assetName: 'src/${config.packageName}_bindings_generated.dart',
      sources: [
        'src/native_add.c',
        'src/native_multiply.c',
      ],
      linkModePreference: config.linkingEnabled
          ? LinkModePreference.static
          : LinkModePreference.dynamic,
    );
    await cbuilder.run(
      config: config,
      output: output,
      linkInPackage: config.linkingEnabled ? config.packageName : null,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) {
          print('${record.level.name}: ${record.time}: ${record.message}');
        }),
    );
  });
}
