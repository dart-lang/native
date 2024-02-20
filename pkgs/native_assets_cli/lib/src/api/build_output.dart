// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

import '../model/dependencies.dart';
import '../model/metadata.dart';
import '../utils/datetime.dart';
import '../utils/file.dart';
import '../utils/map.dart';
import '../utils/yaml.dart';
import 'asset.dart';
import 'build_config.dart';
import 'target.dart';

part '../model/build_output.dart';

/// The output of a `build.dart` invocation.
///
/// A package can choose to have a toplevel `build.dart` script. If such a
/// script exists, it will be automatically run, by the Flutter and Dart SDK
/// tools. The script is expect to produce a specific output which [BuildOutput]
/// can produce.
abstract class BuildOutput {
  // Start time for the build of this output.
  ///
  /// The [timestamp] is rounded down to whole seconds, because
  /// [File.lastModified] is rounded to whole seconds and caching logic compares
  /// these timestamps.
  DateTime get timestamp;

  /// The assets produced by this build.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  Iterable<Asset> get assets;

  /// The files used by this build.
  ///
  /// If any of the files in [dependencies] are modified after [timestamp], the
  /// build will be re-run.
  Iterable<Uri> get dependencies;

  /// Create a build output.
  ///
  /// The [timestamp] must be before any any [dependencies] are read by the
  /// build this output belongs to. If the [BuildOutput] object is created at
  /// the beginning of the `build.dart` script, [timestamp] can be omitted and
  /// will default to [DateTime.now]. The [timestamp] is rounded down to whole
  /// seconds, because [File.lastModified] is rounded to whole seconds and
  /// caching logic compares these timestamps.
  ///
  /// The [CCodeAsset]s produced by this build or dry-run can be provided to the
  /// constructor as [assets], or can be added later using [addAssets]. In dry
  /// runs, the assets for all [Architecture]s for the [OS] specified in the dry
  /// run must be provided.
  ///
  /// The files used by this build must be passed in [dependencies] or
  /// [addDependencies]. If any of these files are modified after [timestamp],
  /// the build will be re-run. Typically these dependencies contain the
  /// `build.dart` script itself, and the source files used in the build.
  ///
  /// Metadata can be passed to `build.dart` invocations of dependent packages
  /// via [metadata] or [addMetadata].
  factory BuildOutput({
    DateTime? timestamp,
    Iterable<Asset>? assets,
    Iterable<Uri>? dependencies,
    Map<String, Object>? metadata,
  }) =>
      BuildOutputImpl(
        timestamp: timestamp,
        assets: assets?.cast<AssetImpl>().toList(),
        dependencies: Dependencies([...?dependencies]),
        metadata: Metadata({...?metadata}),
      );

  /// Adds [CCodeAsset]s produced by this build or dry run.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  void addAsset(Asset asset);

  /// Adds [CCodeAsset]s produced by this build or dry run.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  void addAssets(Iterable<Asset> assets);

  /// Adds file used by this build.
  ///
  /// If any of the files are modified after [timestamp], the build will be
  /// re-run.
  void addDependency(Uri dependency);

  /// Adds files used by this build.
  ///
  /// If any of the files are modified after [timestamp], the build will be
  /// re-run.
  void addDependencies(Iterable<Uri> dependencies);

  /// Adds metadata to be passed to `build.dart` invocations of dependent
  /// packages.
  void addMetadatum(String key, Object value);

  /// Adds metadata to be passed to `build.dart` invocations of dependent
  /// packages.
  void addMetadata(Map<String, Object> metadata);

  /// The version of [BuildOutput].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through `build.dart` invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  static Version get latestVersion => BuildOutputImpl.latestVersion;

  /// Write out this build output to a file inside [BuildConfig.outDir].
  Future<void> writeToFile({required BuildConfig config});
}
