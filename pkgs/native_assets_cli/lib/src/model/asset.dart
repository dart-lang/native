// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/asset.dart';

abstract final class AssetImpl implements Asset {
  Map<String, Object> toJson(Version version);

  static List<AssetImpl> listFromJson(List<Object?>? list) {
    final assets = <AssetImpl>[];
    if (list == null) return assets;
    for (final jsonElement in list) {
      final jsonMap = as<Map<Object?, Object?>>(jsonElement);
      final type = jsonMap[NativeCodeAssetImpl.typeKey];
      switch (type) {
        case NativeCodeAsset.type:
        case null: // Backwards compatibility with v1.0.0.
          assets.add(NativeCodeAssetImpl.fromJson(jsonMap));
        case DataAsset.type:
          assets.add(DataAssetImpl.fromJson(jsonMap));
        default:
        // Do nothing, some other launcher might define it's own asset types.
      }
    }
    return assets;
  }

  static List<Map<String, Object>> listToJson(
          List<AssetImpl> assets, Version version) =>
      [
        for (final asset in assets) asset.toJson(version),
      ];
}
