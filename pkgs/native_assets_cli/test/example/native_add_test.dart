// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() async {
  late Uri tempUri;
  final packageUri = Directory.current.uri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  test('native_add build', () async {
    final testTempUri = tempUri.resolve('test1/');
    await Directory.fromUri(testTempUri).create();
    final testPackageUri = packageUri.resolve('example/native_add/');
    final dartUri = Uri.file(Platform.resolvedExecutable);

    final processResult = await Process.run(
      dartUri.path,
      [
        'bin/native.dart',
        '-Dout_dir=${tempUri.path}',
        '-Dpackage_root=${testPackageUri.path}',
        '-Dtarget=linux_x64',
        '-Dpackaging=dynamic',
      ],
      workingDirectory: testPackageUri.path,
    );
    if (processResult.exitCode != 0) {
      print(processResult.stdout);
      print(processResult.stderr);
      print(processResult.exitCode);
    }
    expect(processResult.exitCode, 0);

    final dependenciesUri = tempUri.resolve('dependencies.yaml');
    final dependencies = Dependencies.fromYamlString(
        await File.fromUri(dependenciesUri).readAsString());
    expect(
      dependencies.dependencies,
      [
        testPackageUri.resolve('src/native_add.c'),
        testPackageUri.resolve('bin/native.dart'),
      ],
    );

    final builtInfoUri = tempUri.resolve('built_info.yaml');
    final builtInfo = BuiltInfo.fromYamlString(
        await File.fromUri(builtInfoUri).readAsString());
    final assets = builtInfo.assets;
    expect(assets.length, 1);
    for (final asset in assets) {
      final assetPath = asset.path as AssetAbsolutePath;
      final libUri = assetPath.uri;
      expect(await File.fromUri(libUri).exists(), true);
    }
  });
}
