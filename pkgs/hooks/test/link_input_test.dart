// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() async {
  late Uri outFile;
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late List<EncodedAsset> assets;
  late Map<String, Object?> inputJson;

  setUp(() async {
    final tempUri =
        (await Directory.systemTemp.createTemp('hooks link_input temp '))
            .uri;
    outFile = tempUri.resolve('output.json');
    outDirUri = tempUri.resolve('out1/');
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    assets = [
      for (int i = 0; i < 3; i++)
        EncodedAsset('my-asset-type', {'a-$i': 'v-$i'}),
    ];

    inputJson = {
      'assets': [for (final asset in assets) asset.toJson()],
      'config': {
        'build_asset_types': ['asset-type-1', 'asset-type-2'],
      },
      'assets_from_linking': [],
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'out_file': outFile.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
    };
  });

  test('LinkInputBuilder->JSON->LinkInput', () {
    final inputBuilder = LinkInputBuilder()
      ..setupShared(
        packageName: packageName,
        packageRoot: packageRootUri,
        outputFile: outFile,
        outputDirectoryShared: outputDirectoryShared,
      )
      ..config.addBuildAssetTypes(['asset-type-1', 'asset-type-2'])
      ..setupLink(
        assets: assets,
        recordedUsesFile: null,
        assetsFromLinking: [],
      );
    final input = inputBuilder.build();

    expect(input.json, inputJson);
    expect(json.decode(input.toString()), inputJson);

    // The output_directory is deprecated, the hook makes a directory inside the
    // shared output directory.
    expect(input.outputDirectory, isNot(outDirUri));

    expect(input.outputDirectoryShared, outputDirectoryShared);

    expect(input.packageName, packageName);
    expect(input.packageRoot, packageRootUri);
    expect(input.config.buildAssetTypes, ['asset-type-1', 'asset-type-2']);
    expect(input.assets.encodedAssets, assets);
  });

  group('LinkInput FormatExceptions', () {
    for (final version in ['9001.0.0', '0.0.1']) {
      test('LinkInput version $version', () {
        final input = inputJson;
        input['version'] = version;
        expect(() => LinkInput(input), isNot(throwsException));
      });
    }

    test('LinkInput FormatExceptions', () {
      final input = inputJson;
      input['assets'] = 'astring';
      expect(
        () => LinkInput(input),
        throwsA(
          predicate(
            (e) =>
                e is FormatException &&
                e.message.contains(
                  "Unexpected value 'astring' (String) for 'assets'. "
                  'Expected a List<Object?>?.',
                ),
          ),
        ),
      );
    });
  });
}
