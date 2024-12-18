// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../config.dart';

import '../encoded_asset.dart';
import 'data_asset.dart';

/// Link output extension for data assets.
extension DataAssetLinkConfig on LinkConfig {
  // Returns the data assets that were sent to this linker.
  //
  // NOTE: If the linker implementation depends on the contents of the files of
  // the data assets (e.g. by transforming them, merging with other files, etc)
  // then the linker script has to add those files as dependencies via
  // [LinkOutput.addDependency] to ensure the linker script will be re-run if
  // the content of the files changes.
  DataAssetLinkConfig2 get data => DataAssetLinkConfig2(this);
}

extension type DataAssetLinkConfig2(LinkConfig linkConfig) {
  // Returns the data assets that were sent to this linker.
  //
  // NOTE: If the linker implementation depends on the contents of the files of
  // the data assets (e.g. by transforming them, merging with other files, etc)
  // then the linker script has to add those files as dependencies via
  // [LinkOutput.addDependency] to ensure the linker script will be re-run if
  // the content of the files changes.
  Iterable<DataAsset> get assets => linkConfig.encodedAssets
      .where((e) => e.type == DataAsset.type)
      .map(DataAsset.fromEncoded);
}

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

extension DataAssetBuildOutput on BuildOutput {
  DataAssetBuildOutput2 get data => DataAssetBuildOutput2(this);
}

/// Provides access to [DataAsset]s from a build hook output.
extension type DataAssetBuildOutput2(BuildOutput buildOutput) {
  List<DataAsset> get assets => buildOutput.encodedAssets
      .where((asset) => asset.type == DataAsset.type)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}

extension DataAssetLinkOutput on LinkOutput {
  DataAssetLinkOutput2 get data => DataAssetLinkOutput2(this);
}

/// Provides access to [DataAsset]s from a link hook output.
extension type DataAssetLinkOutput2(LinkOutput linkOutput) {
  List<DataAsset> get assets => linkOutput.encodedAssets
      .where((asset) => asset.type == DataAsset.type)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}

extension DataAssetEncodedAsset on List<EncodedAsset> {
  List<DataAsset> get data => where((asset) => asset.type == DataAsset.type)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}
