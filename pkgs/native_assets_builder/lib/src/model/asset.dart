// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

import '../utils/yaml.dart';

/// Asset is avaliable on a relative path.
///
/// If [LinkMode] of an [Asset] is [LinkMode.dynamic],
/// `Platform.script.resolve(uri)` will be used to load the asset at runtime.
class AssetRelativePath implements AssetPath {
  final Uri uri;

  AssetRelativePath(this.uri);

  static const _pathTypeValue = 'relative';

  @override
  Map<String, Object> toYaml() => throw UnimplementedError();
  @override
  List<String> toDartConst() => [_pathTypeValue, uri.toFilePath()];

  @override
  int get hashCode => Object.hash(uri, 133717);

  @override
  bool operator ==(Object other) {
    if (other is! AssetRelativePath) {
      return false;
    }
    return uri == other.uri;
  }

  @override
  Future<bool> exists() => throw UnimplementedError();
}

extension AssetIterable on Iterable<Asset> {
  Iterable<Asset> whereLinkMode(LinkMode linkMode) =>
      where((e) => e.linkMode == linkMode);

  Map<Target, List<Asset>> get assetsPerTarget {
    final result = <Target, List<Asset>>{};
    for (final asset in this) {
      final assets = result[asset.target] ?? [];
      assets.add(asset);
      result[asset.target] = assets;
    }
    return result;
  }

  Map<String, Map<String, List<String>>> toDartConst() => {
        for (final entry in assetsPerTarget.entries)
          entry.key.toString():
              _combineMaps(entry.value.map((e) => e.toDartConst()).toList())
      };

  Map<Object, Object> toNativeAssetsFileEncoding() => {
        'format-version': [1, 0, 0],
        'native-assets': toDartConst(),
      };

  String toNativeAssetsFile() => yamlEncode(toNativeAssetsFileEncoding());
}

Map<X, Y> _combineMaps<X, Y>(Iterable<Map<X, Y>> maps) {
  final result = <X, Y>{};
  for (final map in maps) {
    result.addAll(map);
  }
  return result;
}
