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

  test('LinkInputBuilder->JSON->LinkInput', () {
    final inputBuilder = LinkInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: packageRootUri,
        outputDirectory: outDirUri,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..config.setupShared(buildAssetTypes: ['asset-type-1', 'asset-type-2'])
      ..setupLink(
        assets: assets,
        recordedUsesFile: null,
      );
    final input = LinkInput(inputBuilder.json);

    final expectedInputJson = {
      'assets': [for (final asset in assets) asset.toJson()],
      'build_asset_types': ['asset-type-1', 'asset-type-2'],
      'build_mode': 'release',
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'out_dir': outDirUri.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'supported_asset_types': ['asset-type-1', 'asset-type-2'],
      'version': latestVersion.toString(),
    };
    expect(input.json, expectedInputJson);
    expect(json.decode(input.toString()), expectedInputJson);

    expect(input.outputDirectory, outDirUri);
    expect(input.outputDirectoryShared, outputDirectoryShared);

    expect(input.packageName, packageName);
    expect(input.packageRoot, packageRootUri);
    expect(input.config.buildAssetTypes, ['asset-type-1', 'asset-type-2']);
    expect(input.assets.encodedAssets, assets);
  });

  group('LinkInput FormatExceptions', () {
    for (final version in ['9001.0.0', '0.0.1']) {
      test('LinkInput version $version', () {
        final outDir = outDirUri;
        final input = {
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
          () => LinkInput(input),
          throwsA(predicate(
            (e) =>
                e is FormatException &&
                e.message.contains(version) &&
                e.message.contains(latestVersion.toString()),
          )),
        );
      });
    }
    test('LinkInput FormatExceptions', () {
      expect(
        () => LinkInput({}),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains('No value was provided for required key: '),
        )),
      );
      expect(
        () => LinkInput({
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
        () => LinkInput({
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
                "Unexpected value 'astring' for key '.assets' in input file. "
                'Expected a List<Object?>?.',
              ),
        )),
      );
    });
  });
}
