// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({
  'mac-os': Timeout.factor(2),
  'windows': Timeout.factor(10),
})
library;

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('build failure', () async {
    final tempUri = await tempDirForTest();
    final addCOriginalUri =
        packageUri.resolve('test/cbuilder/testfiles/add/src/add.c');
    final addCUri = tempUri.resolve('add.c');
    final addCOriginalContents =
        await File.fromUri(addCOriginalUri).readAsString();
    final addCBrokenContents = addCOriginalContents.replaceAll(
        'int32_t a, int32_t b', 'int64_t blabla');
    await File.fromUri(addCUri).writeAsString(addCBrokenContents);
    const name = 'add';

    final buildConfig = BuildConfig.build(
      outputDirectory: tempUri,
      packageName: name,
      packageRoot: tempUri,
      targetArchitecture: Architecture.current,
      targetOS: OS.current,
      linkModePreference: LinkModePreference.dynamic,
      buildMode: BuildMode.release,
      cCompiler: CCompilerConfig(
        compiler: cc,
        envScript: envScript,
        envScriptArgs: envScriptArgs,
      ),
    );
    final buildOutput = BuildOutput();

    final cbuilder = CBuilder.library(
      sources: [addCUri.toFilePath()],
      name: name,
      assetName: name,
      dartBuildFiles: ['hook/build.dart'],
    );
    expect(
      () => cbuilder.run(
        buildConfig: buildConfig,
        buildOutput: buildOutput,
        logger: logger,
      ),
      throwsException,
    );
  });
}
