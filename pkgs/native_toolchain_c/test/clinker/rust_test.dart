// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

Future<void> main() async {
  late final LinkInput linkInput;
  late final Uri staticLib;
  final linkOutputBuilder = LinkOutputBuilder();
  final targetArchitecture = Architecture.current;
  final targetOS = OS.current;
  late final bool rustToolchainInstalled;
  setUpAll(() async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    staticLib = tempUri.resolve(targetOS.staticlibFileName('libtest'));
    final processResult = await Process.run('rustc', [
      '--crate-type=staticlib',
      'test/clinker/testfiles/linker/test.rs',
      '-o',
      staticLib.toFilePath(),
    ]);
    rustToolchainInstalled = processResult.exitCode == 0;
    if (rustToolchainInstalled) {
      await File.fromUri(
        staticLib,
      ).copy(tempUri.resolve('libtest.a').toFilePath());
    }
    final linkInputBuilder = LinkInputBuilder()
      ..setupShared(
        packageName: 'testpackage',
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: tempUri2,
      )
      ..setupLink(assets: [], recordedUsesFile: null, assetsFromLinking: [])
      ..addExtension(
        CodeAssetExtension(
          targetOS: targetOS,
          targetArchitecture: targetArchitecture,
          linkModePreference: LinkModePreference.dynamic,
        ),
      );

    linkInput = linkInputBuilder.build();
  });
  test('link rust binary with script treeshakes', () async {
    if (!rustToolchainInstalled) {
      return;
    }
    final treeshakeOption = LinkerOptions.treeshake(
      symbolsToKeep: ['my_other_func'],
    );
    final symbols = await _link(
      staticLib,
      treeshakeOption,
      linkInput,
      linkOutputBuilder,
      targetArchitecture,
      targetOS,
    );
    final skipReason = symbols == null
        ? 'tool to extract symbols unavailable'
        : false;
    expect(symbols, contains('my_other_func'), skip: skipReason);
    expect(symbols, isNot(contains('my_func')), skip: skipReason);
  });

  test('link rust binary without script keeps symbols', () async {
    if (!rustToolchainInstalled) {
      return;
    }
    final manualOption = LinkerOptions.manual(
      symbolsToKeep: ['my_other_func'],
      stripDebug: true,
      gcSections: true,
    );
    final symbols = await _link(
      staticLib,
      manualOption,
      linkInput,
      linkOutputBuilder,
      targetArchitecture,
      targetOS,
    );
    final skipReason = symbols == null
        ? 'tool to extract symbols unavailable'
        : false;
    expect(symbols, contains('my_other_func'), skip: skipReason);
    expect(symbols, contains('my_func'), skip: skipReason);
  });
}

Future<String?> _link(
  Uri staticLib,
  LinkerOptions manualOption,
  LinkInput linkInput,
  LinkOutputBuilder linkOutputBuilder,
  Architecture targetArchitecture,
  OS targetOS,
) async {
  await CLinker.library(
    name: 'mylibname',
    assetName: '',
    sources: [staticLib.toFilePath()],
    linkerOptions: manualOption,
  ).run(input: linkInput, output: linkOutputBuilder, logger: logger);

  final linkOutput = linkOutputBuilder.build();
  final asset = linkOutput.assets.code.first;

  await expectMachineArchitecture(asset.file!, targetArchitecture, targetOS);

  return await readSymbols(asset, targetOS);
}
