// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await link(
    arguments,
    (config, output) async {
      final linker = CLinker.library(
        name: config.packageName,
        assetName: config.codeAssets.single.id.split('/').skip(1).join('/'),
        linkerOptions: LinkerOptions.treeshake(symbols: ['add']),
        sources: [config.codeAssets.single.file!.toFilePath()],
      );
      await linker.run(
        config: config,
        output: output,
        logger: Logger('')
          ..level = Level.ALL
          ..onRecord.listen((record) {
            print('${record.level.name}: ${record.time}: ${record.message}');
          }),
      );
    },
  );
}
