// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  for (final targetOS in OS.values) {
    if (targetOS == OS.linux ||
        targetOS == OS.android ||
        targetOS == OS.macOS ||
        targetOS == OS.iOS) {
      // Is implemented.
      continue;
    }

    test('throws when targeting $targetOS', () async {
      final tempUri = await tempDirForTest();
      final tempUri2 = await tempDirForTest();

      final linkInputBuilder = LinkInputBuilder()
        ..setupShared(
          packageName: 'testpackage',
          packageRoot: tempUri,
          outputFile: tempUri.resolve('output.json'),
          outputDirectoryShared: tempUri2,
        )
        ..setupLink(assets: [], recordedUsesFile: null)
        ..addExtension(
          CodeAssetExtension(
            targetOS: targetOS,
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
        targetOS == OS.fuchsia ? throwsFormatException : throwsUnsupportedError,
      );
    });
  }
}
