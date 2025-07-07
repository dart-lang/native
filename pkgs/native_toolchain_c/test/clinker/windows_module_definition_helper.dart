// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'build_testfiles.dart';

void runWindowsModuleDefinitionTests(List<Architecture> architectures) {
  const name = 'mylibname';
  const targetOS = OS.windows;

  for (final architecture in architectures) {
    test(
      'Module definition script can export unexported function ($architecture)',
      () async {
        final tempUri = await tempDirForTest();
        final tempUri2 = await tempDirForTest();

        final uri = await buildTestArchive(
          tempUri,
          tempUri2,
          targetOS,
          architecture,
          extraSources: [
            packageUri.resolve('test/clinker/testfiles/linker/test3.c'),
          ],
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
            ),
          );

        final linkInput = linkInputBuilder.build();
        final linkOutput = LinkOutputBuilder();

        printOnFailure(linkInput.config.code.cCompiler.toString());
        printOnFailure(Platform.environment.keys.toList().toString());
        await CLinker.library(
          name: name,
          assetName: '',
          linkerOptions: LinkerOptions.treeshake(
            symbols: ['my_func', 'my_unexported_func'],
          ),
          sources: [uri.toFilePath()],
        ).run(input: linkInput, output: linkOutput, logger: logger);

        final codeAssets = LinkOutput(linkOutput.json).assets.code;
        expect(codeAssets, hasLength(1));
        final asset = codeAssets.first;
        expect(asset, isA<CodeAsset>());
        final symbols = await readSymbols(asset, targetOS);
        final skipReason = symbols == null
            ? 'tool to extract symbols unavailable'
            : false;
        expect(symbols, contains('my_func'), skip: skipReason);
        // Module Definition file causes my_unexported_func to be exported even
        // though it wasn't marked for export.
        expect(symbols, contains('my_unexported_func'), skip: skipReason);
        expect(symbols, isNot(contains('my_other_func')), skip: skipReason);
      },
    );
  }
}
