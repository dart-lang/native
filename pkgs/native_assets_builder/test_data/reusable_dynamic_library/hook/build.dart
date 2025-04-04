// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final logger =
        Logger('')
          ..level = Level.ALL
          ..onRecord.listen((record) => print(record.message));

    final builder = CBuilder.library(
      name: 'add',
      assetName: 'add.dart',
      sources: ['src/add.c'],
      buildMode: BuildMode.debug,
    );

    await builder.run(
      input: input,
      output: output,
      logger: logger,
      routing: const [
        // Bundle the dylib in the app, someone might use it.
        ToAppBundle(),
        // Enable other packages to link to the dylib.
        ToBuildHooks(),
      ],
    );

    // Enable other packages to find the headers.
    output.metadata['include'] = input.packageRoot.resolve('src/').toFilePath();
  });
}
