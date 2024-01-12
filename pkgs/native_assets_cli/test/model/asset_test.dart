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
  final assets = [
    Asset(
      id: 'foo',
      path: AssetAbsolutePath(fooUri),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      id: 'foo3',
      path: AssetSystemPath(foo3Uri),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      id: 'foo4',
      path: AssetInExecutable(),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      id: 'foo5',
      path: AssetInProcess(),
      target: Target.androidX64,
      linkMode: LinkMode.dynamic,
    ),
    Asset(
      id: 'bar',
      path: AssetAbsolutePath(barUri),
      target: Target.linuxArm64,
      linkMode: LinkMode.static,
    ),
    Asset(
      id: 'bla',
      path: AssetAbsolutePath(blaUri),
      target: Target.windowsX64,
      linkMode: LinkMode.dynamic,
    ),
  ];

  final assetsYamlEncoding = '''- id: foo
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

  test('asset yaml', () {
    final yaml = assets.toYamlString();
    expect(yaml, assetsYamlEncoding);
    final assets2 = Asset.listFromYamlString(yaml);
    expect(assets, assets2);
  });

  test('AssetPath factory', () async {
    expect(
      () => AssetPath('wrong', null),
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
    const equality = ListEquality<Asset>();
    expect(equality.hash(assets) != equality.hash(assets2), true);
  });

  test('Asset toString', () async {
    assets.toString();
  });

  test('Asset listFromYamlString', () async {
    final assets = Asset.listFromYamlString('');
    expect(assets, <Asset>[]);
  });
}
