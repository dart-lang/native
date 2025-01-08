// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

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

        final linkInputBuilder = LinkInputBuilder()
          ..setupShared(
            packageName: 'testpackage',
            packageRoot: tempUri,
            outputDirectoryShared: tempUri2,
            outputDirectory: tempUri,
          )
          ..setupLink(
            assets: [],
            recordedUsesFile: null,
          )
          ..config.setupShared(buildAssetTypes: [CodeAsset.type])
          ..config.setupCode(
            targetOS: os,
            targetArchitecture: Architecture.x64,
            linkModePreference: LinkModePreference.dynamic,
            cCompiler: cCompiler,
          );

        final linkHookInput = LinkInput(linkInputBuilder.json);

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
      },
    );
  }
}
