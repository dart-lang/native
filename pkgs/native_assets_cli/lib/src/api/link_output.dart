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

  /// Files and directories used to build an asset by this build.
  ///
  /// Maps [Asset.id]s to a list of absolute uris.
  ///
  /// If any of the files in [assetDependencies] are modified after [timestamp],
  /// the build will be re-run.
  ///
  /// The (transitive) Dart sources do not have to be added to these
  /// dependencies, only non-Dart files. (Note that old Dart and Flutter SDKs do
  /// not automatically add the Dart sources. So builds get wrongly cached, try
  /// updating to the latest release.)
  Map<String, Iterable<Uri>> get assetDependencies;

  /// Files and directories used that if modified could change which assets are
  /// built.
  ///
  /// Maps [Asset] types to a list of absolute uris.
  ///
  /// If any of the files in [assetTypeDependencies] are modified after
  /// [timestamp], the build will be re-run.
  ///
  /// The (transitive) Dart sources do not have to be added to these
  /// dependencies, only non-Dart files. (Note that old Dart and Flutter SDKs do
  /// not automatically add the Dart sources. So builds get wrongly cached, try
  /// updating to the latest release.)
  Map<String, Iterable<Uri>> get assetTypeDependencies;

  /// Adds file used by this link.
  ///
  /// If any of the files are modified after [timestamp], the link will be
  /// re-run.
  void addAssetTypeDependency(
    String assetType,
    Uri dependency,
  );

  /// Adds files used by this link.
  ///
  /// If any of the files are modified after [timestamp], the link will be
  /// re-run.
  void addAssetTypeDependencies(
    String assetType,
    Iterable<Uri> dependencies,
  );

  /// Adds [Asset]s produced by this link or dry run.
  ///
  /// If provided, [dependencies] adds files used to build these [asset]. If any
  /// of the files are modified after [timestamp], the build will be re-run. If
  /// omitted, and [Asset.file] is outside the [BuildConfig.outputDirectory], a
  /// dependency on the file is added implicitly.
  void addAsset(
    Asset asset, {
    Iterable<Uri>? dependencies,
  });

  /// Adds [Asset]s produced by this link or dry run.
  ///
  /// If provided, [dependencies] adds files used to build these [assets]. If
  /// any of the files are modified after [timestamp], the build will be re-run.
  /// If omitted, and [Asset.file] is outside the [BuildConfig.outputDirectory],
  /// a dependency on the file is added implicitly.
  void addAssets(
    Iterable<Asset> assets, {
    Iterable<Uri>? dependencies,
  });

  factory LinkOutput({
    Iterable<AssetImpl>? assets,
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
