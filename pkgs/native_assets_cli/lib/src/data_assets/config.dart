// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';

import 'data_asset.dart';

/// Extension to the [HookConfig] providing access to configuration specific
/// to data assets.
extension CodeAssetHookConfig on HookConfig {
  bool get buildDataAssets => buildAssetTypes.contains(DataAsset.type);
}

/// Extension to initialize data specific configuration on link/build inputs.
extension DataAssetBuildInputBuilder on HookConfigBuilder {}

/// Link output extension for data assets.
extension DataAssetLinkInput on LinkInputAssets {
  // Returns the data assets that were sent to this linker.
  //
  // NOTE: If the linker implementation depends on the contents of the files of
  // the data assets (e.g. by transforming them, merging with other files, etc)
  // then the linker script has to add those files as dependencies via
  // [LinkOutput.addDependency] to ensure the linker script will be re-run if
  // the content of the files changes.
  Iterable<DataAsset> get data => encodedAssets
      .where((e) => e.type == DataAsset.type)
      .map(DataAsset.fromEncoded);
}

/// Build output extension for data assets.`
extension DataAssetBuildOutputBuilder on EncodedAssetBuildOutputBuilder {
  /// Provides access to emitting data assets.
  DataAssetBuildOutputBuilderAdd get data =>
      DataAssetBuildOutputBuilderAdd._(this);
}

/// Supports emitting code assets for build hooks.
extension type DataAssetBuildOutputBuilderAdd._(
    EncodedAssetBuildOutputBuilder _output) {
  /// Adds the given [asset] to the hook output (or send to [linkInPackage]
  /// for linking if provided).
  void add(DataAsset asset, {String? linkInPackage}) =>
      _output.addEncodedAsset(asset.encode(), linkInPackage: linkInPackage);

  /// Adds the given [assets] to the hook output (or send to [linkInPackage]
  /// for linking if provided).
  void addAll(Iterable<DataAsset> assets, {String? linkInPackage}) {
    for (final asset in assets) {
      add(asset, linkInPackage: linkInPackage);
    }
  }
}

/// Extension to the [LinkOutputBuilder] providing access to emitting data
/// assets (only available if data assets are supported).
extension DataAssetLinkOutputBuilder on EncodedAssetLinkOutputBuilder {
  /// Provides access to emitting data assets.
  DataAssetLinkOutputBuilderAdd get data => DataAssetLinkOutputBuilderAdd(this);
}

/// Extension on [LinkOutputBuilder] to emit data assets.
extension type DataAssetLinkOutputBuilderAdd(
    EncodedAssetLinkOutputBuilder _output) {
  /// Adds the given [asset] to the link hook output.
  void add(DataAsset asset) => _output.addEncodedAsset(asset.encode());

  /// Adds the given [assets] to the link hook output.
  void addAll(Iterable<DataAsset> assets) => assets.forEach(add);
}

/// Provides access to [DataAsset]s from a build hook output.
extension DataAssetBuildOutput on BuildOutputAssets {
  List<DataAsset> get data => encodedAssets
      .where((asset) => asset.type == DataAsset.type)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}

/// Provides access to [DataAsset]s from a link hook output.
extension DataAssetLinkOutput on LinkOutputAssets {
  List<DataAsset> get data => encodedAssets
      .where((asset) => asset.type == DataAsset.type)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}
