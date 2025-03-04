// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    final linker = CLinker.library(
      name: input.packageName,
      assetName: input.assets.code.single.id.split('/').skip(1).join('/'),
      linkerOptions: LinkerOptions.treeshake(symbols: ['add']),
      sources: [input.assets.code.single.file!.toFilePath()],
    );
    await linker.run(
      input: input,
      output: output,
      logger:
          Logger('')
            ..level = Level.ALL
            ..onRecord.listen((record) {
              print('${record.level.name}: ${record.time}: ${record.message}');
            }),
    );
  });
}
