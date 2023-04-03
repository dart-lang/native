// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  final assets = [
    Asset(
      name: 'foo',
      path: AssetAbsolutePath(Uri(path: 'path/to/libfoo.so')),
      target: Target.androidX64,
      packaging: Packaging.dynamic,
    ),
    Asset(
      name: 'foo2',
      path: AssetRelativePath(Uri(path: 'path/to/libfoo2.so')),
      target: Target.androidX64,
      packaging: Packaging.dynamic,
    ),
    Asset(
      name: 'foo3',
      path: AssetSystemPath(Uri(path: 'libfoo3.so')),
      target: Target.androidX64,
      packaging: Packaging.dynamic,
    ),
    Asset(
      name: 'foo4',
      path: AssetInExecutable(),
      target: Target.androidX64,
      packaging: Packaging.dynamic,
    ),
    Asset(
      name: 'foo5',
      path: AssetInProcess(),
      target: Target.androidX64,
      packaging: Packaging.dynamic,
    ),
    Asset(
      name: 'bar',
      path: AssetAbsolutePath(Uri(path: 'path/to/libbar.a')),
      target: Target.linuxArm64,
      packaging: Packaging.static,
    ),
    Asset(
      name: 'bla',
      path: AssetAbsolutePath(Uri(path: 'path/with spaces/bla.dll')),
      target: Target.windowsX64,
      packaging: Packaging.dynamic,
    ),
  ];

  const assetsYamlEncoding = '''- name: foo
  packaging: dynamic
  path:
    path_type: absolute
    uri: path/to/libfoo.so
  target: android_x64
- name: foo2
  packaging: dynamic
  path:
    path_type: relative
    uri: path/to/libfoo2.so
  target: android_x64
- name: foo3
  packaging: dynamic
  path:
    path_type: system
    uri: libfoo3.so
  target: android_x64
- name: foo4
  packaging: dynamic
  path:
    path_type: executable
  target: android_x64
- name: foo5
  packaging: dynamic
  path:
    path_type: process
  target: android_x64
- name: bar
  packaging: static
  path:
    path_type: absolute
    uri: path/to/libbar.a
  target: linux_arm64
- name: bla
  packaging: dynamic
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
    final yaml = assets.toYaml().replaceAll('\\', '/');
    expect(yaml, assetsYamlEncoding);
    final assets2 = Asset.listFromYamlString(yaml);
    expect(assets, assets2);
  });

  test('asset yaml', () async {
    final fileContents = assets.toNativeAssetsFile();
    expect(fileContents.replaceAll('\\', '/'), assetsDartEncoding);
  });
}
