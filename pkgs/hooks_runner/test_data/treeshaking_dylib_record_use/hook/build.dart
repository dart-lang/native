// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildCodeAssets) {
      final addLib = CLibrary(
        name: 'add',
        assetName: 'add',
        sources: ['src/add.c'],
      );
      await addLib.build(input: input, output: output);

      final multiplyLib = CLibrary(
        name: 'multiply',
        assetName: 'multiply',
        sources: ['src/multiply.c'],
      );
      await multiplyLib.build(input: input, output: output);
    }
  });
}
