// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (config, output) async {
    final packageName = config.packageName;
    final cbuilder = CBuilder.library(
      name: packageName,
      assetName: '$packageName.dart',
      sources: [
        'src/$packageName.c',
      ],
      dartBuildFiles: ['hook/build.dart'],
    );
    final (assets, dependencies) = await cbuilder.run(
      hookConfig: config,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) => print(record.message)),
    );
    output.addAssets(assets);
    output.addDependencies(dependencies);
  });
}
