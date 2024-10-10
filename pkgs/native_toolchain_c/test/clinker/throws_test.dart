// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

Future<void> main() async {
  for (final os in OS.values) {
    if (Platform.isLinux) {
      // Is implemented.
      continue;
    }

    test(
      'throws on some platforms',
      () async {
        final tempUri = await tempDirForTest();
        final tempUri2 = await tempDirForTest();

        final linkConfigBuilder = LinkConfigBuilder()
          ..setupHookConfig(
            supportedAssetTypes: [CodeAsset.type],
            packageName: 'testpackage',
            packageRoot: tempUri,
            targetOS: os,
            buildMode: BuildMode.debug,
          )
          ..setupLinkConfig(
            assets: [],
          )
          ..setupCodeConfig(
            targetArchitecture: Architecture.x64,
            linkModePreference: LinkModePreference.dynamic,
            cCompilerConfig: cCompiler,
          );
        linkConfigBuilder.setupLinkRunConfig(
          outputDirectoryShared: tempUri2,
          outputDirectory: tempUri,
          recordedUsesFile: null,
        );
        final linkHookConfig = LinkConfig(linkConfigBuilder.json);

        final cLinker = CLinker.library(
          name: 'mylibname',
          linkerOptions: LinkerOptions.manual(),
        );
        await expectLater(
          () => cLinker.run(
            config: linkHookConfig,
            output: LinkOutputBuilder(),
            logger: logger,
          ),
          throwsUnsupportedError,
        );
      },
    );
  }
}
