// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({'mac-os': Timeout.factor(2), 'windows': Timeout.factor(10)})
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:collection/collection.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() {
  test('build failure', () async {
    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final addCOriginalUri = packageUri.resolve(
      'test/cbuilder/testfiles/add/src/add.c',
    );
    final addCUri = tempUri.resolve('add.c');
    final addCOriginalContents = await File.fromUri(
      addCOriginalUri,
    ).readAsString();
    final addCBrokenContents = addCOriginalContents.replaceAll(
      'int32_t a, int32_t b',
      'int64_t blabla',
    );
    await File.fromUri(addCUri).writeAsString(addCBrokenContents);
    const name = 'add';

    final targetOS = OS.current;
    final buildInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: name,
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: tempUri2,
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(
        CodeAssetExtension(
          targetOS: targetOS,
          macOS: targetOS == OS.macOS
              ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
              : null,
          targetArchitecture: Architecture.current,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );

    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    final cbuilder = CBuilder.library(
      sources: [addCUri.toFilePath()],
      name: name,
      assetName: name,
      buildMode: BuildMode.release,
    );
    expect(
      () =>
          cbuilder.run(input: buildInput, output: buildOutput, logger: logger),
      throwsException,
    );
  });

  test('CL build failure include error output', () async {
    if (!Platform.isWindows) {
      // Avoid needing status files on Dart SDK CI.
      return;
    }

    final tempUri = await tempDirForTest();
    final tempUri2 = await tempDirForTest();
    final source = packageUri.resolve(
      'test/cbuilder/testfiles/build_failure/cl.c',
    );
    const name = 'cl';

    final buildInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: name,
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: tempUri2,
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(
        CodeAssetExtension(
          targetOS: OS.windows,
          targetArchitecture: Architecture.current,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );

    final buildInput = buildInputBuilder.build();
    final buildOutput = BuildOutputBuilder();

    final logs = <LogRecord>[];
    final logger = createCapturingRecordLogger(logs);
    final cbuilder = CBuilder.library(
      sources: [source.toFilePath()],
      name: name,
      assetName: name,
      includes: [],
      buildMode: BuildMode.release,
    );
    await expectLater(
      cbuilder.run(input: buildInput, output: buildOutput, logger: logger),
      throwsException,
    );

    // Note: don't check the entire message as CL output is based on user
    //       locale.
    final line = logs.firstWhereOrNull(
      (log) =>
          log.level == Level.INFO && log.message.contains('fatal error C1070'),
    );
    expect(line != null, true);
  });
}
