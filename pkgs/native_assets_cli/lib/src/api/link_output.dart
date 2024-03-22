// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'architecture.dart';
import 'asset.dart';
import 'build_output.dart';
import 'link_config.dart';
import 'os.dart';

extension type LinkOutput(BuildOutputImpl _buildOutput) {
  /// Start time for the link of this output.
  ///
  /// The [timestamp] is rounded down to whole seconds, because
  /// [File.lastModified] is rounded to whole seconds and caching logic compares
  /// these timestamps.
  DateTime get timestamp => _buildOutput.timestamp;

  /// The assets produced by this link.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  Iterable<Asset> get assets => _buildOutput.assets;

  /// The files used by this link.
  ///
  /// If any of the files in [dependencies] are modified after [timestamp], the
  /// link will be re-run.
  Iterable<Uri> get dependencies => _buildOutput.dependencies;

  /// Adds [Asset]s produced by this link or dry run.
  void addAsset(Asset asset) => _buildOutput.addAsset(asset);

  /// Adds [Asset]s produced by this link or dry run.
  void addAssets(Iterable<Asset> assets) => _buildOutput.addAssets(assets);

  /// Writes this object the output file specified in the [config].
  ///
  /// Serializes this object, meaning the [assets] and [dependencies] together
  /// with some metadata, to an output JSON file. The location of the file is
  /// specified in the [config].
  Future<void> writeToFile({required LinkConfig config}) =>
      _buildOutput.writeToFile(config: config);
}
