// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final builders = [
      CBuilder.library(
        name: 'debug',
        assetName: 'debug',
        sources: ['src/debug.c'],
        buildMode: BuildMode.debug,
      ),
      CBuilder.library(
        name: 'math',
        assetName: 'math',
        sources: ['src/math.c'],
        libraries: ['debug'],
        buildMode: BuildMode.debug,
      ),
      CBuilder.library(
        name: 'add',
        assetName: 'add.dart',
        sources: ['src/add.c'],
        libraries: ['math'],
        buildMode: BuildMode.debug,
      ),
    ];

    // Note: These builders need to be run sequentially because they depend on
    // each others output.
    for (final builder in builders) {
      await builder.run(input: input, output: output);
    }
  });
}
