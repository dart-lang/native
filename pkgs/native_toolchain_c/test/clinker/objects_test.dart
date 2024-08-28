// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

//TODO(mosuem): Enable for windows and mac.
// See https://github.com/dart-lang/native/issues/1376.
@TestOn('linux')
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
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
    final linkOutput = LinkOutput();
    final tempUri = await tempDirForTest();

    final uri = await buildTestArchive(tempUri, os, architecture);
    final linkConfig = LinkConfig.build(
      outputDirectory: tempUri,
      packageName: 'testpackage',
      packageRoot: tempUri,
      targetArchitecture: architecture,
      targetOS: os,
      buildMode: BuildMode.debug,
      linkModePreference: LinkModePreference.dynamic,
      assets: [],
      cCompiler: cCompiler,
    );
    printOnFailure(linkConfig.cCompiler.toString());
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

    expect(linkOutput.assets, hasLength(1));
    final asset = linkOutput.assets.first;
    expect(asset, isA<NativeCodeAsset>());
    await expectSymbols(
      asset: asset as NativeCodeAsset,
      symbols: [
        'my_func',
        'my_other_func',
      ],
    );
  });
}
