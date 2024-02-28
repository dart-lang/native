// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:native_assets_cli/src/api/asset.dart';
import 'package:native_assets_cli/src/utils/yaml.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final fooUri = Uri.file('path/to/libfoo.so');
  final foo3Uri = Uri(path: 'libfoo3.so');
  final barUri = Uri(path: 'path/to/libbar.a');
  final blaUri = Uri(path: 'path/with spaces/bla.dll');
  final dataUri = Uri.file('path/to/data.txt');
  final data2Uri = Uri.file('path/to/data.json');
  final cCodeAssets = [
    CCodeAssetImpl(
      id: 'package:my_package/foo',
      file: fooUri,
      dynamicLoading: BundledDylibImpl(),
      os: OSImpl.android,
      architecture: ArchitectureImpl.x64,
      linkMode: LinkModeImpl.dynamic,
    ),
    CCodeAssetImpl(
      id: 'package:my_package/foo3',
      dynamicLoading: SystemDylibImpl(foo3Uri),
      os: OSImpl.android,
      architecture: ArchitectureImpl.x64,
      linkMode: LinkModeImpl.dynamic,
    ),
    CCodeAssetImpl(
      id: 'package:my_package/foo4',
      dynamicLoading: LookupInExecutableImpl(),
      os: OSImpl.android,
      architecture: ArchitectureImpl.x64,
      linkMode: LinkModeImpl.dynamic,
    ),
    CCodeAssetImpl(
      id: 'package:my_package/foo5',
      dynamicLoading: LookupInProcessImpl(),
      os: OSImpl.android,
      architecture: ArchitectureImpl.x64,
      linkMode: LinkModeImpl.dynamic,
    ),
    CCodeAssetImpl(
      id: 'package:my_package/bar',
      file: barUri,
      os: OSImpl.linux,
      architecture: ArchitectureImpl.arm64,
      linkMode: LinkModeImpl.static,
    ),
    CCodeAssetImpl(
      id: 'package:my_package/bla',
      file: blaUri,
      dynamicLoading: BundledDylibImpl(),
      os: OSImpl.windows,
      architecture: ArchitectureImpl.x64,
      linkMode: LinkModeImpl.dynamic,
    ),
  ];
  final dataAssets = [
    DataAssetImpl(
      id: 'package:my_package/my_data_asset',
      file: dataUri,
    ),
    DataAssetImpl(
      id: 'package:my_package/my_data_asset2',
      file: data2Uri,
    ),
  ];
  final assets = [
    ...cCodeAssets,
    ...dataAssets,
  ];

  final assetsYamlEncodingV1_0_0 = '''- id: package:my_package/foo
  link_mode: dynamic
  path:
    path_type: absolute
    uri: ${fooUri.toFilePath()}
  target: android_x64
- id: package:my_package/foo3
  link_mode: dynamic
  path:
    path_type: system
    uri: ${foo3Uri.toFilePath()}
  target: android_x64
- id: package:my_package/foo4
  link_mode: dynamic
  path:
    path_type: executable
  target: android_x64
- id: package:my_package/foo5
  link_mode: dynamic
  path:
    path_type: process
  target: android_x64
- id: package:my_package/bar
  link_mode: static
  path:
    path_type: absolute
    uri: ${barUri.toFilePath()}
  target: linux_arm64
- id: package:my_package/bla
  link_mode: dynamic
  path:
    path_type: absolute
    uri: ${blaUri.toFilePath()}
  target: windows_x64''';

  final assetsYamlEncoding = '''- architecture: x64
  dynamic_loading:
    type: bundle
  file: ${fooUri.toFilePath()}
  id: package:my_package/foo
  link_mode: dynamic
  os: android
  type: c_code
- architecture: x64
  dynamic_loading:
    type: system
    uri: ${foo3Uri.toFilePath()}
  id: package:my_package/foo3
  link_mode: dynamic
  os: android
  type: c_code
- architecture: x64
  dynamic_loading:
    type: executable
  id: package:my_package/foo4
  link_mode: dynamic
  os: android
  type: c_code
- architecture: x64
  dynamic_loading:
    type: process
  id: package:my_package/foo5
  link_mode: dynamic
  os: android
  type: c_code
- architecture: arm64
  file: ${barUri.toFilePath()}
  id: package:my_package/bar
  link_mode: static
  os: linux
  type: c_code
- architecture: x64
  dynamic_loading:
    type: bundle
  file: ${blaUri.toFilePath()}
  id: package:my_package/bla
  link_mode: dynamic
  os: windows
  type: c_code
- id: package:my_package/my_data_asset
  file: ${dataUri.toFilePath()}
  type: data
- id: package:my_package/my_data_asset2
  file: ${data2Uri.toFilePath()}
  type: data''';

  test('asset yaml', () {
    final yaml = yamlEncode([
      for (final item in assets) item.toYaml(BuildOutputImpl.latestVersion)
    ]);
    expect(yaml, assetsYamlEncoding);
    final assets2 = AssetImpl.listFromYamlList(loadYaml(yaml) as YamlList);
    expect(assets, assets2);
  });

  test('build_output protocol v1.0.0 keeps working', () {
    final assets2 = AssetImpl.listFromYamlList(
        loadYaml(assetsYamlEncodingV1_0_0) as YamlList);
    expect(cCodeAssets, assets2);
  });

  test('AssetPath factory', () async {
    expect(
      () => DynamicLoadingImpl('wrong', null),
      throwsA(predicate(
        (e) => e is FormatException && e.message.contains('Unknown type'),
      )),
    );
  });

  test('Asset hashCode copyWith', () async {
    final asset = cCodeAssets.first;
    final asset2 = asset.copyWith(id: 'foo321');
    expect(asset.hashCode != asset2.hashCode, true);

    final asset3 = asset.copyWith();
    expect(asset.hashCode, asset3.hashCode);

    expect(dataAssets[0].hashCode, isNot(dataAssets[1].hashCode));
  });

  test('List<Asset> hashCode', () async {
    final assets2 = cCodeAssets.take(3).toList();
    const equality = ListEquality<CCodeAssetImpl>();
    expect(equality.hash(cCodeAssets) != equality.hash(assets2), true);
  });

  test('Asset toString', () async {
    assets.toString();
  });
}
