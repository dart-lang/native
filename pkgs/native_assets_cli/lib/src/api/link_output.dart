// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'build_output.dart';

/// The output of a link hook (`hook/link.dart`) invocation.
///
/// A package can optionally provide link hook (`hook/link.dart`). If such a
/// hook exists, and any build hook outputs packages for linking with it, it
/// will be automatically run, by the Flutter and Dart SDK tools. The hook is
/// expect to produce a specific output which [LinkOutput] can produce.
///
/// For more information see [link].
///
/// Designed to be a sink. The [LinkOutput] is not designed to be read from.
/// [Linker]s stream outputs to the link output. For more info see [Linker].
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
  void addAsset(Asset asset);

  /// Adds [Asset]s produced by this link or dry run.
  void addAssets(Iterable<Asset> assets);

  factory LinkOutput({
    Iterable<Asset>? assets,
    Dependencies? dependencies,
    DateTime? timestamp,
  }) =>
      HookOutputImpl(
        assets: assets,
        dependencies: dependencies,
        timestamp: timestamp,
      );

  /// The version of [LinkOutput].
  ///
  /// The link output is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  static Version get latestVersion => HookOutputImpl.latestVersion;
}
