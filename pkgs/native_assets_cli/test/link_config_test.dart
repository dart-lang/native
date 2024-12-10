// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_builder.dart';
import 'package:native_assets_cli/src/config.dart' show latestVersion;
import 'package:test/test.dart';

void main() async {
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late List<EncodedAsset> assets;

  setUp(() async {
    final tempUri = Directory.systemTemp.uri;
    outDirUri = tempUri.resolve('out1/');
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    assets = [
      for (int i = 0; i < 3; i++)
        EncodedAsset('my-asset-type', {'a-$i': 'v-$i'})
    ];
  });

  test('LinkConfigBuilder->JSON->LinkConfig', () {
    final configBuilder = LinkConfigBuilder()
      ..setupHookConfig(
        packageName: packageName,
        packageRoot: packageRootUri,
        targetOS: OS.android,
        buildAssetTypes: ['asset-type-1', 'asset-type-2'],
      )
      ..setupLinkConfig(assets: assets)
      ..setupLinkRunConfig(
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
        recordedUsesFile: null,
      );
    final config = LinkConfig(configBuilder.json);

    final expectedConfigJson = {
      'assets': [for (final asset in assets) asset.toJson()],
      'build_asset_types': ['asset-type-1', 'asset-type-2'],
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'out_dir': outDirUri.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'supported_asset_types': ['asset-type-1', 'asset-type-2'],
      'target_os': 'android',
      'version': latestVersion.toString(),
    };
    expect(config.json, expectedConfigJson);
    expect(json.decode(config.toString()), expectedConfigJson);

    expect(config.outputDirectory, outDirUri);
    expect(config.outputDirectoryShared, outputDirectoryShared);

    expect(config.packageName, packageName);
    expect(config.packageRoot, packageRootUri);
    expect(config.targetOS, OS.android);
    expect(config.buildAssetTypes, ['asset-type-1', 'asset-type-2']);
    expect(config.encodedAssets, assets);
  });

  group('LinkConfig FormatExceptions', () {
    for (final version in ['9001.0.0', '0.0.1']) {
      test('LinkConfig version $version', () {
        final outDir = outDirUri;
        final config = {
          'link_mode_preference': 'prefer-static',
          'out_dir': outDir.toFilePath(),
          'out_dir_shared': outputDirectoryShared.toFilePath(),
          'package_root': packageRootUri.toFilePath(),
          'target_os': 'linux',
          'version': version,
          'package_name': packageName,
          'build_asset_types': ['my-asset-type'],
          'dry_run': true,
        };
        expect(
          () => LinkConfig(config),
          throwsA(predicate(
            (e) =>
                e is FormatException &&
                e.message.contains(version) &&
                e.message.contains(latestVersion.toString()),
          )),
        );
      });
    }
    test('LinkConfig FormatExceptions', () {
      expect(
        () => LinkConfig({}),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains('No value was provided for required key: '),
        )),
      );
      expect(
        () => LinkConfig({
          'version': latestVersion.toString(),
          'build_asset_types': ['my-asset-type'],
          'package_name': packageName,
          'package_root': packageRootUri.toFilePath(),
          'target_os': 'android',
          'assets': <String>[],
        }),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                'No value was provided for required key: out_dir',
              ),
        )),
      );
      expect(
        () => LinkConfig({
          'version': latestVersion.toString(),
          'build_asset_types': ['my-asset-type'],
          'out_dir': outDirUri.toFilePath(),
          'out_dir_shared': outputDirectoryShared.toFilePath(),
          'package_name': packageName,
          'package_root': packageRootUri.toFilePath(),
          'target_os': 'android',
          'assets': 'astring',
        }),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(
                "Unexpected value 'astring' for key '.assets' in config file. "
                'Expected a List<Object?>?.',
              ),
        )),
      );
    });
  });
}
