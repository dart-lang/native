// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:pub_semver/pub_semver.dart';

import '../model/asset.dart' as model;
import '../model/build_output.dart' as model;
import '../model/dependencies.dart' as model;
import '../model/metadata.dart' as model;
import 'asset.dart';
import 'dependencies.dart';
import 'metadata.dart';
import 'target.dart';

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

  @Deprecated('Use assets2')
  List<Asset> get assets;

  /// The assets produced by this build.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  // TODO: Rename to `assets` after removing old one.
  Iterable<Asset> get assets2;

  @Deprecated('Use dependencies2')
  Dependencies get dependencies;

  /// The files used by this build.
  ///
  /// If any of the files in [dependencies2] are modified after [timestamp], the
  /// build will be re-run.
  // TODO: Rename to `dependencies` after removing old one.
  Iterable<Uri> get dependencies2;

  @Deprecated('Use getMetadata')
  Metadata get metadata;

  /// Metadata can to be passed to `build.dart` invocations of dependent
  /// packages.
  // TODO(dacoharkes): Rename to metadata.
  Object? metadata2(String key);

  /// Create a build output.
  ///
  /// The [timestamp] must be before any any [dependencies2] are read by the
  /// build this output belongs to. If the [BuildOutput] object is created at
  /// the beginning of the `build.dart` script, it can be omitted and will
  /// default to [DateTime.now]. The [timestamp] is rounded down to whole
  /// seconds, because [File.lastModified] is rounded to whole seconds and
  /// caching logic compares these timestamps.
  ///
  /// The [Asset]s produced by this build or dry-run can be provided to the
  /// constructor as [assets], or can be added later using [addAssets]. In dry
  /// runs, the assets for all [Architecture]s for the [OS] specified in the dry
  /// run must be provided.
  ///
  /// The files used by this build must be passed in [dependencies2] or
  /// [addDependencies]. If any of these files are modified after [timestamp],
  /// the build will be re-run.
  ///
  /// Metadata can be passed to `build.dart` invocations of dependent packages
  /// via [metadata2] or [addMetadata].
  factory BuildOutput({
    DateTime? timestamp,
    Iterable<Asset>? assets,
    @Deprecated('Use addDependencies.') Dependencies? dependencies,
    Iterable<Uri>? dependencies2,
    @Deprecated('Use addMetadata.') Metadata? metadata,
    Map<String, Object>? metadata2,
  }) =>
      model.BuildOutput(
        timestamp: timestamp,
        assets: assets?.cast<model.Asset>().toList(),
        dependencies: dependencies2 != null
            ? model.Dependencies(dependencies2.toList())
            : dependencies as model.Dependencies?,
        metadata: metadata2 != null
            ? model.Metadata(metadata2)
            : metadata as model.Metadata?,
      );

  /// Adds [Asset]s produced by this build or dry run.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  void addAssets(Iterable<Asset> assets);

  /// Adds files used by this build.
  ///
  /// If any of the files are modified after [timestamp], the build will be
  /// re-run.
  void addDependencies(Iterable<Uri> dependencies);

  /// Adds metadata to be passed to `build.dart` invocations of dependent
  /// packages.
  void addMetadata(String key, Object value);

  /// The version of [BuildOutput].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through `build.dart` invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the YAML
  /// representation in the protocol.
  static Version get version => model.BuildOutput.version;

  /// Write out this build output to a file inside [outDir].
  Future<void> writeToFile({required Uri outDir});
}
