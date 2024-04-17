// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:path/path.dart' as path;

import 'build.dart';

const packageName = 'treeshaking_native_assets';

void main(List<String> arguments) async {
  await link(arguments, (config, output) async {
    final staticLibrary = config.assets
        .firstWhere((asset) => asset.id == 'package:$packageName/staticlib');
    final nameWithoutLibAndSo = path
        .basenameWithoutExtension(placeholderAsset(config).file!.toFilePath())
        .substring(3);
    await CLinker(
      name: nameWithoutLibAndSo,
      //TODO: expose name from `placeholderAsset`
      assetName: 'src/${packageName}_bindings.dart',
      linkerOptions: LinkerOptions.treeshake(
          symbols: config.resources
              ?.map((resource) => resource.metadata)
              .map((metadata) => metadata.toString())),
      sources: [staticLibrary.file!.toFilePath()],
    ).run(
      linkConfig: config,
      linkOutput: output,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) => print(record.message)),
    );
  });
}
