// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

import '../helpers.dart';

Future<Uri> buildTestArchive(
  Uri tempUri,
  Uri tempUri2,
  OS targetOS,
  Architecture architecture, {
  int? androidTargetNdkApi, // Must be specified iff targetOS is OS.android.
}) async {
  assert((targetOS != OS.android) == (androidTargetNdkApi == null));
  final test1Uri = packageUri.resolve('test/clinker/testfiles/linker/test1.c');
  final test2Uri = packageUri.resolve('test/clinker/testfiles/linker/test2.c');
  if (!await File.fromUri(test1Uri).exists() ||
      !await File.fromUri(test2Uri).exists()) {
    throw Exception('Run the test from the root directory.');
  }
  const name = 'static_test';

  final logMessages = <String>[];
  final logger = createCapturingLogger(logMessages);

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
        targetOS: targetOS,
        targetArchitecture: architecture,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: cCompiler,
        android: androidTargetNdkApi != null
            ? AndroidCodeConfig(targetNdkApi: androidTargetNdkApi)
            : null,
      ),
    );

  final buildInput = buildInputBuilder.build();
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

  final buildOutput = buildOutputBuilder.build();
  return buildOutput.assets.code.first.file!;
}
