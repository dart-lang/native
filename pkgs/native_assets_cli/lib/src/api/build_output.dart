// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../architecture.dart';
import '../encoded_asset.dart';
import '../json_utils.dart';
import '../model/dependencies.dart';
import '../model/metadata.dart';
import '../os.dart';
import '../utils/datetime.dart';
import '../utils/file.dart';
import '../utils/json.dart';
import '../utils/map.dart';
import 'build.dart';
import 'build_config.dart';
import 'builder.dart';
import 'deprecation_messages.dart';
import 'hook_config.dart';
import 'link.dart';
import 'linker.dart';

part '../model/hook_output.dart';
part 'link_output.dart';

/// The output of a build hook (`hook/build.dart`) invocation.
///
/// A package can optionally provide build hook (`hook/build.dart`). If such a
/// hook exists, it will be automatically run, by the Flutter and Dart SDK
/// tools. The hook is expect to produce a specific output which [BuildOutput]
/// can produce.
///
/// For more information see [build].
///
/// Designed to be a sink. The [BuildOutput] is not intended to be read from.
/// [Builder]s stream outputs to the build output. For more info see [Builder].
abstract final class BuildOutput {
  /// Start time for the build of this output.
  ///
  /// The [timestamp] is rounded down to whole seconds, because
  /// [File.lastModified] is rounded to whole seconds and caching logic compares
  /// these timestamps.
  DateTime get timestamp;

  /// The assets produced by this build.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  Iterable<EncodedAsset> get encodedAssets;

  /// The assets produced by this build which should be linked.
  ///
  /// Every key in the map is a package name. These assets in the values are not
  /// bundled with the application, but are sent to the link hook of the package
  /// specified in the key, which can decide if they are bundled or not.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  Map<String, Iterable<EncodedAsset>> get encodedAssetsForLinking;

  /// The files used by this build.
  ///
  /// If any of the files in [dependencies] are modified after [timestamp], the
  /// build will be re-run.
  ///
  /// The (transitive) Dart sources do not have to be added to these
  /// dependencies, only non-Dart files. (Note that old Dart and Flutter SDKs
  /// do not automatically add the Dart sources. So builds get wrongly cached,
  /// try updating to the latest release.)
  Iterable<Uri> get dependencies;

  /// Create a build output.
  ///
  /// The [timestamp] must be before any [dependencies] are read by the build
  /// this output belongs to. If the [BuildOutput] object is created at the
  /// beginning of the build hook, [timestamp] can be omitted and will default
  /// to [DateTime.now]. The [timestamp] is rounded down to whole seconds,
  /// because [File.lastModified] is rounded to whole seconds and caching logic
  /// compares these timestamps.
  ///
  /// The [EncodedAsset]s produced by this build or dry-run can be provided to
  /// the constructor as [encodedAssets], or can be added later using
  /// [addEncodedAsset] and [addEncodedAssets].
  ///
  /// The files used by this build must be provided to the constructor as
  /// [dependencies], or can be added later with [addDependency] and
  /// [addDependencies]. If any of these files are modified after [timestamp],
  /// the build will be re-run. Typically these dependencies contain the build
  /// hook itself, and the source files used in the build.
  ///
  /// Metadata can be passed to build hook invocations of dependent packages. It
  /// must be provided to the constructor as [metadata], or added later with
  // ignore: deprecated_member_use_from_same_package
  /// [addMetadatum] and [addMetadata].
  factory BuildOutput({
    DateTime? timestamp,
    Iterable<EncodedAsset>? encodedAssets,
    Iterable<Uri>? dependencies,
    @Deprecated(metadataDeprecation) Map<String, Object>? metadata,
  }) =>
      HookOutputImpl(
        timestamp: timestamp,
        encodedAssets: encodedAssets?.toList(),
        dependencies: Dependencies([...?dependencies]),
        metadata: Metadata({...?metadata}),
      );

  /// Adds [EncodedAsset]s produced by this build or dry run.
  ///
  /// If the [linkInPackage] argument is specified, the asset will not be
  /// bundled during the build step, but sent as input to the link hook of the
  /// specified package, where it can be further processed and possibly bundled.
  ///
  /// Note to hook writers. Prefer using the `.add` method on the extension for
  /// the specific asset type being added:
  ///
  /// ```dart
  /// main(List<String> arguments) async {
  ///   await build((config, output) {
  ///     output.codeAssets.add(CodeAsset(...));
  ///     output.dataAssets.add(DataAsset(...));
  ///   });
  /// }
  /// ```
  void addEncodedAsset(EncodedAsset asset, {String? linkInPackage});

  /// Adds [EncodedAsset]s produced by this build or dry run.
  ///
  /// If the [linkInPackage] argument is specified, the assets will not be
  /// bundled during the build step, but sent as input to the link hook of the
  /// specified package, where they can be further processed and possibly
  /// bundled.
  ///
  /// Note to hook writers. Prefer using the `.addAll` method on the extension
  /// for the specific asset type being added:
  ///
  /// ```dart
  /// main(List<String> arguments) async {
  ///   await build((config, output) {
  ///     output.codeAssets.addAll([CodeAsset(...), ...]);
  ///     output.dataAssets.addAll([DataAsset(...), ...]);
  ///   });
  /// }
  /// ```
  void addEncodedAssets(Iterable<EncodedAsset> assets, {String? linkInPackage});

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

  /// Adds metadata to be passed to build hook invocations of dependent
  /// packages.
  @Deprecated(metadataDeprecation)
  void addMetadatum(String key, Object value);

  /// Adds metadata to be passed to build hook invocations of dependent
  /// packages.
  @Deprecated(metadataDeprecation)
  void addMetadata(Map<String, Object> metadata);

  /// The version of [BuildOutput].
  ///
  /// The build output is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  static Version get latestVersion => HookOutputImpl.latestVersion;
}
