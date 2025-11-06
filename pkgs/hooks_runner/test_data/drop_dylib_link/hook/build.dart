// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final routing = input.config.linkingEnabled
        ? <AssetRouting>[ToLinkHook(input.packageName)]
        : [const ToAppBundle()];
    await CBuilder.library(
      name: 'add',
      assetName: 'dylib_add',
      sources: ['src/native_add.c'],
      linkModePreference: LinkModePreference.dynamic,
    ).run(input: input, output: output, routing: routing);

    await CBuilder.library(
      name: 'multiply',
      assetName: 'dylib_multiply',
      sources: ['src/native_multiply.c'],
      linkModePreference: LinkModePreference.dynamic,
    ).run(input: input, output: output, routing: routing);
  });
}
