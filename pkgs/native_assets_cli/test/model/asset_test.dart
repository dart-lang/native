// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:native_assets_cli/src/api/c_code_asset.dart';
import 'package:test/test.dart';

void main() {
  final fooUri = Uri.file('path/to/libfoo.so');
  final foo3Uri = Uri(path: 'libfoo3.so');
  final barUri = Uri(path: 'path/to/libbar.a');
  final blaUri = Uri(path: 'path/with spaces/bla.dll');
  final assets = [
    CCodeAssetImpl(
      id: 'foo',
      path: AssetAbsolutePathImpl(fooUri),
      target: TargetImpl.androidX64,
      linkMode: LinkModeImpl.dynamic,
    ),
    CCodeAssetImpl(
      id: 'foo3',
      path: AssetSystemPathImpl(foo3Uri),
      target: TargetImpl.androidX64,
      linkMode: LinkModeImpl.dynamic,
    ),
    CCodeAssetImpl(
      id: 'foo4',
      path: AssetInExecutableImpl(),
      target: TargetImpl.androidX64,
      linkMode: LinkModeImpl.dynamic,
    ),
    CCodeAssetImpl(
      id: 'foo5',
      path: AssetInProcessImpl(),
      target: TargetImpl.androidX64,
      linkMode: LinkModeImpl.dynamic,
    ),
    CCodeAssetImpl(
      id: 'bar',
      path: AssetAbsolutePathImpl(barUri),
      target: TargetImpl.linuxArm64,
      linkMode: LinkModeImpl.static,
    ),
    CCodeAssetImpl(
      id: 'bla',
      path: AssetAbsolutePathImpl(blaUri),
      target: TargetImpl.windowsX64,
      linkMode: LinkModeImpl.dynamic,
    ),
  ];

  final assetsYamlEncodingV1_0_0 = '''- id: foo
  link_mode: dynamic
  path:
    path_type: absolute
    uri: ${fooUri.toFilePath()}
  target: android_x64
- id: foo3
  link_mode: dynamic
  path:
    path_type: system
    uri: ${foo3Uri.toFilePath()}
  target: android_x64
- id: foo4
  link_mode: dynamic
  path:
    path_type: executable
  target: android_x64
- id: foo5
  link_mode: dynamic
  path:
    path_type: process
  target: android_x64
- id: bar
  link_mode: static
  path:
    path_type: absolute
    uri: ${barUri.toFilePath()}
  target: linux_arm64
- id: bla
  link_mode: dynamic
  path:
    path_type: absolute
    uri: ${blaUri.toFilePath()}
  target: windows_x64''';

  final assetsYamlEncoding = '''- id: foo
  link_mode: dynamic
  path:
    path_type: absolute
    uri: ${fooUri.toFilePath()}
  target: android_x64
  type: c_code
- id: foo3
  link_mode: dynamic
  path:
    path_type: system
    uri: ${foo3Uri.toFilePath()}
  target: android_x64
  type: c_code
- id: foo4
  link_mode: dynamic
  path:
    path_type: executable
  target: android_x64
  type: c_code
- id: foo5
  link_mode: dynamic
  path:
    path_type: process
  target: android_x64
  type: c_code
- id: bar
  link_mode: static
  path:
    path_type: absolute
    uri: ${barUri.toFilePath()}
  target: linux_arm64
  type: c_code
- id: bla
  link_mode: dynamic
  path:
    path_type: absolute
    uri: ${blaUri.toFilePath()}
  target: windows_x64
  type: c_code''';

  test('asset yaml', () {
    final yaml = assets.toYamlString();
    expect(yaml, assetsYamlEncoding);
    final assets2 = CCodeAssetImpl.listFromYamlString(yaml);
    expect(assets, assets2);
  });

  test('build_output protocol v1.0.0 keeps working', () {
    final assets2 = CCodeAssetImpl.listFromYamlString(assetsYamlEncodingV1_0_0);
    expect(assets, assets2);
  });

  test('AssetPath factory', () async {
    expect(
      () => AssetPathImpl('wrong', null),
      throwsA(predicate(
        (e) => e is FormatException && e.message.contains('Unknown pathType'),
      )),
    );
  });

  test('Asset hashCode copyWith', () async {
    final asset = assets.first;
    final asset2 = asset.copyWith(id: 'foo321');
    expect(asset.hashCode != asset2.hashCode, true);

    final asset3 = asset.copyWith();
    expect(asset.hashCode, asset3.hashCode);
  });

  test('List<Asset> hashCode', () async {
    final assets2 = assets.take(3).toList();
    const equality = ListEquality<CCodeAssetImpl>();
    expect(equality.hash(assets) != equality.hash(assets2), true);
  });

  test('Asset toString', () async {
    assets.toString();
  });

  test('Asset listFromYamlString', () async {
    final assets = CCodeAssetImpl.listFromYamlString('');
    expect(assets, <CCodeAssetImpl>[]);
  });
}
