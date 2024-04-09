// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'build_output.dart';

abstract final class LinkOutput {
  /// Start time for the link of this output.
  ///
  /// The [timestamp] is rounded down to whole seconds, because
  /// [File.lastModified] is rounded to whole seconds and caching logic compares
  /// these timestamps.
  DateTime get timestamp;

  /// The assets produced by this link.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  Iterable<Asset> get assets;

  /// The files used by this link.
  ///
  /// If any of the files in [dependencies] are modified after [timestamp], the
  /// link will be re-run.
  Iterable<Uri> get dependencies;

  /// Adds file used by this link.
  ///
  /// If any of the files are modified after [timestamp], the link will be
  /// re-run.
  void addDependency(Uri dependency);

  /// Adds files used by this link.
  ///
  /// If any of the files are modified after [timestamp], the link will be
  /// re-run.
  void addDependencies(Iterable<Uri> dependencies);

  /// Adds [Asset]s produced by this link or dry run.
  void linkAsset(LinkableAsset asset);

  /// Adds [Asset]s produced by this link or dry run.
  void linkAssets(Iterable<LinkableAsset> assets);

  factory LinkOutput({
    required List<AssetImpl> assets,
    required Dependencies dependencies,
    required DateTime timestamp,
  }) =>
      HookOutputImpl(
        assets: assets,
        dependencies: dependencies,
        timestamp: timestamp,
      );
}
