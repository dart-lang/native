// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_builder.dart';
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

  BuildConfig makeBuildConfig() {
    final configBuilder = BuildConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: tempUri,
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
      )
      ..addBuildAssetType('my-asset-type')
      ..setupBuildConfig(
        linkingEnabled: false,
        dryRun: false,
      );
    return BuildConfig(configBuilder.json);
  }

  test('linking not enabled', () async {
    final config = makeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.addEncodedAsset(
      EncodedAsset('my-asset-type', {}),
      linkInPackage: 'bar',
    );
    final errors =
        await validateBuildOutput(config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('linkingEnabled is false')),
    );
  });

  test('supported asset type', () async {
    final config = makeBuildConfig();
    final outputBuilder = BuildOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.addEncodedAsset(EncodedAsset('baz', {}));
    final errors =
        await validateBuildOutput(config, BuildOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('"baz" is not a supported asset type')),
    );
  });
}
