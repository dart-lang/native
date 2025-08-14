// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    final asset = input.assets.code.single;
    final packageName = asset.id.split('/').first.replaceAll('package:', '');
    final assetName = asset.id.split('/').skip(1).join('/');
    final linker = CLinker.library(
      name: packageName,
      assetName: assetName,
      linkerOptions: LinkerOptions.treeshake(symbolsToKeep: ['add']),
      sources: [asset.file!.toFilePath()],
    );
    await linker.run(
      input: input,
      output: output,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) {
          print('${record.level.name}: ${record.time}: ${record.message}');
        }),
    );
  });
}
