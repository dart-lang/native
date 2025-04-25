// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/code_assets.dart';
import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_assets_cli/native_assets_cli_builder.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

Future<void> main() async {
  for (final os in OS.values) {
    if (Platform.isLinux) {
      // Is implemented.
      continue;
    }

    test('throws on some platforms', () async {
      final tempUri = await tempDirForTest();
      final tempUri2 = await tempDirForTest();

      final linkInputBuilder =
          LinkInputBuilder()
            ..setupShared(
              packageName: 'testpackage',
              packageRoot: tempUri,
              outputFile: tempUri.resolve('output.json'),
              outputDirectoryShared: tempUri2,
            )
            ..setupLink(assets: [], recordedUsesFile: null)
            ..addExtension(
              CodeAssetExtension(
                targetOS: os,
                targetArchitecture: Architecture.x64,
                linkModePreference: LinkModePreference.dynamic,
                cCompiler: cCompiler,
              ),
            );

      final linkHookInput = linkInputBuilder.build();

      final cLinker = CLinker.library(
        name: 'mylibname',
        linkerOptions: LinkerOptions.manual(),
      );
      await expectLater(
        () => cLinker.run(
          input: linkHookInput,
          output: LinkOutputBuilder(),
          logger: logger,
        ),
        throwsUnsupportedError,
      );
    });
  }
}
