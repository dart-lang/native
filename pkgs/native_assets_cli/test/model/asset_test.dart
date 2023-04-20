// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  final assets = [
    Asset(
      name: 'foo',
      path: AssetAbsolutePath(Uri(path: 'path/to/libfoo.so')),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      name: 'foo2',
      path: AssetRelativePath(Uri(path: 'path/to/libfoo2.so')),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      name: 'foo3',
      path: AssetSystemPath(Uri(path: 'libfoo3.so')),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      name: 'foo4',
      path: AssetInExecutable(),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      name: 'foo5',
      path: AssetInProcess(),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      name: 'bar',
      path: AssetAbsolutePath(Uri(path: 'path/to/libbar.a')),
      target: Target.linuxArm64,
      linkMode: LinkMode.static,
    ),
    Asset(
      name: 'bla',
      path: AssetAbsolutePath(Uri(path: 'path/with spaces/bla.dll')),
      target: Target.windowsX64,
      linkMode: LinkMode.dynamic,
    ),
  ];

  const assetsYamlEncoding = '''- name: foo
  link_mode: dynamic
  path:
    path_type: absolute
    uri: path/to/libfoo.so
  target: android_x64
- name: foo2
  link_mode: dynamic
  path:
    path_type: relative
    uri: path/to/libfoo2.so
  target: android_x64
- name: foo3
  link_mode: dynamic
  path:
    path_type: system
    uri: libfoo3.so
  target: android_x64
- name: foo4
  link_mode: dynamic
  path:
    path_type: executable
  target: android_x64
- name: foo5
  link_mode: dynamic
  path:
    path_type: process
  target: android_x64
- name: bar
  link_mode: static
  path:
    path_type: absolute
    uri: path/to/libbar.a
  target: linux_arm64
- name: bla
  link_mode: dynamic
  path:
    path_type: absolute
    uri: path/with spaces/bla.dll
  target: windows_x64''';

  const assetsDartEncoding = '''format-version:
  - 1
  - 0
  - 0
native-assets:
  android_x64:
    foo:
      - absolute
      - path/to/libfoo.so
    foo2:
      - relative
      - path/to/libfoo2.so
    foo3:
      - system
      - libfoo3.so
    foo4:
      - executable
    foo5:
      - process
  linux_arm64:
    bar:
      - absolute
      - path/to/libbar.a
  windows_x64:
    bla:
      - absolute
      - path/with spaces/bla.dll''';

  test('asset yaml', () {
    final yaml = assets.toYamlString().replaceAll('\\', '/');
    expect(yaml, assetsYamlEncoding);
    final assets2 = Asset.listFromYamlString(yaml);
    expect(assets, assets2);
  });

  test('asset yaml', () async {
    final fileContents = assets.toNativeAssetsFile();
    expect(fileContents.replaceAll('\\', '/'), assetsDartEncoding);
  });

  test('AssetPath factory', () async {
    expect(() => AssetPath('wrong', null), throwsFormatException);
  });

  test('Asset hashCode copyWith', () async {
    final asset = assets.first;
    final asset2 = asset.copyWith(name: 'foo321');
    expect(asset.hashCode != asset2.hashCode, true);

    final asset3 = asset.copyWith();
    expect(asset.hashCode, asset3.hashCode);
  });

  test('List<Asset> hashCode', () async {
    final assets2 = assets.take(3).toList();
    final equality = ListEquality<Asset>();
    expect(equality.hash(assets) != equality.hash(assets2), true);
  });

  test('List<Asset> whereLinkMode', () async {
    final assets2 = assets.whereLinkMode(LinkMode.dynamic);
    expect(assets2.length, 6);
  });

  test('Asset toString', () async {
    assets.toString();
  });

  test('Asset toString', () async {
    expect(await assets.allExist(), false);
  });

  test('Asset toYaml', () async {
    expect(
        assets.first.toYamlString(),
        '''
name: foo
link_mode: dynamic
path:
  path_type: absolute
  uri: path/to/libfoo.so
target: android_x64
'''
            .trim());
  });

  test('Asset listFromYamlString', () async {
    final assets = Asset.listFromYamlString('');
    expect(assets, <Asset>[]);
  });
}
