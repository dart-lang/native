// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
library;

import 'dart:ffi';
import 'dart:io';

import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  if (!Platform.isMacOS) {
    // Avoid needing status files on Dart SDK CI.
    return;
  }

  test('CBuilder compile objective c', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final addMUri =
        packageUri.resolve('test/cbuilder/testfiles/add_objective_c/src/add.m');
    if (!await File.fromUri(addMUri).exists()) {
      throw Exception('Run the test from the root directory.');
    }
    const name = 'add_objective_c';

    final logMessages = <String>[];
    final logger = createCapturingLogger(logMessages);

    final buildConfigBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        supportedAssetTypes: [CodeAsset.type],
        packageName: name,
        packageRoot: tempUri,
        targetOS: OS.current,
        buildMode: BuildMode.release,
      )
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
      )
      ..setupCodeConfig(
        targetArchitecture: Architecture.current,
        linkModePreference: LinkModePreference.dynamic,
        cCompilerConfig: cCompiler,
      );
    buildConfigBuilder.setupBuildRunConfig(
      outputDirectory: tempUri,
      outputDirectoryShared: tempUri2,
    );

    final buildConfig = BuildConfig(buildConfigBuilder.json);
    final buildOutput = BuildOutputBuilder();

    final cbuilder = CBuilder.library(
      name: name,
      assetName: name,
      sources: [addMUri.toFilePath()],
      language: Language.objectiveC,
    );
    await cbuilder.run(
      config: buildConfig,
      output: buildOutput,
      logger: logger,
    );

    final dylibUri = tempUri.resolve(OS.current.dylibFileName(name));
    expect(await File.fromUri(dylibUri).exists(), true);
    final dylib = openDynamicLibraryForTest(dylibUri.toFilePath());
    final add = dylib.lookupFunction<Int32 Function(Int32, Int32),
        int Function(int, int)>('add');
    expect(add(1, 2), 3);
  });
}
