// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Regression test for the MSVC archiver invocation. `RunCBuilder.runCl` must
// pass the archiver (`lib.exe`) the object file names derived from the sources
// (e.g. `add.obj`), not `*.obj`.
//
// `cl.exe /c` writes one object file per source into the build output
// directory, and `lib.exe` expands `*.obj` against that directory. So with
// `*.obj` the archiver sweeps in *any* `.obj` file left in the output
// directory by another build, corrupting the archive (and failing outright if
// such a leftover object is not a valid COFF file). Passing the derived names
// keeps the archive contents independent of unrelated files in the directory.
//
// This guards against a well-meaning simplification back to `*.obj`.

@TestOn('windows')
@OnPlatform({'windows': Timeout.factor(10)})
library;

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

  test('CBuilder static library ignores stray .obj files in the output '
      'directory', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
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
          linkModePreference: LinkModePreference.static,
          cCompiler: cCompiler,
        ),
      );

    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    // Drop a leftover object file into the build output directory before the
    // build runs, simulating an object file left behind by an earlier build.
    // `CBuilder.run` creates this directory with `create(recursive: true)`,
    // which does not remove existing contents, so the stray file is still
    // present when the archiver runs. It is deliberately not a valid COFF
    // file, so `lib.exe` fails on it (`LNK1107`) if it is ever passed `*.obj`.
    final outputDirectory = buildInput.outputDirectory;
    await Directory.fromUri(outputDirectory).create(recursive: true);
    await File.fromUri(
      outputDirectory.resolve('stray.obj'),
    ).writeAsString('not a valid object file');

    final cbuilder = CBuilder.library(
      name: name,
      assetName: name,
      sources: [addCUri.toFilePath()],
      buildMode: .release,
    );
    // Throws on the unpatched (`*.obj`) code: `lib.exe` picks up `stray.obj`
    // and fails with `fatal error LNK1107: invalid or corrupt file`.
    await cbuilder.run(input: buildInput, output: buildOutput, logger: logger);

    final libUri = outputDirectory.resolve(
      OS.windows.libraryFileName(name, StaticLinking()),
    );
    expect(await File.fromUri(libUri).exists(), isTrue);
  });
}
