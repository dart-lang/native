// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Regression test for building with MSVC when the
// `NoDefaultCurrentDirectoryInExePath` environment variable is set.
//
// With that variable set, cmd.exe doesn't search the working directory for
// bare command names. `environmentFromBatchFile` used to run `vcvars64.bat` by
// bare name from its own directory, so cmd.exe didn't find it and the MSVC
// environment came back empty.

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

  const name = 'add';

  test('CBuilder', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
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
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );
    final buildInput = buildInputBuilder.build();

    await CBuilder.library(
      name: name,
      assetName: name,
      sources: [
        packageUri
            .resolve('test/cbuilder/testfiles/add/src/add.c')
            .toFilePath(),
      ],
      buildMode: .release,
    ).run(
      input: buildInput,
      output: BuildOutputBuilder(),
      logger: logger,
      processManager: const NoDefaultCurrentDirectoryInExePathProcessManager(),
    );

    final libUri = buildInput.outputDirectory.resolve(
      OS.windows.dylibFileName(name),
    );
    final dylib = openDynamicLibraryForTest(libUri.toFilePath());
    final add = dylib
        .lookupFunction<Int32 Function(Int32, Int32), int Function(int, int)>(
          'add',
        );
    expect(add(1, 2), 3);
  });
}
