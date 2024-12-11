// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//TODO(mosuem): Enable for windows and mac.
// See https://github.com/dart-lang/native/issues/1376.
@TestOn('linux')
library;

import 'dart:io';

import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'build_testfiles.dart';

Future<void> main() async {
  if (!Platform.isLinux) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  final architecture = Architecture.current;
  const os = OS.linux;
  const name = 'mylibname';

  test('link two objects', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();

    final uri = await buildTestArchive(tempUri, tempUri2, os, architecture);

    final linkConfigBuilder = LinkConfigBuilder()
      ..setupHookConfig(
        buildAssetTypes: [CodeAsset.type],
        packageName: 'testpackage',
        packageRoot: tempUri,
      )
      ..setupLinkConfig(
        assets: [],
      )
      ..setupCodeConfig(
        targetOS: os,
        targetArchitecture: architecture,
        linkModePreference: LinkModePreference.dynamic,
        cCompilerConfig: cCompiler,
      );
    linkConfigBuilder.setupLinkRunConfig(
      outputDirectory: tempUri,
      outputDirectoryShared: tempUri2,
      recordedUsesFile: null,
    );
    final linkConfig = LinkConfig(linkConfigBuilder.json);
    final linkOutput = LinkOutputBuilder();

    printOnFailure(linkConfig.codeConfig.cCompiler.toString());
    printOnFailure(Platform.environment.keys.toList().toString());
    await CLinker.library(
      name: name,
      assetName: '',
      linkerOptions: LinkerOptions.manual(gcSections: false),
      sources: [uri.toFilePath()],
    ).run(
      config: linkConfig,
      output: linkOutput,
      logger: logger,
    );

    final codeAssets = LinkOutput(linkOutput.json).codeAssets;
    expect(codeAssets, hasLength(1));
    final asset = codeAssets.first;
    expect(asset, isA<CodeAsset>());
    await expectSymbols(
      asset: asset,
      symbols: [
        'my_func',
        'my_other_func',
      ],
    );
  });
}
