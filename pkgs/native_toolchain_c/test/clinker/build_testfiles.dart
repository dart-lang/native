// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_toolchain_c/native_toolchain_c.dart';

import '../helpers.dart';

Future<Uri> buildTestArchive(
  Uri tempUri,
  Uri tempUri2,
  OS os,
  Architecture architecture,
) async {
  final test1Uri = packageUri.resolve('test/clinker/testfiles/linker/test1.c');
  final test2Uri = packageUri.resolve('test/clinker/testfiles/linker/test2.c');
  if (!await File.fromUri(test1Uri).exists() ||
      !await File.fromUri(test2Uri).exists()) {
    throw Exception('Run the test from the root directory.');
  }
  const name = 'static_test';

  final logMessages = <String>[];
  final logger = createCapturingLogger(logMessages);

  assert(os == OS.linux); // Setup code input for other OSes.
  final buildInputBuilder = BuildInputBuilder()
    ..setupHookInput(
      packageName: name,
      packageRoot: tempUri,
      outputDirectory: tempUri,
      outputDirectoryShared: tempUri2,
    )
    ..targetConfig.setupBuildConfig(
      linkingEnabled: false,
      dryRun: false,
    )
    ..targetConfig.setupCodeConfig(
      targetOS: os,
      targetArchitecture: architecture,
      linkModePreference: LinkModePreference.dynamic,
      cCompilerConfig: cCompiler,
    );

  final buildInput = BuildInput(buildInputBuilder.json);
  final buildOutputBuilder = BuildOutputBuilder();

  final cbuilder = CBuilder.library(
    name: name,
    assetName: '',
    sources: [test1Uri.toFilePath(), test2Uri.toFilePath()],
    linkModePreference: LinkModePreference.static,
    buildMode: BuildMode.release,
  );
  await cbuilder.run(
    input: buildInput,
    output: buildOutputBuilder,
    logger: logger,
  );

  final buildOutput = BuildOutput(buildOutputBuilder.json);
  return buildOutput.assets.code.first.file!;
}
