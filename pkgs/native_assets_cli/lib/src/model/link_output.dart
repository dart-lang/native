// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_output.dart';

class LinkOutputImpl implements LinkOutput {
  final BuildOutputImpl _buildOutput;

  LinkOutputImpl({
    DateTime? timestamp,
    List<AssetImpl>? assets,
    Dependencies? dependencies,
  }) : _buildOutput = BuildOutputImpl(
          timestamp: timestamp,
          assets: assets,
          dependencies: dependencies,
        );

  /// Start time for the link of this output.
  ///
  /// The [timestamp] is rounded down to whole seconds, because
  /// [File.lastModified] is rounded to whole seconds and caching logic compares
  /// these timestamps.
  @override
  DateTime get timestamp => _buildOutput.timestamp;

  /// The assets produced by this link.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  @override
  Iterable<Asset> get assets => _buildOutput.assets;

  /// The files used by this link.
  ///
  /// If any of the files in [dependencies] are modified after [timestamp], the
  /// link will be re-run.
  @override
  Iterable<Uri> get dependencies => _buildOutput.dependencies;

  /// Adds [Asset]s produced by this link or dry run.
  @override
  void addAsset(Asset asset) => _buildOutput.addAsset(asset);

  /// Adds [Asset]s produced by this link or dry run.
  @override
  void addAssets(Iterable<Asset> assets) => _buildOutput.addAssets(assets);

  Future<void> writeToFile({required LinkConfigImpl config}) =>
      _buildOutput.writeToFile(config: config);
}
