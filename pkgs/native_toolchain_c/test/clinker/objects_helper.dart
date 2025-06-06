// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'build_testfiles.dart';

Future<void> runObjectTests(
  OS targetOS,
  List<Architecture> architectures,
) async {
  const name = 'mylibname';

  for (final architecture in architectures) {
    test('link two objects for $architecture', () async {
      final tempUri = await tempDirForTest();
      final tempUri2 = await tempDirForTest();

      final uri = await buildTestArchive(
        tempUri,
        tempUri2,
        targetOS,
        architecture,
      );

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
            targetArchitecture: architecture,
            linkModePreference: LinkModePreference.dynamic,
            cCompiler: cCompiler,
            android: targetOS == OS.android
                ? AndroidCodeConfig(targetNdkApi: 21)
                : null,
          ),
        );

      final linkInput = linkInputBuilder.build();
      final linkOutput = LinkOutputBuilder();

      printOnFailure(linkInput.config.code.cCompiler.toString());
      printOnFailure(Platform.environment.keys.toList().toString());
      await CLinker.library(
        name: name,
        assetName: '',
        linkerOptions: LinkerOptions.manual(gcSections: false),
        sources: [uri.toFilePath()],
      ).run(input: linkInput, output: linkOutput, logger: logger);

      final codeAssets = LinkOutput(linkOutput.json).assets.code;
      expect(codeAssets, hasLength(1));
      final asset = codeAssets.first;
      expect(asset, isA<CodeAsset>());
      expect(
        await nmReadSymbols(asset),
        stringContainsInOrder(['my_func', 'my_other_func']),
      );
    });
  }
}
