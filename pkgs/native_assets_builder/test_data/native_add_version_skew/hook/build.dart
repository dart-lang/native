// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    final packageName = config.packageName;
    final cbuilder = CBuilder.library(
      name: packageName,
      assetName: 'src/${packageName}_bindings_generated.dart',
      sources: [
        'src/$packageName.c',
      ],
    );
    await cbuilder.run(
      config: config,
      output: output,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) {
          print('${record.level.name}: ${record.time}: ${record.message}');
        }),
    );
  });
}
