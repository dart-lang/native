// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

abstract final class AssetImpl implements Asset {
  Map<String, Object> toYaml(Version version);

  static List<AssetImpl> listFromYamlList(YamlList list) {
    final assets = <AssetImpl>[];
    for (final yamlElement in list) {
      final yamlMap = as<YamlMap>(yamlElement);
      final type = yamlMap[NativeCodeAssetImpl.typeKey];
      switch (type) {
        case NativeCodeAsset.type:
        case null: // Backwards compatibility with v1.0.0.
          assets.add(NativeCodeAssetImpl.fromYaml(yamlMap));
        case DataAsset.type:
          assets.add(DataAssetImpl.fromYaml(yamlMap));
        default:
        // Do nothing, some other launcher might define it's own asset types.
      }
    }
    return assets;
  }
}
