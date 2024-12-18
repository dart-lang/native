// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';

import '../encoded_asset.dart';
import 'data_asset.dart';

/// Build output extension for data assets.
extension DataAssetBuildOutputBuilder on BuildOutputBuilder {
  /// Provides access to emitting data assets.
  DataAssetBuildOutputBuilderAdd get data =>
      DataAssetBuildOutputBuilderAdd._(this);
}

/// Supports emitting code assets for build hooks.
extension type DataAssetBuildOutputBuilderAdd._(BuildOutputBuilder _output) {
  /// Adds the given [asset] to the hook output (or send to [linkInPackage]
  /// for linking if provided).
  void addAsset(DataAsset asset, {String? linkInPackage}) =>
      _output.addEncodedAsset(asset.encode(), linkInPackage: linkInPackage);

  /// Adds the given [assets] to the hook output (or send to [linkInPackage]
  /// for linking if provided).
  void addAll(Iterable<DataAsset> assets, {String? linkInPackage}) {
    for (final asset in assets) {
      addAsset(asset, linkInPackage: linkInPackage);
    }
  }
}

/// Extension to the [LinkOutputBuilder] providing access to emitting data
/// assets (only available if data assets are supported).
extension DataAssetLinkOutputBuilder on LinkOutputBuilder {
  /// Provides access to emitting data assets.
  DataAssetLinkOutputBuilderAdd get data => DataAssetLinkOutputBuilderAdd(this);
}

/// Extension on [LinkOutputBuilder] to emit data assets.
extension type DataAssetLinkOutputBuilderAdd(LinkOutputBuilder _output) {
  /// Adds the given [asset] to the link hook output.
  void addAsset(DataAsset asset) => _output.addEncodedAsset(asset.encode());

  /// Adds the given [assets] to the link hook output.
  void addAssets(Iterable<DataAsset> assets) => assets.forEach(addAsset);
}

extension DataAssetEncodedAsset on List<EncodedAsset> {
  List<DataAsset> get data => where((asset) => asset.type == DataAsset.type)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}
