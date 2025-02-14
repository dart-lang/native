// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';
import 'package:native_assets_cli/code_assets.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final cbuilder = CBuilder.library(
      name: input.packageName + (input.config.linkingEnabled ? '_static' : ''),
      assetName: 'src/${input.packageName}_bindings_generated.dart',
      sources: ['src/native_add.c', 'src/native_multiply.c'],
      linkModePreference:
          input.config.linkingEnabled
              ? LinkModePreference.static
              : LinkModePreference.dynamic,
    );
    await cbuilder.run(
      input: input,
      output: output,
      linkInPackage: input.config.linkingEnabled ? input.packageName : null,
      logger:
          Logger('')
            ..level = Level.ALL
            ..onRecord.listen((record) {
              print('${record.level.name}: ${record.time}: ${record.message}');
            }),
    );
  });
}
