// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    if (!input.config.linkingEnabled) {
      throw Exception('Link hook must be run!');
    }
    final logger = Logger('')
      ..level = Level.ALL
      ..onRecord.listen((record) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      });
    await CBuilder.library(
      name: 'add',
      assetName: 'dylib_add_build',
      sources: [
        'src/native_add.c',
      ],
      linkModePreference: LinkModePreference.dynamic,
    ).run(
      input: input,
      output: output,
      logger: logger,
      linkInPackage: 'add_asset_link',
    );
  });
}
