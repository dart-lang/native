// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';
import 'build_testfiles.dart';

/// Tree-shakes a static library down to so many symbols that one linker flag
/// per symbol would exceed the 32,767 character command-line limit of Windows.
void main() {
  const functionCount = 2000;
  const keptCount = 1500;
  String functionName(int i) =>
      'a_function_with_a_long_name_to_exceed_the_command_line_limit_'
      '${i.toString().padLeft(4, '0')}';

  test(
    'treeshake keeps $keptCount symbols',
    timeout: const Timeout(Duration(minutes: 5)),
    () async {
      final targetOS = OS.current;
      final targetArchitecture = Architecture.current;
      final macOSTargetVersion = targetOS == OS.macOS
          ? defaultMacOSVersion
          : null;
      final tempUri = await tempDirForTest();
      final tempUri2 = await tempDirForTest();

      // Plain C functions without `__declspec(dllexport)`, so that on Windows
      // only the generated module-definition file exports them.
      final source = tempUri.resolve('many_functions.c');
      await File.fromUri(source).writeAsString(
        [
          for (var i = 0; i < functionCount; i++)
            'int ${functionName(i)}(void) { return $i; }',
          '',
        ].join('\n'),
      );

      final archive = await buildTestArchive(
        tempUri,
        tempUri2,
        targetOS,
        targetArchitecture,
        extraSources: [source],
        macOSTargetVersion: macOSTargetVersion,
      );

      final linkInput =
          (LinkInputBuilder()
                ..setupShared(
                  packageName: 'testpackage',
                  packageRoot: tempUri,
                  outputFile: tempUri.resolve('output.json'),
                  outputDirectoryShared: tempUri2,
                )
                ..setupLink(
                  assets: [],
                  recordedUsesFile: null,
                  assetsFromLinking: [],
                )
                ..addExtension(
                  CodeAssetExtension(
                    targetOS: targetOS,
                    targetArchitecture: targetArchitecture,
                    linkModePreference: LinkModePreference.dynamic,
                    cCompiler: cCompiler,
                    macOS: macOSTargetVersion != null
                        ? MacOSCodeConfig(targetVersion: macOSTargetVersion)
                        : null,
                  ),
                ))
              .build();
      final linkOutputBuilder = LinkOutputBuilder();

      await CLinker.library(
        name: 'mylibname',
        assetName: '',
        sources: [archive.toFilePath()],
        linkerOptions: LinkerOptions.treeshake(
          symbolsToKeep: [for (var i = 0; i < keptCount; i++) functionName(i)],
        ),
      ).run(input: linkInput, output: linkOutputBuilder, logger: logger);

      final asset = linkOutputBuilder.build().assets.code.single;
      await expectSymbols(
        asset: asset,
        targetOS: targetOS,
        symbols: [functionName(0), functionName(keptCount - 1)],
        symbolsNotToContain: [
          functionName(keptCount),
          functionName(functionCount - 1),
          'my_func',
        ],
      );
    },
  );
}
