// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const packageName = 'native_add';

void main(List<String> arguments) async {
  final config = await BuildConfig.fromArgs(arguments);
  final output = BuildOutput();
  final cbuilder = CBuilder.library(
    name: packageName,
    assetId: 'package/$packageName:src/${packageName}_bindings_generated.dart',
    sources: [
      'src/$packageName.c',
    ],
    dartBuildFiles: ['build.dart'],
  );
  await cbuilder.run(
    buildConfig: config,
    buildOutput: output,
    logger: Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      }),
  );
  await output.writeToFile(outDir: config.outDir);
}
