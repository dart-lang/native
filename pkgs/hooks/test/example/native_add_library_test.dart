// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@OnPlatform({'mac-os': Timeout.factor(2), 'windows': Timeout.factor(10)})
library;

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  late Uri tempUri;
  const name = 'native_add_library';

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp('hooks example temp '))
        .uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  test('native_add build', () async {
    final buildOutputUri = tempUri.resolve('build_output.json');
    final testTempUri = tempUri.resolve('test1/');
    await Directory.fromUri(testTempUri).create();
    final outputDirectory = tempUri.resolve('out/');
    await Directory.fromUri(outputDirectory).create();
    final outputDirectoryShared = tempUri.resolve('out_shared/');
    await Directory.fromUri(outputDirectoryShared).create();
    final testPackageUri = packageUri.resolve('example/build/$name/');
    final dartUri = Uri.file(Platform.resolvedExecutable);

    final targetOS = OS.current;
    final inputBuilder = BuildInputBuilder()
      ..setupShared(
        packageRoot: testPackageUri,
        packageName: name,
        outputFile: buildOutputUri,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(
        CodeAssetExtension(
          targetOS: OS.current,
          macOS: targetOS == OS.macOS
              ? MacOSCodeConfig(targetVersion: defaultMacOSVersion)
              : null,
          targetArchitecture: Architecture.current,
          linkModePreference: LinkModePreference.dynamic,
          cCompiler: cCompiler,
        ),
      );

    final buildInputUri = testTempUri.resolve('build_input.json');
    await File.fromUri(
      buildInputUri,
    ).writeAsString(jsonEncode(inputBuilder.json));

    final processResult = await Process.run(dartUri.toFilePath(), [
      'hook/build.dart',
      '--config=${buildInputUri.toFilePath()}',
    ], workingDirectory: testPackageUri.toFilePath());
    if (processResult.exitCode != 0) {
      print(processResult.stdout);
      print(processResult.stderr);
      print(processResult.exitCode);
    }
    expect(processResult.exitCode, 0);

    final buildOutput = BuildOutput(
      json.decode(await File.fromUri(buildOutputUri).readAsString())
          as Map<String, Object?>,
    );
    final assets = buildOutput.assets.encodedAssets;
    final dependencies = buildOutput.dependencies;
    expect(assets.length, 1);
    expect(await assets.allExist(), true);
    expect(dependencies, [testPackageUri.resolve('src/$name.c')]);
  });
}
