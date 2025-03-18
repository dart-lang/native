// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import '../config.dart';

import 'data_asset.dart';

extension AddDataAssetsDirectory on BuildOutputBuilder {
  /// Extension on [BuildOutput] to handle data asset directories and files.
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
  Future<void> addDataAssetDirectories(
    List<String> paths, {
    required BuildInput input,
    bool recursive = false,
  }) async {
    String assetName(Uri assetUri) => assetUri
        .toFilePath(windows: false)
        .substring(input.packageRoot.toFilePath().length);

    for (final path in paths) {
      final resolvedUri = input.packageRoot.resolve(path);
      final directory = Directory.fromUri(resolvedUri);
      final file = File.fromUri(resolvedUri);

      if (await directory.exists()) {
        try {
          await for (final entity in directory.list(
            recursive: recursive,
            followLinks: false,
          )) {
            if (entity is File) {
              assets.data.add(
                DataAsset(
                  package: input.packageName,
                  name: assetName(entity.uri),
                  file: entity.uri,
                ),
              );
              addDependency(entity.uri);
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
        assets.data.add(
          DataAsset(
            package: input.packageName,
            name: assetName(file.uri),
            file: file.uri,
          ),
        );
        addDependency(file.uri);
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

/// Build output extension for data assets.
extension DataAssetBuildOutputBuilder on EncodedAssetBuildOutputBuilder {
  /// Provides access to emitting data assets.
  DataAssetBuildOutputBuilderAdd get data =>
      DataAssetBuildOutputBuilderAdd._(this);
}

/// Supports emitting code assets for build hooks.
extension type DataAssetBuildOutputBuilderAdd._(
  EncodedAssetBuildOutputBuilder _output
) {
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
  EncodedAssetLinkOutputBuilder _output
) {
  /// Adds the given [asset] to the link hook output.
  void add(DataAsset asset) => _output.addEncodedAsset(asset.encode());

  /// Adds the given [assets] to the link hook output.
  void addAll(Iterable<DataAsset> assets) => assets.forEach(add);
}

/// Provides access to [DataAsset]s from a build hook output.
extension DataAssetBuildOutput on BuildOutputAssets {
  List<DataAsset> get data =>
      encodedAssets
          .where((asset) => asset.type == DataAsset.type)
          .map<DataAsset>(DataAsset.fromEncoded)
          .toList();
}

/// Provides access to [DataAsset]s from a link hook output.
extension DataAssetLinkOutput on LinkOutputAssets {
  List<DataAsset> get data =>
      encodedAssets
          .where((asset) => asset.type == DataAsset.type)
          .map<DataAsset>(DataAsset.fromEncoded)
          .toList();
}
