// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:hooks/hooks.dart';

import 'data_asset.dart';

/// Extension on [BuildOutputBuilder] to handle data asset directories and
/// files.
extension BuildOutputBuilderAddDataAssetsDirectories on BuildOutputBuilder {
  /// Extension on [BuildOutputBuilder] to handle data asset directories and
  /// files.
  ///
  /// This extension provides a convenient way for build hooks to add
  /// [DataAsset] dependencies from one or more directories or individual files.
  ///
  /// If any specified path does not exist, a [FileSystemException] is thrown.
  /// Any error during the directory listing is caught and rethrown with
  /// additional context.
  ///
  /// When recursive is set to true, the method will also add all subdirectories
  /// and their files as dependencies.
  ///
  /// Should only be used if [HookConfigDataConfig.buildDataAssets] in [input]
  /// is true.
  Future<void> addDataAssetDirectories(
    List<String> paths, {
    required HookInput input,
    bool recursive = false,
    AssetRouting routing = const ToAppBundle(),
  }) async {
    String assetName(Uri assetUri) => assetUri
        .toFilePath(windows: false)
        .substring(input.packageRoot.toFilePath(windows: false).length);

    void addAsset(File file) {
      assets.data.add(
        DataAsset(
          package: input.packageName,
          name: assetName(file.uri),
          file: file.uri,
        ),
        routing: routing,
      );
      dependencies.add(file.uri);
    }

    for (final path in paths) {
      final resolvedUri = input.packageRoot.resolve(path);
      final directory = Directory.fromUri(resolvedUri);
      final file = File.fromUri(resolvedUri);

      if (await directory.exists()) {
        try {
          dependencies.add(directory.uri);
          await for (final entity in directory.list(
            recursive: recursive,
            followLinks: false,
          )) {
            if (entity is File) {
              addAsset(entity);
            } else {
              dependencies.add(entity.uri);
            }
          }
        } on FileSystemException catch (e) {
          throw FileSystemException(
            'Error reading directory "$path": ${e.message}',
            directory.path,
            e.osError,
          );
        }
      } else if (await file.exists()) {
        addAsset(file);
      } else {
        throw FileSystemException(
          'Path does not exist',
          resolvedUri.toFilePath(windows: Platform.isWindows),
        );
      }
    }
  }
}

/// Extension to the [HookConfig] providing access to configuration specific
/// to data assets.
extension HookConfigDataConfig on HookConfig {
  bool get buildDataAssets => buildAssetTypes.contains(DataAssetType.type);
}

/// Link output extension for data assets.
extension LinkInputDataAssets on LinkInputAssets {
  // Returns the data assets that were sent to this linker.
  //
  // NOTE: If the linker implementation depends on the contents of the files of
  // the data assets (e.g. by transforming them, merging with other files, etc)
  // then the linker script has to add those files as dependencies via
  // [LinkOutput.addDependency] to ensure the linker script will be re-run if
  // the content of the files changes.
  Iterable<DataAsset> get data =>
      encodedAssets.where((e) => e.isDataAsset).map(DataAsset.fromEncoded);
}

/// Extension on [BuildOutputBuilder] to add [DataAsset]s.
extension BuildOutputAssetsBuilderData on BuildOutputAssetsBuilder {
  /// Provides access to emitting data assets.
  ///
  /// Should only be used if [HookConfigDataConfig.buildDataAssets] is true.
  BuildOutputDataAssetsBuilder get data => BuildOutputDataAssetsBuilder._(this);
}

/// Extension on [BuildOutputBuilder] to add [DataAsset]s.
final class BuildOutputDataAssetsBuilder {
  final BuildOutputAssetsBuilder _output;

  BuildOutputDataAssetsBuilder._(this._output);

  /// Adds the given [asset] to the hook output with [routing].
  ///
  /// The [DataAsset.file] must be an absolute path. Prefer constructing the
  /// path via [HookInput.outputDirectoryShared] or [HookInput.outputDirectory]
  /// for files emitted during a hook, and via [HookInput.packageRoot] for files
  /// which are part of the package.
  void add(DataAsset asset, {AssetRouting routing = const ToAppBundle()}) =>
      _output.addEncodedAsset(asset.encode(), routing: routing);

  /// Adds the given [assets] to the hook output with [routing].
  ///
  /// The [DataAsset.file]s must be absolute paths. Prefer constructing the
  /// path via [HookInput.outputDirectoryShared] or [HookInput.outputDirectory]
  /// for files emitted during a hook, and via [HookInput.packageRoot] for files
  /// which are part of the package.
  void addAll(
    Iterable<DataAsset> assets, {
    AssetRouting routing = const ToAppBundle(),
  }) {
    for (final asset in assets) {
      add(asset, routing: routing);
    }
  }
}

/// Extension on [LinkOutputBuilder] to add [DataAsset]s.
extension LinkOutputAssetsBuilderData on LinkOutputAssetsBuilder {
  /// Provides access to emitting data assets.
  LinkOutputDataAssetsBuilder get data => LinkOutputDataAssetsBuilder(this);
}

/// Extension on [LinkOutputBuilder] to add [DataAsset]s.
final class LinkOutputDataAssetsBuilder {
  final LinkOutputAssetsBuilder _output;

  LinkOutputDataAssetsBuilder(this._output);

  /// Adds the given [asset] to the link hook output.
  void add(DataAsset asset, {LinkAssetRouting routing = const ToAppBundle()}) =>
      _output.addEncodedAsset(asset.encode(), routing: routing);

  /// Adds the given [assets] to the link hook output.
  void addAll(
    Iterable<DataAsset> assets, {
    LinkAssetRouting routing = const ToAppBundle(),
  }) {
    for (final asset in assets) {
      add(asset, routing: routing);
    }
  }
}

/// Provides access to [DataAsset]s from a build hook output.
extension BuildOutputDataAssets on BuildOutputAssets {
  List<DataAsset> get data => encodedAssets
      .where((asset) => asset.isDataAsset)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}

/// Provides access to [DataAsset]s from a link hook output.
extension LinkOutputDataAssets on LinkOutputAssets {
  List<DataAsset> get data => encodedAssets
      .where((asset) => asset.isDataAsset)
      .map<DataAsset>(DataAsset.fromEncoded)
      .toList();
}
