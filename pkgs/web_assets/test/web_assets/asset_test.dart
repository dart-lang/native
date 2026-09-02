// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:test/test.dart';
import 'package:web_assets/web_assets.dart';

void main() {
  final dataUri = Uri.file('path/to/data.txt');
  final data2Uri = Uri.file('path/to/data.json');

  final dataAssets = [
    WebAsset(name: 'my_web_asset', package: 'my_package', file: dataUri),
    WebAsset(name: 'my_web_asset2', package: 'my_package', file: data2Uri),
  ];
  final assets = [for (final asset in dataAssets) asset.encode()];

  final assetsJsonEncoding = [
    {
      'type': 'web_assets/web',
      'encoding': {
        'name': 'my_web_asset',
        'package': 'my_package',
        'file': Uri.file('path/to/data.txt').toFilePath(),
      },
    },
    {
      'type': 'web_assets/web',
      'encoding': {
        'name': 'my_web_asset2',
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
