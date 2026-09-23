// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() async {
  test('DataAsset toJson', () {
    expect(
      DataAsset(
        package: 'my_package',
        name: 'name',
        file: Uri.file('not there'),
      ).encode().toJson(),
      {
        'type': 'data_assets/data',
        'encoding': {
          'file': 'not there',
          'name': 'name',
          'package': 'my_package',
        },
      },
    );
  });

  test('DataAsset fromJson', () {
    final encodedAsset = EncodedAsset.fromJson({
      'type': 'data_assets/data',
      'encoding': {
        'file': 'not there',
        'name': 'name',
        'package': 'my_package',
      },
    });
    expect(encodedAsset.isDataAsset, isTrue);
    expect(
      DataAsset.fromEncoded(encodedAsset),
      DataAsset(
        package: 'my_package',
        name: 'name',
        file: Uri.file('not there'),
      ),
    );
    expect(
      DataAsset.fromEncoded(encodedAsset).hashCode,
      DataAsset(
        package: 'my_package',
        name: 'name',
        file: Uri.file('not there'),
      ).hashCode,
    );
  });

  test('Build and Link input/output data asset extensions', () {
    final tempDir = Directory.systemTemp.createTempSync();
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final tempUri = tempDir.uri;

    final asset1 = DataAsset(
      package: 'my_package',
      name: 'asset1',
      file: tempUri.resolve('asset1'),
    );
    final asset2 = DataAsset(
      package: 'my_package',
      name: 'asset2',
      file: tempUri.resolve('asset2'),
    );

    final buildInputBuilder = BuildInputBuilder()
      ..setupShared(
        packageName: 'my_package',
        packageRoot: tempUri,
        outputFile: tempUri.resolve('output.json'),
        outputDirectoryShared: tempUri.resolve('shared/'),
      )
      ..config.setupBuild(linkingEnabled: false)
      ..addExtension(DataAssetsExtension());

    final buildInput = buildInputBuilder.build();
    expect(buildInput.config.buildDataAssets, isTrue);

    final buildOutputBuilder = BuildOutputBuilder();
    buildOutputBuilder.assets.data.add(asset1);
    buildOutputBuilder.assets.data.addAll([asset2]);
    final buildOutput = BuildOutput(buildOutputBuilder.json);
    expect(buildOutput.assets.data, [asset1, asset2]);

    final linkInputBuilder = LinkInputBuilder()
      ..setupShared(
        packageName: 'my_package',
        packageRoot: tempUri,
        outputFile: tempUri.resolve('link_output.json'),
        outputDirectoryShared: tempUri.resolve('shared/'),
      )
      ..setupLink(
        assets: buildOutput.assets.encodedAssets,
        recordedUsesFile: null,
        assetsFromLinking: [],
      )
      ..addExtension(DataAssetsExtension());

    final linkInput = linkInputBuilder.build();
    expect(linkInput.assets.data, [asset1, asset2]);

    final linkOutputBuilder = LinkOutputBuilder();
    linkOutputBuilder.assets.data.add(asset1);
    linkOutputBuilder.assets.data.addAll([asset2]);
    final linkOutput = LinkOutput(linkOutputBuilder.json);
    expect(linkOutput.assets.data, [asset1, asset2]);
  });
}
