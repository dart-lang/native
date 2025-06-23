// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() async {
  late Uri outFile;
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late Map<String, List<EncodedAsset>> assets;
  late Map<String, Object?> inputJson;

  setUp(() async {
    final tempUri = Directory.systemTemp.uri;
    outFile = tempUri.resolve('output.json');
    outDirUri = tempUri.resolve('out1/');
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    assets = {
      'my_package': [
        for (int i = 0; i < 3; i++)
          EncodedAsset('my-asset-type', {'a-$i': 'v-$i'}),
      ],
    };

    inputJson = {
      'assets': {
        'my_package': [
          {
            'encoding': {'a-0': 'v-0'},
            'type': 'my-asset-type',
          },
          {
            'encoding': {'a-1': 'v-1'},
            'type': 'my-asset-type',
          },
          {
            'encoding': {'a-2': 'v-2'},
            'type': 'my-asset-type',
          },
        ],
      },
      'config': {
        'build_asset_types': ['my-asset-type'],
        'linking_enabled': false,
      },
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'out_file': outFile.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
    };
  });

  test('BuildInputBuilder->JSON->BuildInput', () {
    final inputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: packageRootUri,
        outputFile: outFile,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..config.addBuildAssetTypes(['my-asset-type'])
      ..config.setupBuild(linkingEnabled: false)
      ..setupBuildInput(assets: assets);
    final input = inputBuilder.build();

    expect(input.json, inputJson);
    expect(json.decode(input.toString()), inputJson);

    // The output_directory is deprecated, the hook makes a directory inside the
    // shared output directory.
    expect(input.outputDirectory, isNot(outDirUri));

    expect(input.outputDirectoryShared, outputDirectoryShared);

    expect(input.packageName, packageName);
    expect(input.packageRoot, packageRootUri);
    expect(input.config.buildAssetTypes, ['my-asset-type']);

    expect(input.config.linkingEnabled, false);
    expect(input.assets.encodedAssets, assets);
  });

  group('BuildInput format issues', () {
    for (final version in ['9001.0.0', '0.0.1']) {
      test('BuildInput version $version', () {
        final input = inputJson;
        input['version'] = version;
        expect(() => BuildInput(input), isNot(throwsException));
      });
    }

    test('BuildInput FormatException config.build_asset_types', () {
      final input = inputJson;
      traverseJson<Map<String, Object?>>(input, [
        'config',
      ]).remove('build_asset_types');
      expect(
        () => BuildInput(input).config.buildAssetTypes,
        throwsA(
          predicate(
            (e) =>
                e is FormatException &&
                e.message.contains(
                  'No value was provided for '
                  "'config.build_asset_types'.",
                ),
          ),
        ),
      );
    });
  });
}
