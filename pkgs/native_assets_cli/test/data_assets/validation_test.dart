// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/data_assets_builder.dart';
import 'package:test/test.dart';

void main() {
  late Uri tempUri;
  late Uri outDirUri;
  late Uri outDirSharedUri;
  late String packageName;
  late Uri packageRootUri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
    outDirUri = tempUri.resolve('out/');
    await Directory.fromUri(outDirUri).create();
    outDirSharedUri = tempUri.resolve('out_shared/');
    await Directory.fromUri(outDirSharedUri).create();
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    await Directory.fromUri(packageRootUri).create();
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  BuildConfig makeDataBuildConfig() {
    final configBuilder = BuildConfigBuilder()
      ..setupHookConfig(
          packageName: packageName,
          packageRoot: tempUri,
          targetOS: OS.iOS,
          buildMode: BuildMode.release,
          buildAssetTypes: [DataAsset.type])
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
      )
      ..setupBuildRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
      );
    return BuildConfig(configBuilder.json);
  }

  test('file exists', () async {
    final config = makeDataBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.txt'));
    outputBuilder.dataAssets.add(DataAsset(
      package: config.packageName,
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors = await validateDataAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('which does not exist')),
    );
  });

  test('asset id in wrong package', () async {
    final config = makeDataBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.dataAssets.add(DataAsset(
      package: 'different_package',
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors = await validateDataAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('Data asset must have package name my_package')),
    );
  });

  test('duplicate asset id', () async {
    final config = makeDataBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.dataAssets.addAll([
      DataAsset(
        package: config.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
      DataAsset(
        package: config.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    ]);
    final errors = await validateDataAssetBuildOutput(
        config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('More than one')),
    );
  });
}
