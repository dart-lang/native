// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

void main() {
  final fooUri = Uri.file('path/to/libfoo.so');
  final foo3Uri = Uri(path: 'libfoo3.so');
  final barUri = Uri(path: 'path/to/libbar.a');
  final blaUri = Uri(path: 'path/with spaces/bla.dll');
  final dataUri = Uri.file('path/to/data.txt');
  final data2Uri = Uri.file('path/to/data.json');
  final nativeCodeAssets = [
    CodeAsset(
      package: 'my_package',
      name: 'foo',
      file: fooUri,
      linkMode: DynamicLoadingBundled(),
      os: OS.android,
      architecture: Architecture.x64,
    ),
    CodeAsset(
      package: 'my_package',
      name: 'foo3',
      linkMode: DynamicLoadingSystem(foo3Uri),
      os: OS.android,
      architecture: Architecture.x64,
    ),
    CodeAsset(
      package: 'my_package',
      name: 'foo4',
      linkMode: LookupInExecutable(),
      os: OS.android,
      architecture: Architecture.x64,
    ),
    CodeAsset(
      package: 'my_package',
      name: 'foo5',
      linkMode: LookupInProcess(),
      os: OS.android,
      architecture: Architecture.x64,
    ),
    CodeAsset(
      package: 'my_package',
      name: 'bar',
      file: barUri,
      os: OS.linux,
      architecture: Architecture.arm64,
      linkMode: StaticLinking(),
    ),
    CodeAsset(
      package: 'my_package',
      name: 'bla',
      file: blaUri,
      linkMode: DynamicLoadingBundled(),
      os: OS.windows,
      architecture: Architecture.x64,
    ),
  ];
  final dataAssets = [
    DataAsset(
      name: 'my_data_asset',
      package: 'my_package',
      file: dataUri,
    ),
    DataAsset(
      name: 'my_data_asset2',
      package: 'my_package',
      file: data2Uri,
    ),
  ];
  final assets = [
    for (final asset in nativeCodeAssets) asset.encode(),
    for (final asset in dataAssets) asset.encode(),
  ];

  final assetsJsonEncoding = [
    {
      'architecture': 'x64',
      'file': fooUri.toFilePath(),
      'id': 'package:my_package/foo',
      'link_mode': {'type': 'dynamic_loading_bundle'},
      'os': 'android',
      'type': 'native_code'
    },
    {
      'architecture': 'x64',
      'id': 'package:my_package/foo3',
      'link_mode': {
        'type': 'dynamic_loading_system',
        'uri': foo3Uri.toFilePath()
      },
      'os': 'android',
      'type': 'native_code'
    },
    {
      'architecture': 'x64',
      'id': 'package:my_package/foo4',
      'link_mode': {'type': 'dynamic_loading_executable'},
      'os': 'android',
      'type': 'native_code'
    },
    {
      'architecture': 'x64',
      'id': 'package:my_package/foo5',
      'link_mode': {'type': 'dynamic_loading_process'},
      'os': 'android',
      'type': 'native_code'
    },
    {
      'architecture': 'arm64',
      'file': barUri.toFilePath(),
      'id': 'package:my_package/bar',
      'link_mode': {'type': 'static'},
      'os': 'linux',
      'type': 'native_code'
    },
    {
      'architecture': 'x64',
      'file': blaUri.toFilePath(),
      'id': 'package:my_package/bla',
      'link_mode': {'type': 'dynamic_loading_bundle'},
      'os': 'windows',
      'type': 'native_code'
    },
    {
      'name': 'my_data_asset',
      'package': 'my_package',
      'file': Uri.file('path/to/data.txt').toFilePath(),
      'type': 'data'
    },
    {
      'name': 'my_data_asset2',
      'package': 'my_package',
      'file': Uri.file('path/to/data.json').toFilePath(),
      'type': 'data'
    }
  ];

  test('asset json', () {
    final json = [for (final item in assets) item.toJson()];
    expect(json, assetsJsonEncoding);
    final assets2 = [for (final e in json) EncodedAsset.fromJson(e)];
    expect(assets, assets2);
  });

  test('AssetPath factory', () async {
    expect(
      () => LinkMode.fromJson({'type': 'wrong'}),
      throwsA(predicate(
        (e) =>
            e is FormatException &&
            e.message.contains('The link mode "wrong" is not known'),
      )),
    );
  });

  test('Asset hashCode copyWith', () async {
    final asset = nativeCodeAssets.first;
    final asset2 = asset.copyWith(id: 'foo321');
    expect(asset.hashCode != asset2.hashCode, true);

    final asset3 = asset.copyWith();
    expect(asset.hashCode, asset3.hashCode);

    expect(dataAssets[0].hashCode, isNot(dataAssets[1].hashCode));
  });

  test('List<Asset> hashCode', () async {
    final assets2 = nativeCodeAssets.take(3).toList();
    const equality = ListEquality<CodeAsset>();
    expect(equality.hash(nativeCodeAssets) != equality.hash(assets2), true);
  });

  test('Asset toString', () async {
    assets.toString();
  });
}
