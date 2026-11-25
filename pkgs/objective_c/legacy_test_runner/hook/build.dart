// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) {
      return;
    }
    final targetOS = input.config.code.targetOS;
    if (targetOS != OS.macOS && targetOS != OS.iOS) {
      return;
    }
    final builder = CBuilder.library(
      name: 'legacy_bindings',
      assetName: 'legacy_bindings.g.dart',
      language: Language.objectiveC,
      sources: ['src/legacy_fixture.m', 'src/legacy_bindings.m'],
      includes: ['src'],
      flags: ['-fobjc-arc'],
      frameworks: ['Foundation'],
    );
    await builder.run(input: input, output: output);
  });
}
