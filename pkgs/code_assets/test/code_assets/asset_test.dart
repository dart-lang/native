// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:code_assets/code_assets.dart';
import 'package:collection/collection.dart';
import 'package:hooks/hooks.dart';
import 'package:test/test.dart';

void main() {
  final fooUri = Uri.file('path/to/libfoo.so');
  final foo3Uri = Uri(path: 'libfoo3.so');
  final barUri = Uri(path: 'path/to/libbar.a');
  final blaUri = Uri(path: 'path/with spaces/bla.dll');
  final nativeCodeAssets = [
    CodeAsset(
      package: 'my_package',
      name: 'foo',
      file: fooUri,
      linkMode: DynamicLoadingBundled(),
    ),
    CodeAsset(
      package: 'my_package',
      name: 'foo3',
      linkMode: DynamicLoadingSystem(foo3Uri),
    ),
    CodeAsset(
      package: 'my_package',
      name: 'foo4',
      linkMode: LookupInExecutable(),
    ),
    CodeAsset(package: 'my_package', name: 'foo5', linkMode: LookupInProcess()),
    CodeAsset(
      package: 'my_package',
      name: 'bar',
      file: barUri,
      linkMode: StaticLinking(),
    ),
    CodeAsset(
      package: 'my_package',
      name: 'bla',
      file: blaUri,
      linkMode: DynamicLoadingBundled(),
    ),
  ];

  final assets = [for (final asset in nativeCodeAssets) asset.encode()];

  final assetsJsonEncoding = [
    {
      'type': 'code_assets/code',
      'encoding': {
        'file': fooUri.toFilePath(),
        'id': 'package:my_package/foo',
        'link_mode': {'type': 'dynamic_loading_bundle'},
      },
    },
    {
      'type': 'code_assets/code',
      'encoding': {
        'id': 'package:my_package/foo3',
        'link_mode': {
          'type': 'dynamic_loading_system',
          'uri': foo3Uri.toFilePath(),
        },
      },
    },
    {
      'type': 'code_assets/code',
      'encoding': {
        'id': 'package:my_package/foo4',
        'link_mode': {'type': 'dynamic_loading_executable'},
      },
    },
    {
      'type': 'code_assets/code',
      'encoding': {
        'id': 'package:my_package/foo5',
        'link_mode': {'type': 'dynamic_loading_process'},
      },
    },
    {
      'type': 'code_assets/code',
      'encoding': {
        'file': barUri.toFilePath(),
        'id': 'package:my_package/bar',
        'link_mode': {'type': 'static'},
      },
    },
    {
      'type': 'code_assets/code',
      'encoding': {
        'file': blaUri.toFilePath(),
        'id': 'package:my_package/bla',
        'link_mode': {'type': 'dynamic_loading_bundle'},
      },
    },
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
      throwsA(
        predicate(
          (e) =>
              e is FormatException &&
              e.message.contains('The link mode "wrong" is not known'),
        ),
      ),
    );
  });

  test('Asset hashCode copyWith', () async {
    final asset = nativeCodeAssets.first;
    final asset2 = asset.copyWith(id: 'foo321');
    expect(asset.hashCode != asset2.hashCode, true);

    final asset3 = asset.copyWith();
    expect(asset.hashCode, asset3.hashCode);
  });

  test('List<Asset> hashCode', () async {
    final assets2 = nativeCodeAssets.take(3).toList();
    const equality = ListEquality<CodeAsset>();
    expect(equality.hash(nativeCodeAssets) != equality.hash(assets2), true);
  });

  test('Asset toString', () async {
    assets.toString();
  });

  test('toString', () {
    StaticLinking().toString();
    DynamicLoadingBundled().toString();
    DynamicLoadingSystem(Uri.file('foo.so')).toString();
    LookupInProcess().toString();
    LookupInExecutable().toString();
  });

  test('OS current', () async {
    final current = OS.current;
    expect(current.toString(), Abi.current().toString().split('_').first);
  });

  test('Architecture current', () async {
    final current = Architecture.current;
    expect(current.toString(), Abi.current().toString().split('_')[1]);
  });
}
