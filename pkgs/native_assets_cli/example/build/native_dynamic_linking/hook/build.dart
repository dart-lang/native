// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (config, output) async {
    final logger = Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) => print(record.message));

    final mathBuilder = CBuilder.library(
      name: 'math',
      assetName: 'math',
      sources: [
        'src/math.c',
      ],
    );
    await mathBuilder.run(
      config: config,
      output: output,
      logger: logger,
    );

    final mathLibraryUri = output.assets
        .whereType<NativeCodeAsset>()
        .where((asset) => asset.id.endsWith('math'))
        .single
        .file;

    final addBuilder = CBuilder.library(
      name: 'add',
      assetName: 'add.dart',
      sources: [
        'src/add.c',
      ],
      // TODO: Use specific API for linking once available.
      // TODO: Enable support for Windows once linker flags are supported or
      // specific API for linking is available.
      // https://github.com/dart-lang/native/issues/190
      flags: [
        if (mathLibraryUri != null)
          ...switch (config.targetOS) {
            OS.macOS => [
                '-L${mathLibraryUri.resolve('./').toFilePath()}',
                '-lmath',
              ],
            OS.linux => [
                '-Wl,-rpath=\$ORIGIN/.',
                '-L${mathLibraryUri.resolve('./').toFilePath()}',
                '-lmath',
              ],
            _ => throw UnimplementedError('Unsupported OS: ${config.targetOS}'),
          }
      ],
    );
    await addBuilder.run(
      config: config,
      output: output,
      logger: logger,
    );
  });
}
