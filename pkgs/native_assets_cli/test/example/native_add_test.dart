// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

import '../helpers.dart';

void main() async {
  late Uri tempUri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  test('native_add build', timeout: Timeout.factor(2), () async {
    final testTempUri = tempUri.resolve('test1/');
    await Directory.fromUri(testTempUri).create();
    final testPackageUri = packageUri.resolve('example/native_add/');
    final dartUri = Uri.file(Platform.resolvedExecutable);

    final processResult = await Process.run(
      dartUri.toFilePath(),
      [
        'build.dart',
        '-Dout_dir=${tempUri.toFilePath()}',
        '-Dpackage_root=${testPackageUri.toFilePath()}',
        '-Dtarget=${Target.current}',
        '-Dlink_mode_preference=dynamic',
        if (cc != null) '-Dcc=${cc!.toFilePath()}',
        if (toolchainEnvScript != null)
          '-D${BuildConfig.toolchainEnvScriptConfigKey}='
              '${toolchainEnvScript!.toFilePath()}',
        if (toolchainEnvScriptArgs != null)
          '-D${BuildConfig.toolchainEnvScriptArgsConfigKey}='
              '${toolchainEnvScriptArgs!.join(' ')}',
        '-Dversion=1.0.0',
      ],
      workingDirectory: testPackageUri.toFilePath(),
    );
    if (processResult.exitCode != 0) {
      print(processResult.stdout);
      print(processResult.stderr);
      print(processResult.exitCode);
    }
    expect(processResult.exitCode, 0);

    final buildOutputUri = tempUri.resolve('build_output.yaml');
    final buildOutput = BuildOutput.fromYamlString(
        await File.fromUri(buildOutputUri).readAsString());
    final assets = buildOutput.assets;
    expect(assets.length, 1);
    final dependencies = buildOutput.dependencies;
    expect(await assets.allExist(), true);
    expect(
      dependencies.dependencies,
      [
        testPackageUri.resolve('src/native_add.c'),
        testPackageUri.resolve('build.dart'),
      ],
    );
  });
}
