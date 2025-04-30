// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  final dataUri = Uri.file('path/to/data.txt');
  final data2Uri = Uri.file('path/to/data.json');

  final dataAssets = [
    DataAsset(name: 'my_data_asset', package: 'my_package', file: dataUri),
    DataAsset(name: 'my_data_asset2', package: 'my_package', file: data2Uri),
  ];
  final assets = [for (final asset in dataAssets) asset.encode()];

  final assetsJsonEncoding = [
    {
      'type': 'data_assets/data',
      'encoding': {
        'name': 'my_data_asset',
        'package': 'my_package',
        'file': Uri.file('path/to/data.txt').toFilePath(),
      },
    },
    {
      'type': 'data_assets/data',
      'encoding': {
        'name': 'my_data_asset2',
        'package': 'my_package',
        'file': Uri.file('path/to/data.json').toFilePath(),
      },
    },
  ];

  test('asset json', () {
    final json = [for (final item in assets) item.toJson()];
    expect(json, assetsJsonEncoding);
    final assets2 = [for (final e in json) EncodedAsset.fromJson(e)];
    expect(assets, assets2);
  });

  test('Asset toString', () async {
    assets.toString();
  });
}
