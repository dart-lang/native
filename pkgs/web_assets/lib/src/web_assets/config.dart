// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';

import 'web_asset.dart';

/// Extension to the [HookConfig] providing access to configuration specific
/// to web assets.
extension HookConfigWebConfig on HookConfig {
  bool get buildWebUriAssets => buildAssetTypes.contains(WebUriAssetType.type);
}

/// Link output extension for web assets.
extension LinkInputWebAssets on LinkInputAssets {
  // Returns the web uri assets that were sent to this linker.
  //
  // NOTE: If the linker implementation depends on the contents of the files of
  // the web uri assets (e.g. by transforming them, merging with other files,
  // etc) then the linker script has to add those files as dependencies via
  // [LinkOutput.addDependency] to ensure the linker script will be re-run if
  // the content of the files changes.
  Iterable<WebUriAsset> get webUri =>
      encodedAssets.where((e) => e.isWebAsset).map(WebUriAsset.fromEncoded);
}

/// Extension on [BuildOutputBuilder] to add [WebUriAsset]s.
extension BuildOutputAssetsBuilderWeb on BuildOutputAssetsBuilder {
  /// Provides access to emitting web assets.
  ///
  /// Should only be used if [HookConfigWebConfig.buildWebUriAssets] is true.
  BuildOutputWebUriAssetsBuilder get webUri =>
      BuildOutputWebUriAssetsBuilder._(this);
}

/// Extension on [BuildOutputBuilder] to add [WebUriAsset]s.
final class BuildOutputWebUriAssetsBuilder._(
  final BuildOutputAssetsBuilder _output,
) {
  /// Adds the given [asset] to the hook output with [routing].
  ///
  /// The [WebUriAsset.file] must be an absolute path. Prefer constructing the
  /// path via [HookInput.outputDirectoryShared] or [HookInput.outputDirectory]
  /// for files emitted during a hook, and via [HookInput.packageRoot] for files
  /// which are part of the package.
  void add(WebUriAsset asset, {AssetRouting routing = const ToAppBundle()}) =>
      _output.addEncodedAsset(asset.encode(), routing: routing);

  /// Adds the given [assets] to the hook output with [routing].
  ///
  /// The [WebUriAsset.file]s must be an absolute path. Prefer constructing the
  /// path via [HookInput.outputDirectoryShared] or [HookInput.outputDirectory]
  /// for files emitted during a hook, and via [HookInput.packageRoot] for files
  /// which are part of the package.
  void addAll(
    Iterable<WebUriAsset> assets, {
    AssetRouting routing = const ToAppBundle(),
  }) {
    for (final asset in assets) {
      add(asset, routing: routing);
    }
  }
}

/// Extension on [LinkOutputBuilder] to add [WebUriAsset]s.
extension LinkOutputAssetsBuilderWeb on LinkOutputAssetsBuilder {
  /// Provides access to emitting web assets.
  LinkOutputWebUriAssetsBuilder get web =>
      LinkOutputWebUriAssetsBuilder._(this);
}

/// Extension on [LinkOutputBuilder] to add [WebUriAsset]s.
final class LinkOutputWebUriAssetsBuilder._(
  final LinkOutputAssetsBuilder _output,
) {
  /// Adds the given [asset] to the link hook output.
  void add(
    WebUriAsset asset, {
    LinkAssetRouting routing = const ToAppBundle(),
  }) => _output.addEncodedAsset(asset.encode(), routing: routing);

  /// Adds the given [assets] to the link hook output.
  void addAll(
    Iterable<WebUriAsset> assets, {
    LinkAssetRouting routing = const ToAppBundle(),
  }) {
    for (final asset in assets) {
      add(asset, routing: routing);
    }
  }
}

/// Provides access to [WebUriAsset]s from a build hook output.
extension BuildOutputWebAssets on BuildOutputAssets {
  List<WebUriAsset> get webUri => encodedAssets
      .where((asset) => asset.isWebAsset)
      .map<WebUriAsset>(WebUriAsset.fromEncoded)
      .toList();
}

/// Provides access to [WebUriAsset]s from a link hook output.
extension LinkOutputWebAssets on LinkOutputAssets {
  List<WebUriAsset> get web => encodedAssets
      .where((asset) => asset.isWebAsset)
      .map<WebUriAsset>(WebUriAsset.fromEncoded)
      .toList();
}
