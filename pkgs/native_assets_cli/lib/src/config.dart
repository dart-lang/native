// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert' hide json;
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:pub_semver/pub_semver.dart';

import 'api/deprecation_messages.dart';
import 'code_assets/architecture.dart';
import 'code_assets/os.dart';
import 'encoded_asset.dart';
import 'json_utils.dart';
import 'metadata.dart';
import 'utils/datetime.dart';
import 'utils/json.dart';

/// The shared properties of a [LinkInput] and a [BuildInput].
///
/// This abstraction makes it easier to design APIs intended for both kinds of
/// build hooks, building and linking.
sealed class HookInput {
  /// The underlying json configuration of this [HookInput].
  final Map<String, Object?> json;

  /// The version of the [HookInput].
  final Version version;

  /// The directory in which output and intermediate artifacts that are unique
  /// to the [config] can be placed.
  ///
  /// This directory is unique per hook and per [config].
  ///
  /// The contents of this directory will not be modified by anything else than
  /// the hook itself.
  ///
  /// The invoker of the the hook will ensure concurrent invocations wait on
  /// each other.
  final Uri outputDirectory;

  /// The directory in which shared output and intermediate artifacts can be
  /// placed.
  ///
  /// This directory is unique per hook.
  ///
  /// The contents of this directory will not be modified by anything else than
  /// the hook itself.
  ///
  /// The invoker of the the hook will ensure concurrent invocations wait on
  /// each other.
  final Uri outputDirectoryShared;

  /// The name of the package the assets are built for.
  final String packageName;

  /// The root of the package the assets are built for.
  ///
  /// Often a package's assets are built because a package is a dependency of
  /// another. For this it is convenient to know the packageRoot.
  final Uri packageRoot;

  HookInput(this.json)
      : version = switch (Version.parse(json.string(_versionKey))) {
          final Version version => (version.major != latestVersion.major ||
                  version < latestParsableVersion)
              ? throw FormatException(
                  'Only compatible versions with $latestVersion are supported '
                  '(was: $version).')
              : version,
        },
        outputDirectory = json.path(_outDirInputKey),
        outputDirectoryShared = json.path(_outDirSharedInputKey),
        packageRoot = json.path(_packageRootInputKey),
        packageName = json.string(_packageNameInputKey);

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(json);

  HookConfig get config => HookConfig(json);
}

sealed class HookInputBuilder {
  final Map<String, Object?> json = {
    'version': latestVersion.toString(),
  };

  void setupShared({
    required Uri packageRoot,
    required String packageName,
    required Uri outputDirectory,
    required Uri outputDirectoryShared,
  }) {
    json[_packageNameInputKey] = packageName;
    json[_packageRootInputKey] = packageRoot.toFilePath();
    json[_outDirInputKey] = outputDirectory.toFilePath();
    json[_outDirSharedInputKey] = outputDirectoryShared.toFilePath();
  }

  /// Constructs a checksum for a [BuildInput].
  ///
  /// This can be used to construct an output directory name specific to the
  /// [BuildInput] being built with this [BuildInputBuilder]. It is therefore
  /// assumed the output directory has not been set yet.
  String computeChecksum() {
    if (json.containsKey(_outDirInputKey) ||
        json.containsKey(_outDirSharedInputKey) ||
        json.containsKey(_assetsKey)) {
      // The bundling tools would first calculate the checksum, create an output
      // directory and then call [setupHookInput].
      // The output directory should not depend on the assets passed in for
      // linking.
      throw StateError('The checksum should be generated before setting '
          'up the hook configuration');
    }
    final hash = sha256
        .convert(const JsonEncoder().fuse(const Utf8Encoder()).convert(json))
        .toString()
        // 256 bit hashes lead to 64 hex character strings.
        // To avoid overflowing file paths limits, only use 32.
        // Using 16 hex characters would also be unlikely to have collisions.
        .substring(0, 32);
    return hash;
  }

  HookConfigBuilder get config => HookConfigBuilder._(this);
}

// TODO: Bump min-SDK constraint to 3.7 and remove once stable.
const _buildModeInputKeyDeprecated = 'build_mode';
const _metadataConfigKey = 'metadata';
const _outDirInputKey = 'out_dir';
const _outDirSharedInputKey = 'out_dir_shared';
const _packageNameInputKey = 'package_name';
const _packageRootInputKey = 'package_root';
const _supportedAssetTypesKey = 'supported_asset_types';
const _buildAssetTypesKey = 'build_asset_types';

final class BuildInput extends HookInput {
  final Map<String, Metadata> metadata;

  BuildInput(super.json)
      : metadata = {
          for (final entry
              in (json.optionalMap(_dependencyMetadataKey) ?? {}).entries)
            entry.key: Metadata.fromJson(as<Map<String, Object?>>(entry.value)),
        };

  Object? metadatum(String packageName, String key) =>
      metadata[packageName]?.metadata[key];

  @override
  BuildConfig get config => BuildConfig(json);
}

final class BuildInputBuilder extends HookInputBuilder {
  void setupBuildInput({
    Map<String, Metadata> metadata = const {},
  }) {
    json[_dependencyMetadataKey] = {
      for (final key in metadata.keys) key: metadata[key]!.toJson(),
    };
  }

  @override
  BuildConfigBuilder get config => BuildConfigBuilder._(this);
}

final class HookConfigBuilder {
  final HookInputBuilder builder;

  Map<String, Object?> get json => builder.json;

  HookConfigBuilder._(this.builder);

  void setupShared({
    required List<String> buildAssetTypes,
  }) {
    json[_buildAssetTypesKey] = buildAssetTypes;
    json[_supportedAssetTypesKey] = buildAssetTypes;
  }
}

final class BuildConfigBuilder extends HookConfigBuilder {
  BuildConfigBuilder._(super.builder) : super._();
}

extension BuildConfigBuilderSetup on BuildConfigBuilder {
  void setupBuild({
    required bool dryRun,
    required bool linkingEnabled,
  }) {
    json[_dryRunConfigKey] = dryRun;
    json[_linkingEnabledKey] = linkingEnabled;

    // TODO: Bump min-SDK constraint to 3.7 and remove once stable.
    if (!dryRun) {
      json[_buildModeInputKeyDeprecated] = 'release';
    }
  }
}

const _dryRunConfigKey = 'dry_run';
const _linkingEnabledKey = 'linking_enabled';

final class LinkInput extends HookInput {
  final List<EncodedAsset> _encodedAssets;

  final Uri? recordedUsagesFile;

  LinkInput(super.json)
      : _encodedAssets =
            _parseAssets(json.getOptional<List<Object?>>(_assetsKey)),
        recordedUsagesFile = json.optionalPath(_recordedUsagesFileInputKey);

  LinkInputAssets get assets => LinkInputAssets._(this);
}

extension type LinkInputAssets._(LinkInput _input) {
  List<EncodedAsset> get encodedAssets => _input._encodedAssets;
}

final class LinkInputBuilder extends HookInputBuilder {
  void setupLink({
    required List<EncodedAsset> assets,
    required Uri? recordedUsesFile,
  }) {
    json[_assetsKey] = [for (final asset in assets) asset.toJson()];
    // TODO: Bump min-SDK constraint to 3.7 and remove once stable.
    json[_buildModeInputKeyDeprecated] = 'release';
    if (recordedUsesFile != null) {
      json[_recordedUsagesFileInputKey] = recordedUsesFile.toFilePath();
    }
  }
}

List<EncodedAsset> _parseAssets(List<Object?>? object) => object == null
    ? []
    : [
        for (int i = 0; i < object.length; ++i)
          EncodedAsset.fromJson(object.mapAt(i)),
      ];

const _recordedUsagesFileInputKey = 'resource_identifiers';
const _assetsKey = 'assets';
const _versionKey = 'version';

sealed class HookOutput {
  /// The underlying json configuration of this [HookOutput].
  final Map<String, Object?> json;

  /// The version of the [HookInput].
  final Version version;

  /// Start time for the build of this output.
  ///
  /// The [timestamp] is rounded down to whole seconds, because
  /// [File.lastModified] is rounded to whole seconds and caching logic compares
  /// these timestamps.
  final DateTime timestamp;

  /// The files used by this build.
  ///
  /// If any of the files in [dependencies] are modified after [timestamp], the
  /// build will be re-run.
  ///
  /// The (transitive) Dart sources do not have to be added to these
  /// dependencies, only non-Dart files. (Note that old Dart and Flutter SDKs
  /// do not automatically add the Dart sources. So builds get wrongly cached,
  /// try updating to the latest release.)
  final List<Uri> dependencies;

  HookOutput(this.json)
      : version = switch (Version.parse(json.string(_versionKey))) {
          final Version version => (version.major != latestVersion.major ||
                  version < latestParsableVersion)
              ? throw FormatException(
                  'Only compatible versions with $latestVersion are supported '
                  '(was: $version).')
              : version,
        },
        timestamp = DateTime.parse(json.string(_timestampKey)),
        dependencies = _parseDependencies(json.optionalList(_dependenciesKey));

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(json);
}

List<Uri> _parseDependencies(List<Object?>? list) {
  if (list == null) return const [];
  return [
    for (int i = 0; i < list.length; ++i) list.pathAt(i),
  ];
}

const String _timestampKey = 'timestamp';
const String _dependenciesKey = 'dependencies';

sealed class HookOutputBuilder {
  final Map<String, Object?> json = {};

  HookOutputBuilder() {
    json[_versionKey] = latestVersion.toString();
    json[_timestampKey] = DateTime.now().roundDownToSeconds().toString();
    json[_dependenciesKey] = [];
  }

  /// Adds file used by this build.
  ///
  /// If any of the files are modified after [BuildOutput.timestamp], the
  // build will be  re-run.
  void addDependency(Uri uri) {
    final dependencies = json[_dependenciesKey] as List;
    dependencies.add(uri.toFilePath());
  }

  /// Adds files used by this build.
  ///
  /// If any of the files are modified after [BuildOutput.timestamp], the
  // build will be  re-run.
  void addDependencies(Iterable<Uri> uris) {
    final dependencies = json[_dependenciesKey] as List;
    dependencies.addAll(uris.map((uri) => uri.toFilePath()));
  }
}

class BuildOutput extends HookOutput {
  /// The assets produced by this build.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  final List<EncodedAsset> _encodedAssets;

  /// The assets produced by this build which should be linked.
  ///
  /// Every key in the map is a package name. These assets in the values are not
  /// bundled with the application, but are sent to the link hook of the package
  /// specified in the key, which can decide if they are bundled or not.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  final Map<String, List<EncodedAsset>> _encodedAssetsForLinking;

  /// Metadata passed to dependent build hook invocations.
  final Metadata metadata;

  /// Creates a [BuildOutput] from the given [json].
  BuildOutput(super.json)
      : _encodedAssets = _parseEncodedAssets(json.optionalList(_assetsKey)),
        _encodedAssetsForLinking = {
          for (final MapEntry(:key, :value)
              in (json.optionalMap(_assetsForLinkingKey) ?? {}).entries)
            key: _parseEncodedAssets(value as List<Object?>),
        },
        metadata =
            Metadata.fromJson(json.optionalMap(_metadataConfigKey) ?? {});

  BuildOutputAssets get assets => BuildOutputAssets._(this);
}

extension type BuildOutputAssets._(BuildOutput _output) {
  /// The assets produced by this build.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  List<EncodedAsset> get encodedAssets => _output._encodedAssets;

  /// The assets produced by this build which should be linked.
  ///
  /// Every key in the map is a package name. These assets in the values are not
  /// bundled with the application, but are sent to the link hook of the package
  /// specified in the key, which can decide if they are bundled or not.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  Map<String, List<EncodedAsset>> get encodedAssetsForLinking =>
      _output._encodedAssetsForLinking;
}

List<EncodedAsset> _parseEncodedAssets(List<Object?>? json) => json == null
    ? const []
    : [
        for (int i = 0; i < json.length; ++i)
          EncodedAsset.fromJson(json.mapAt(i)),
      ];

const _assetsForLinkingKey = 'assetsForLinking';
const _dependencyMetadataKey = 'dependency_metadata';

/// Builder to produce the output of a build hook.
///
/// There are various Dart extensions on this [BuildOutputBuilder] that allow
/// adding specific asset types - which should be used by normal hook authors.
/// For example
///
/// ```dart
/// main(List<String> arguments) async {
///   await build((input, output) {
///     output.assets.code.add(CodeAsset(...));
///     output.assets.data.add(DataAsset(...));
///   });
/// }
/// ```
class BuildOutputBuilder extends HookOutputBuilder {
  /// Adds metadata to be passed to build hook invocations of dependent
  /// packages.
  @Deprecated(metadataDeprecation)
  void addMetadatum(String key, Object value) {
    var map = json[_metadataConfigKey] as Map<String, Object?>?;
    map ??= json[_metadataConfigKey] = <String, Object?>{};
    map[key] = value;
  }

  /// Adds metadata to be passed to build hook invocations of dependent
  /// packages.
  @Deprecated(metadataDeprecation)
  void addMetadata(Map<String, Object> metadata) {
    var map = json[_metadataConfigKey] as Map<String, Object?>?;
    map ??= json[_metadataConfigKey] = <String, Object?>{};
    map.addAll(metadata);
  }

  EncodedAssetBuildOutputBuilder get assets =>
      EncodedAssetBuildOutputBuilder._(this);
}

extension type EncodedAssetBuildOutputBuilder._(BuildOutputBuilder _output) {
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
  ///   await build((input, output) {
  ///     output.assets.code.add(CodeAsset(...));
  ///     output.assets.data.add(DataAsset(...));
  ///   });
  /// }
  /// ```
  void addEncodedAsset(EncodedAsset asset, {String? linkInPackage}) {
    final list = _getEncodedAssetsList(_output.json, linkInPackage);
    list.add(asset.toJson());
  }

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
  ///   await build((input, output) {
  ///     output.assets.code.addAll([CodeAsset(...), ...]);
  ///     output.assets.data.addAll([DataAsset(...), ...]);
  ///   });
  /// }
  /// ```
  void addEncodedAssets(
    Iterable<EncodedAsset> assets, {
    String? linkInPackage,
  }) {
    final list = _getEncodedAssetsList(_output.json, linkInPackage);
    for (final asset in assets) {
      list.add(asset.toJson());
    }
  }
}

List<Object?> _getEncodedAssetsList(
  Map<String, Object?> json,
  String? linkInPackage,
) {
  if (linkInPackage == null) {
    var list = json[_assetsKey] as List?;
    list ??= json[_assetsKey] = <Map<String, Object?>>[];
    return list;
  }
  var map = json[_assetsForLinkingKey] as Map<String, Object?>?;
  map ??= json[_assetsForLinkingKey] = <String, Object?>{};

  var list = map[linkInPackage] as List?;
  list ??= map[linkInPackage] = <Map<String, Object?>>[];
  return list;
}

class LinkOutput extends HookOutput {
  /// The assets produced by this build.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  final List<EncodedAsset> _encodedAssets;

  /// Creates a [BuildOutput] from the given [json].
  LinkOutput(super.json)
      : _encodedAssets = _parseEncodedAssets(json.optionalList(_assetsKey));

  LinkOutputAssets get assets => LinkOutputAssets._(this);
}

extension type LinkOutputAssets._(LinkOutput _output) {
  /// The assets produced by this build.
  ///
  /// In dry runs, the assets for all [Architecture]s for the [OS] specified in
  /// the dry run must be provided.
  List<EncodedAsset> get encodedAssets => _output._encodedAssets;
}

/// Builder to produce the output of a link hook.
///
/// There are various Dart extensions on this [LinkOutputBuilder] that allow
/// adding specific asset types - which should be used by normal hook authors.
/// For example
///
/// ```dart
/// main(List<String> arguments) async {
///   await build((input, output) {
///     output.assets.code.add(CodeAsset(...));
///     output.assets.data.add(DataAsset(...));
///   });
/// }
/// ```
class LinkOutputBuilder extends HookOutputBuilder {
  EncodedAssetLinkOutputBuilder get assets =>
      EncodedAssetLinkOutputBuilder._(this);
}

/// Extension for the lower-level API to add [EncodedAsset]s to
/// [BuildOutputBuilder].
extension type EncodedAssetLinkOutputBuilder._(LinkOutputBuilder _builder) {
  /// Adds [EncodedAsset]s produced by this build.
  ///
  /// Note to hook writers. Prefer using the `.add` method on the extension for
  /// the specific asset type being added:
  ///
  /// ```dart
  /// main(List<String> arguments) async {
  ///   await build((input, output) {
  ///     output.assets.code.add(CodeAsset(...));
  ///     output.assets.data.add(DataAsset(...));
  ///   });
  /// }
  /// ```
  void addEncodedAsset(EncodedAsset asset) {
    var list = _builder.json[_assetsKey] as List?;
    list ??= _builder.json[_assetsKey] = <Map<String, Object?>>[];
    list.add(asset.toJson());
  }

  /// Adds [EncodedAsset]s produced by this build.
  ///
  /// Note to hook writers. Prefer using the `.addAll` method on the extension
  /// for the specific asset type being added:
  ///
  /// ```dart
  /// main(List<String> arguments) async {
  ///   await build((input, output) {
  ///     output.assets.code.addAll([CodeAsset(...), ...]);
  ///     output.assets.data.addAll([DataAsset(...), ...]);
  ///   });
  /// }
  /// ```
  void addEncodedAssets(Iterable<EncodedAsset> assets) {
    var list = _builder.json[_assetsKey] as List?;
    list ??= _builder.json[_assetsKey] = <Map<String, Object?>>[];
    for (final asset in assets) {
      list.add(asset.toJson());
    }
  }
}

/// The latest supported input version.
///
/// We'll never bump the major version. Removing old keys from the input and
/// output is done via modifying [latestParsableVersion].
final latestVersion = Version(1, 6, 0);

/// The parser can deal with inputs and outputs down to this version.
///
/// This version can be bumped when:
///
/// 1. The stable version of Dart / Flutter uses a newer version _and_ the SDK
///    constraint is bumped in the pubspec of this package to that stable
///    version. (This prevents input parsing from failing.)
/// 2. A stable version of this package is published uses a newer version, _and_
///    most users have migrated to it. (This prevents the output parsing from
///    failing.)
///
/// When updating this number, update the version_skew_test.dart. (This test
/// catches issues with 2.)
final latestParsableVersion = Version(1, 5, 0);

final class HookConfig {
  final Map<String, Object?> json;

  /// The asset types that the invoker of this hook supports.
  final List<String> buildAssetTypes;

  HookConfig(this.json)
      : buildAssetTypes = json.optionalStringList(_buildAssetTypesKey) ??
            json.optionalStringList(_supportedAssetTypesKey) ??
            const [];
}

final class BuildConfig extends HookConfig {
  // TODO(dcharkes): Remove after 3.7.0 stable is released and bump the SDK
  // constraint in the pubspec. Ditto for all uses in related packages.
  /// Whether this run is a dry-run, which doesn't build anything.
  ///
  /// A dry-run only reports information about which assets a build would
  /// create, but doesn't actually create files.
  @Deprecated('Flutter will no longer invoke dry run as of 3.28.')
  final bool dryRun;

  final bool linkingEnabled;

  BuildConfig(super.json)
      // ignore: deprecated_member_use_from_same_package
      : dryRun = json.getOptional<bool>(_dryRunConfigKey) ?? false,
        linkingEnabled = json.get<bool>(_linkingEnabledKey);
}
