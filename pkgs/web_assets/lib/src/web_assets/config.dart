// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';

import 'web_asset.dart';

/// Extension to the [HookConfig] providing access to configuration specific
/// to web assets.
extension HookConfigWebConfig on HookConfig {
  bool get buildWebAssets => buildAssetTypes.contains(WebAssetType.type);
}

/// Link output extension for web assets.
extension LinkInputWebAssets on LinkInputAssets {
  // Returns the web assets that were sent to this linker.
  //
  // NOTE: If the linker implementation depends on the contents of the files of
  // the web assets (e.g. by transforming them, merging with other files, etc)
  // then the linker script has to add those files as dependencies via
  // [LinkOutput.addDependency] to ensure the linker script will be re-run if
  // the content of the files changes.
  Iterable<WebAsset> get web =>
      encodedAssets.where((e) => e.isWebAsset).map(WebAsset.fromEncoded);
}

/// Extension on [BuildOutputBuilder] to add [WebAsset]s.
extension BuildOutputAssetsBuilderWeb on BuildOutputAssetsBuilder {
  /// Provides access to emitting web assets.
  ///
  /// Should only be used if [HookConfigWebConfig.buildWebAssets] is true.
  BuildOutputWebAssetsBuilder get web => BuildOutputWebAssetsBuilder._(this);
}

/// Extension on [BuildOutputBuilder] to add [WebAsset]s.
final class BuildOutputWebAssetsBuilder {
  final BuildOutputAssetsBuilder _output;

  BuildOutputWebAssetsBuilder._(this._output);

  /// Adds the given [asset] to the hook output with [routing].
  ///
  /// The [WebAsset.file] must be an absolute path. Prefer constructing the
  /// path via [HookInput.outputDirectoryShared] or [HookInput.outputDirectory]
  /// for files emitted during a hook, and via [HookInput.packageRoot] for files
  /// which are part of the package.
  void add(WebAsset asset, {AssetRouting routing = const ToAppBundle()}) =>
      _output.addEncodedAsset(asset.encode(), routing: routing);

  /// Adds the given [assets] to the hook output with [routing].
  ///
  /// The [WebAsset.file]s must be absolute paths. Prefer constructing the
  /// path via [HookInput.outputDirectoryShared] or [HookInput.outputDirectory]
  /// for files emitted during a hook, and via [HookInput.packageRoot] for files
  /// which are part of the package.
  void addAll(
    Iterable<WebAsset> assets, {
    AssetRouting routing = const ToAppBundle(),
  }) {
    for (final asset in assets) {
      add(asset, routing: routing);
    }
  }
}

/// Extension on [LinkOutputBuilder] to add [WebAsset]s.
extension LinkOutputAssetsBuilderWeb on LinkOutputAssetsBuilder {
  /// Provides access to emitting web assets.
  LinkOutputWebAssetsBuilder get web => LinkOutputWebAssetsBuilder(this);
}

/// Extension on [LinkOutputBuilder] to add [WebAsset]s.
final class LinkOutputWebAssetsBuilder {
  final LinkOutputAssetsBuilder _output;

  LinkOutputWebAssetsBuilder(this._output);

  /// Adds the given [asset] to the link hook output.
  void add(WebAsset asset, {LinkAssetRouting routing = const ToAppBundle()}) =>
      _output.addEncodedAsset(asset.encode(), routing: routing);

  /// Adds the given [assets] to the link hook output.
  void addAll(
    Iterable<WebAsset> assets, {
    LinkAssetRouting routing = const ToAppBundle(),
  }) {
    for (final asset in assets) {
      add(asset, routing: routing);
    }
  }
}

/// Provides access to [WebAsset]s from a build hook output.
extension BuildOutputWebAssets on BuildOutputAssets {
  List<WebAsset> get web => encodedAssets
      .where((asset) => asset.isWebAsset)
      .map<WebAsset>(WebAsset.fromEncoded)
      .toList();
}

/// Provides access to [WebAsset]s from a link hook output.
extension LinkOutputWebAssets on LinkOutputAssets {
  List<WebAsset> get web => encodedAssets
      .where((asset) => asset.isWebAsset)
      .map<WebAsset>(WebAsset.fromEncoded)
      .toList();
}
