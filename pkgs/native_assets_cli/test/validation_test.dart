// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
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
        targetOS: OS.iOS,
        buildMode: BuildMode.release,
        supportedAssetTypes: ['my-asset-type'],
      )
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

  LinkConfig makeCodeLinkConfig() {
    final configBuilder = LinkConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: tempUri,
        targetOS: OS.iOS,
        buildMode: BuildMode.release,
        supportedAssetTypes: [CodeAsset.type],
      )
      ..setupLinkConfig(assets: [])
      ..setupLinkRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outDirSharedUri,
        recordedUsesFile: null,
      )
      ..setupCodeConfig(
        targetArchitecture: Architecture.arm64,
        targetIOSSdk: IOSSdk.iPhoneOS,
        linkModePreference: LinkModePreference.dynamic,
      );
    return LinkConfig(configBuilder.json);
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

  test('link hook validation', () async {
    final config = makeCodeLinkConfig();
    final outputBuilder = LinkOutputBuilder();
    final assetFile = File.fromUri(outDirUri.resolve('foo.dylib'));
    await assetFile.writeAsBytes([1, 2, 3]);
    outputBuilder.dataAssets.add(DataAsset(
      package: config.packageName,
      name: 'foo.txt',
      file: assetFile.uri,
    ));
    final errors =
        await validateLinkOutput(config, LinkOutput(outputBuilder.json));
    expect(
      errors,
      contains(contains('"data" is not a supported asset type')),
    );
  });
}
