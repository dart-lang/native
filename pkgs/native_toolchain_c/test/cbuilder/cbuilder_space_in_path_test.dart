// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Regression test for building with MSVC when the source, include, and output
// paths contain a space (e.g. the default pub cache under a Windows user name
// with a space, `C:\Users\First Last\AppData\Local\Pub\Cache\...`).
//
// Previously the MSVC compiler/archiver were invoked through `cmd.exe`, whose
// `/c` quote-stripping rule mangled the command line as soon as more than one
// argument (the `cl.exe` path plus a spaced source/include) was quoted, causing
// `'C:\Program' is not recognized as an internal or external command`.

@TestOn('windows')
@OnPlatform({'windows': Timeout.factor(10)})
library;

import 'dart:ffi';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isWindows) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  for (final linkMode in [DynamicLoadingBundled(), StaticLinking()]) {
    test('CBuilder $linkMode with a space in the source path', () async {
      // The spaced prefix puts a space in the source/include paths as well
      // as in the output paths (`/Fe:`, `/out:`), which are derived from
      // [outputDirectoryShared] below.
      const spacedPrefix = 'ntc space test ';
      final spacedRoot = await tempDirForTest(prefix: spacedPrefix);
      final addCUri = packageUri.resolve(
        'test/cbuilder/testfiles/add/src/add.c',
      );
      final spacedSourceUri = spacedRoot.resolve('add.c');
      await File.fromUri(addCUri).copy(spacedSourceUri.toFilePath());

      final tempUri = await tempDirForTest(prefix: spacedPrefix);
      final tempUri2 = await tempDirForTest(prefix: spacedPrefix);
      const name = 'add';

      final buildInputBuilder = BuildInputBuilder()
        ..setupShared(
          packageName: name,
          packageRoot: tempUri,
          outputFile: tempUri.resolve('output.json'),
          outputDirectoryShared: tempUri2,
        )
        ..config.setupBuild(linkingEnabled: false)
        ..addExtension(
          CodeAssetExtension(
            targetOS: OS.windows,
            targetArchitecture: Architecture.current,
            linkModePreference: linkMode == DynamicLoadingBundled()
                ? LinkModePreference.dynamic
                : LinkModePreference.static,
            cCompiler: cCompiler,
          ),
        );

      final buildInput = buildInputBuilder.build();
      final buildOutput = BuildOutputBuilder();

      final cbuilder = CBuilder.library(
        name: name,
        assetName: name,
        sources: [spacedSourceUri.toFilePath()],
        // Also exercise a `/I` include argument whose path contains a space.
        includes: [spacedRoot.toFilePath()],
        buildMode: .release,
      );
      // Fails on the unpatched code with a `ProcessException` because the
      // compiler dies with `'C:\Program' is not recognized ...`.
      await cbuilder.run(
        input: buildInput,
        output: buildOutput,
        logger: logger,
      );

      final libUri = buildInput.outputDirectory.resolve(
        OS.windows.libraryFileName(name, linkMode),
      );
      expect(await File.fromUri(libUri).exists(), isTrue);

      if (linkMode == DynamicLoadingBundled()) {
        final dylib = openDynamicLibraryForTest(libUri.toFilePath());
        final add = dylib
            .lookupFunction<
              Int32 Function(Int32, Int32),
              int Function(int, int)
            >('add');
        expect(add(1, 2), 3);
      }
    });
  }
}
