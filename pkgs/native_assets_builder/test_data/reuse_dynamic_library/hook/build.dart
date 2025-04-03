// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    const dependencyPackage = 'reusable_dynamic_library';
    final buildAssetsFromDep = input.assets[dependencyPackage];
    final codeAssetsFromDep =
        buildAssetsFromDep
            .where((a) => a.isCodeAsset)
            .map((a) => a.asCodeAsset)
            .toList();
    if (codeAssetsFromDep.length != 1) {
      throw Exception(
        'Did not find a build asset from $dependencyPackage:'
        ' $codeAssetsFromDep',
      );
    }
    final codeAsset = codeAssetsFromDep.first;
    final dylibFile = File.fromUri(codeAsset.file!);
    if (!dylibFile.existsSync()) {
      throw Exception('Dylib file does not exist: $dylibFile');
    }
    final libraryDirectory = Directory.fromUri(dylibFile.uri.resolve('.'));
    final includeDirectory = input.metadata[dependencyPackage]['include'];
    if (includeDirectory is! String) {
      throw Exception('Include directory is not a string: $includeDirectory');
    }

    final logger =
        Logger('')
          ..level = Level.ALL
          ..onRecord.listen((record) => print(record.message));

    final builders = [
      CBuilder.library(
        name: 'my_add',
        assetName: 'my_add.dart',
        sources: ['src/my_add.c'],
        libraries: ['add'],
        libraryDirectories: [libraryDirectory.path],
        includes: [includeDirectory],
        buildMode: BuildMode.debug,
      ),
    ];

    // Note: These builders need to be run sequentially because they depend on
    // each others output.
    for (final builder in builders) {
      await builder.run(
        input: input,
        output: output,
        logger: logger,
        routing: const [BundleInApp()],
      );
    }
  });
}
