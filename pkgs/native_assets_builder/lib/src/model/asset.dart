// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

import '../utils/yaml.dart';

extension on Asset {
  Map<String, List<String>> toDartConst() => {
        id: path.toDartConst(),
      };
}

extension on AssetPath {
  List<String> toDartConst() {
    final this_ = this;
    switch (this_) {
      case AssetAbsolutePath _:
        return ['absolute', this_.uri.toFilePath()];
      case AssetSystemPath _:
        return ['system', this_.uri.toFilePath()];
      case AssetInProcess _:
        return ['process'];
      default:
        assert(this_ is AssetInExecutable);
        return ['executable'];
    }
  }
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
