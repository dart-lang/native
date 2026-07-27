// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    final codeConfig = input.config.code;
    final wrongArchitecture =
        codeConfig.targetArchitecture == Architecture.arm64
        ? Architecture.x64
        : Architecture.arm64;
    final wrongInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: input.packageName,
        packageRoot: input.packageRoot,
        outputFile: input.outputFile,
        outputDirectoryShared: input.outputDirectoryShared,
      )
      ..config.setupBuild(linkingEnabled: input.config.linkingEnabled)
      ..addExtension(
        CodeAssetExtension(
          targetArchitecture: wrongArchitecture,
          targetOS: codeConfig.targetOS,
          linkModePreference: codeConfig.linkModePreference,
          cCompiler: codeConfig.cCompiler,
          macOS: MacOSCodeConfig(
            targetVersion: codeConfig.macOS.targetVersion,
          ),
          sanitizer: codeConfig.sanitizer,
        ),
      );

    await CBuilder.library(
      name: input.packageName,
      assetName: 'wrong_architecture_asset',
      sources: ['src/wrong_architecture_asset.c'],
    ).run(input: wrongInputBuilder.build(), output: output);
  });
}
