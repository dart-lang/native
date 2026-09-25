// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:native_toolchain_c/src/cbuilder/logger.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('createDefaultLogger logs info and warning records', () {
    final defaultLogger = createDefaultLogger();
    defaultLogger.info('test info message');
    defaultLogger.warning(
      'test warning message',
      Exception('test exception'),
      StackTrace.current,
    );
  });

  test('CLibrary build and link with linkingEnabled: true', () async {
    final tempUri = await tempDirForTest();
    final tempUriShared = await tempDirForTest();
    final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');

    final cLibrary = CLibrary(
      name: 'add',
      assetName: 'add.dart',
      sources: [addCUri.toFilePath()],
    );

    final buildInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: 'testpackage',
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: tempUriShared,
      )
      ..config.setupBuild(linkingEnabled: true)
      ..addExtension(
        CodeAssetExtension(
          targetOS: OS.current,
          targetArchitecture: Architecture.current,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
          macOS: OS.current == OS.macOS
              ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
              : null,
        ),
      );

    final buildInput = buildInputBuilder.build();
    final buildOutputBuilder = BuildOutputBuilder();

    await cLibrary.build(
      input: buildInput,
      output: buildOutputBuilder,
      logger: logger,
      defines: {'EXTRA_DEFINE': '1'},
    );

    final buildOutput = BuildOutput(buildOutputBuilder.json);
    final buildEncodedAssets =
        buildOutput.assets.encodedAssetsForLinking['testpackage']!;
    expect(buildEncodedAssets, hasLength(1));
    expect(
      CodeAsset.fromEncoded(buildEncodedAssets.first).linkMode,
      StaticLinking(),
    );

    final linkInputBuilder = LinkInputBuilder()
      ..setupShared(
        packageName: 'testpackage',
        packageRoot: tempUri,
        outputFile: tempUri.resolve('link_output.json'),
        outputDirectoryShared: tempUriShared,
      )
      ..setupLink(
        assets: buildEncodedAssets,
        recordedUsesFile: null,
        assetsFromLinking: [],
      )
      ..addExtension(
        CodeAssetExtension(
          targetOS: OS.current,
          targetArchitecture: Architecture.current,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
          macOS: OS.current == OS.macOS
              ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
              : null,
        ),
      );

    final linkInput = linkInputBuilder.build();
    final linkOutputBuilder = LinkOutputBuilder();

    await cLibrary.link(
      input: linkInput,
      output: linkOutputBuilder,
      logger: logger,
      linkerOptions: LinkerOptions.treeshake(symbolsToKeep: ['add']),
    );

    final linkOutput = LinkOutput(linkOutputBuilder.json);
    expect(linkOutput.assets.code, hasLength(1));
    expect(linkOutput.assets.code.first.linkMode, DynamicLoadingBundled());

    // Also test link without assetName filter
    final cLibraryNoAssetName = CLibrary(
      name: 'add',
      sources: [addCUri.toFilePath()],
    );
    final linkOutputBuilder2 = LinkOutputBuilder();
    await cLibraryNoAssetName.link(
      input: linkInput,
      output: linkOutputBuilder2,
      logger: logger,
    );
    expect(LinkOutput(linkOutputBuilder2.json).assets.code, isEmpty);
  });

  test('CLibrary build with linkingEnabled: false', () async {
    final tempUri = await tempDirForTest();
    final tempUriShared = await tempDirForTest();
    final addCUri = packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');

    final cLibrary = CLibrary(
      name: 'add',
      assetName: 'add.dart',
      sources: [addCUri.toFilePath()],
    );

    final buildInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: 'testpackage',
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: tempUriShared,
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(
        CodeAssetExtension(
          targetOS: OS.current,
          targetArchitecture: Architecture.current,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
          macOS: OS.current == OS.macOS
              ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
              : null,
        ),
      );

    final buildInput = buildInputBuilder.build();
    final buildOutputBuilder = BuildOutputBuilder();

    await cLibrary.build(
      input: buildInput,
      output: buildOutputBuilder,
      logger: logger,
    );

    final buildOutput = BuildOutput(buildOutputBuilder.json);
    expect(buildOutput.assets.code, hasLength(1));
    expect(buildOutput.assets.code.first.linkMode, DynamicLoadingBundled());
  });
}
