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

  BuildInput makeDataBuildInput() {
    final inputBuilder =
        BuildInputBuilder()
          ..setupShared(
            packageName: packageName,
            packageRoot: tempUri,
            outputFile: tempUri.resolve('output.json'),
            outputDirectory: outDirUri,
            outputDirectoryShared: outDirSharedUri,
          )
          ..config.setupBuild(linkingEnabled: false)
          ..config.setupShared(buildAssetTypes: [DataAsset.type]);
    return BuildInput(inputBuilder.json);
  }

  test('file exists', () async {
    final input = makeDataBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.txt'));
    outputBuilder.assets.data.add(
      DataAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    );
    final errors = await validateDataAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(errors, contains(contains('does not exist')));
  });

  test('asset id in wrong package', () async {
    final input = makeDataBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.data.add(
      DataAsset(
        package: 'different_package',
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    );
    final errors = await validateDataAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(
      errors,
      contains(contains('Data asset must have package name my_package')),
    );
  });

  test('duplicate asset id', () async {
    final input = makeDataBuildInput();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.assets.data.addAll([
      DataAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
      DataAsset(
        package: input.packageName,
        name: 'foo.txt',
        file: assetFile.uri,
      ),
    ]);
    final errors = await validateDataAssetBuildOutput(
      input,
      BuildOutput(outputBuilder.json),
    );
    expect(errors, contains(contains('More than one')));
  });
}
