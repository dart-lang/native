// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
library;

import 'dart:io';

import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('build failure', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final addCOriginalUri =
        packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
    final addCUri = tempUri.resolve('add.c');
    final addCOriginalContents =
        await File.fromUri(addCOriginalUri).readAsString();
    final addCBrokenContents = addCOriginalContents.replaceAll(
        'int32_t a, int32_t b', 'int64_t blabla');
    await File.fromUri(addCUri).writeAsString(addCBrokenContents);
    const name = 'add';

    final targetOS = OS.current;
    final buildInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: name,
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectory: tempUri,
        outputDirectoryShared: tempUri2,
      )
      ..config.setupBuild(
        linkingEnabled: false,
        dryRun: false,
      )
      ..config.setupShared(buildAssetTypes: [CodeAsset.type])
      ..config.setupCode(
        targetOS: targetOS,
        macOS: targetOS == OS.macOS
            ? MacOSConfig(targetVersion: defaultMacOSVersion)
            : null,
        targetArchitecture: Architecture.current,
        linkModePreference: LinkModePreference.dynamic,
        cCompiler: cCompiler,
      );

    final buildInput = BuildInput(buildInputBuilder.json);
    final buildOutput = BuildOutputBuilder();

    final cbuilder = CBuilder.library(
      sources: [addCUri.toFilePath()],
      name: name,
      assetName: name,
      buildMode: BuildMode.release,
    );
    expect(
      () => cbuilder.run(
        input: buildInput,
        output: buildOutput,
        logger: logger,
      ),
      throwsException,
    );
  });
}
