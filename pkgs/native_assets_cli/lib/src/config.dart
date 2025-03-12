// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert' hide json;
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:pub_semver/pub_semver.dart';

import '../code_assets.dart';
import 'api/deprecation_messages.dart';
import 'data_assets/data_asset.dart';
import 'encoded_asset.dart';
import 'hook/syntax.g.dart' as syntax;
import 'metadata.dart';
import 'utils/datetime.dart';
import 'utils/json.dart';

/// The shared properties of a [LinkInput] and a [BuildInput].
///
/// This abstraction makes it easier to design APIs intended for both kinds of
/// build hooks, building and linking.
sealed class HookInput {
  /// The underlying json configuration of this [HookInput].
  Map<String, Object?> get json => _syntax.json;

  /// The version of the [HookInput].
  Version get version => Version.parse(_syntax.version);

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
  Uri get outputDirectory => _syntax.outDir;

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
  Uri get outputDirectoryShared => _syntax.outDirShared;

  /// The file to write the [HookOutput] to at the end of a hook invocation.
  Uri get outputFile;

  /// The name of the package the assets are built for.
  String get packageName => _syntax.packageName;

  /// The root of the package the assets are built for.
  ///
  /// Often a package's assets are built because a package is a dependency of
  /// another. For this it is convenient to know the packageRoot.
  Uri get packageRoot => _syntax.packageRoot;

  final syntax.HookInput _syntax;

  HookInput(Map<String, Object?> json)
    : _syntax = syntax.HookInput.fromJson(json) {
    if (version.major != latestVersion.major ||
        version < latestParsableVersion) {
      throw FormatException(
        'Only compatible versions with $latestVersion are supported '
        '(was: $version).',
      );
    }
    // Trigger validation, remove with cleanup.
    outputDirectory;
    outputDirectoryShared;
  }

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(json);

  HookConfig get config => HookConfig._(this);
}

sealed class HookInputBuilder {
  final _syntax =
      syntax.HookInput.fromJson({})
        ..version = latestVersion.toString()
        ..config = syntax.Config.fromJson({});

  Map<String, Object?> get json => _syntax.json;

  void setupShared({
    required Uri packageRoot,
    required String packageName,
    required Uri outputDirectory,
    required Uri outputDirectoryShared,
    required Uri outputFile,
  }) {
    _syntax.version = latestVersion.toString();
    _syntax.packageRoot = packageRoot;
    _syntax.packageName = packageName;
    _syntax.outDir = outputDirectory;
    _syntax.outDirShared = outputDirectoryShared;
    _syntax.outFile = outputFile;
  }

  /// Constructs a checksum for a [BuildInput].
  ///
  /// This can be used to construct an output directory name specific to the
  /// [BuildInput] being built with this [BuildInputBuilder]. It is therefore
  /// assumed the output directory has not been set yet.
  String computeChecksum() {
    final config = _syntax.config.json;
    final hash = sha256
        .convert(const JsonEncoder().fuse(const Utf8Encoder()).convert(config))
        .toString()
        // 256 bit hashes lead to 64 hex character strings.
        // To avoid overflowing file paths limits, only use 32.
        // Using 16 hex characters would also be unlikely to have collisions.
        .substring(0, 32);
    return hash;
  }

  HookConfigBuilder get config => HookConfigBuilder._(this);
}

final class BuildInput extends HookInput {
  Map<String, Metadata> get metadata => {
    for (final entry in (_syntaxBuildInput.dependencyMetadata ?? {}).entries)
      entry.key: Metadata.fromJson(as<Map<String, Object?>>(entry.value)),
  };

  @override
  Uri get outputFile =>
      _syntax.outFile ?? _syntax.outDir.resolve('build_output.json');

  final syntax.BuildInput _syntaxBuildInput;

  BuildInput(super.json)
    : _syntaxBuildInput = syntax.BuildInput.fromJson(json) {
    // Run validation.
    metadata;
  }

  Object? metadatum(String packageName, String key) =>
      metadata[packageName]?.metadata[key];

  @override
  BuildConfig get config => BuildConfig._(this);
}

final class BuildInputBuilder extends HookInputBuilder {
  @override
  syntax.BuildInput get _syntax =>
      syntax.BuildInput.fromJson(super._syntax.json);

  void setupBuildInput({Map<String, Metadata> metadata = const {}}) {
    if (metadata.isEmpty) {
      return;
    }
    _syntax.setup(
      dependencyMetadata: {
        for (final key in metadata.keys) key: metadata[key]!.toJson(),
      },
    );
  }

  @override
  BuildConfigBuilder get config => BuildConfigBuilder._(this);
}

final class HookConfigBuilder {
  final HookInputBuilder builder;

  HookConfigBuilder._(this.builder);

  syntax.Config get _syntax => builder._syntax.config;

  void setupShared({required List<String> buildAssetTypes}) {
    _syntax.buildAssetTypes = buildAssetTypes;
  }
}

final class BuildConfigBuilder extends HookConfigBuilder {
  @override
  late final syntax.BuildConfig _syntax = syntax.BuildConfig.fromJson(
    super._syntax.json,
  );

  BuildConfigBuilder._(super.builder) : super._();
}

extension BuildConfigBuilderSetup on BuildConfigBuilder {
  void setupBuild({required bool linkingEnabled}) {
    _syntax.setup(linkingEnabled: linkingEnabled);
  }
}

final class LinkInput extends HookInput {
  List<EncodedAsset> get _encodedAssets {
    final assets = _syntaxLinkInput.assets;
    return _parseAssets(assets);
  }

  Uri? get recordedUsagesFile => _syntaxLinkInput.resourceIdentifiers;

  @override
  Uri get outputFile =>
      _syntax.outFile ?? _syntax.outDir.resolve('link_output.json');

  final syntax.LinkInput _syntaxLinkInput;

  LinkInput(super.json) : _syntaxLinkInput = syntax.LinkInput.fromJson(json) {
    // Run validation.
    _encodedAssets;
  }

  LinkInputAssets get assets => LinkInputAssets._(this);
}

extension type LinkInputAssets._(LinkInput _input) {
  List<EncodedAsset> get encodedAssets => _input._encodedAssets;
}

final class LinkInputBuilder extends HookInputBuilder {
  @override
  syntax.LinkInput get _syntax => syntax.LinkInput.fromJson(super._syntax.json);

  void setupLink({
    required List<EncodedAsset> assets,
    required Uri? recordedUsesFile,
  }) {
    _syntax.setup(
      assets: [
        for (final asset in assets) syntax.Asset.fromJson(asset.toJson()),
      ],
      resourceIdentifiers: recordedUsesFile,
    );
  }
}

List<EncodedAsset> _parseAssets(List<syntax.Asset>? assets) =>
    assets == null
        ? []
        : [for (final asset in assets) EncodedAsset.fromJson(asset.json)];

sealed class HookOutput {
  /// The underlying json configuration of this [HookOutput].
  Map<String, Object?> get json => _syntax.json;

  /// The version of the [HookInput].
  Version get version => Version.parse(_syntax.version);

  /// Start time for the build of this output.
  ///
  /// The [timestamp] is rounded down to whole seconds, because
  /// [File.lastModified] is rounded to whole seconds and caching logic compares
  /// these timestamps.
  DateTime get timestamp => DateTime.parse(_syntax.timestamp);

  /// The files used by this build.
  ///
  /// If any of the files in [dependencies] are modified after [timestamp], the
  /// build will be re-run.
  ///
  /// The (transitive) Dart sources do not have to be added to these
  /// dependencies, only non-Dart files. (Note that old Dart and Flutter SDKs
  /// do not automatically add the Dart sources. So builds get wrongly cached,
  /// try updating to the latest release.)
  List<Uri> get dependencies => _syntax.dependencies ?? [];

  /// The assets produced by this build.
  List<EncodedAsset> get _encodedAssets => _parseAssets(_syntax.assets);

  syntax.HookOutput get _syntax;

  HookOutput._(Map<String, Object?> json) {
    if (version.major != latestVersion.major ||
        version < latestParsableVersion) {
      throw FormatException(
        'Only compatible versions with $latestVersion are supported '
        '(was: $version).',
      );
    }
  }

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(json);
}

sealed class HookOutputBuilder {
  final _syntax = syntax.HookOutput(
    timestamp: DateTime.now().roundDownToSeconds().toString(),
    version: latestVersion.toString(),
  );

  Map<String, Object?> get json => _syntax.json;

  HookOutputBuilder();

  /// Adds file used by this build.
  ///
  /// If any of the files are modified after [BuildOutput.timestamp], the
  // build will be  re-run.
  void addDependency(Uri uri) {
    final dependencies = _syntax.dependencies ?? [];
    dependencies.add(uri);
    _syntax.dependencies = dependencies;
  }

  /// Adds files used by this build.
  ///
  /// If any of the files are modified after [BuildOutput.timestamp], the
  // build will be  re-run.
  void addDependencies(Iterable<Uri> uris) {
    final dependencies = _syntax.dependencies ?? [];
    dependencies.addAll(uris);
    _syntax.dependencies = dependencies;
  }
}

class BuildOutput extends HookOutput {
  /// The assets produced by this build which should be linked.
  ///
  /// Every key in the map is a package name. These assets in the values are not
  /// bundled with the application, but are sent to the link hook of the package
  /// specified in the key, which can decide if they are bundled or not.
  Map<String, List<EncodedAsset>> get _encodedAssetsForLinking => {
    for (final MapEntry(:key, :value)
        in (_syntax.assetsForLinking ?? {}).entries)
      key: _parseAssets(value),
  };

  /// Metadata passed to dependent build hook invocations.
  Metadata get metadata => Metadata(_syntax.metadata ?? {});

  @override
  final syntax.BuildOutput _syntax;

  /// Creates a [BuildOutput] from the given [json].
  BuildOutput(super.json)
    : _syntax = syntax.BuildOutput.fromJson(json),
      super._();

  BuildOutputAssets get assets => BuildOutputAssets._(this);
}

extension type BuildOutputAssets._(BuildOutput _output) {
  /// The assets produced by this build.
  List<EncodedAsset> get encodedAssets => _output._encodedAssets;

  /// The assets produced by this build which should be linked.
  ///
  /// Every key in the map is a package name. These assets in the values are not
  /// bundled with the application, but are sent to the link hook of the package
  /// specified in the key, which can decide if they are bundled or not.
  Map<String, List<EncodedAsset>> get encodedAssetsForLinking =>
      _output._encodedAssetsForLinking;
}

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
    final metadata = _syntax.metadata ?? {};
    metadata[key] = value;
    metadata.sortOnKey();
    _syntax.metadata = metadata;
  }

  /// Adds metadata to be passed to build hook invocations of dependent
  /// packages.
  @Deprecated(metadataDeprecation)
  void addMetadata(Map<String, Object> metadata) {
    final value = _syntax.metadata ?? {};
    value.addAll(metadata);
    value.sortOnKey();
    _syntax.metadata = value;
  }

  EncodedAssetBuildOutputBuilder get assets =>
      EncodedAssetBuildOutputBuilder._(this);

  @override
  syntax.BuildOutput get _syntax =>
      syntax.BuildOutput.fromJson(super._syntax.json);
}

extension DataAssetsDirectoryExtension on BuildOutputBuilder {
  /// Extension on [BuildOutput] to handle data asset directories and files.
  ///
  /// This extension provides a convenient way for build hooks to add
  /// [DataAsset] dependencies from one or more directories or individual files.
  ///
  /// If any specified path does not exist, a [FileSystemException] is thrown.
  /// Any error during the directory listing is caught and rethrown with
  /// additional context.
  Future<void> addDataAssetDirectories(
    List<String> paths, {
    required BuildInput input,
  }) async {
    final packageName = input.packageName;
    final packageRoot = input.packageRoot;
    for (final path in paths) {
      final resolvedUri = packageRoot.resolve('$packageName/$path');
      final directory = Directory.fromUri(resolvedUri);
      final file = File.fromUri(resolvedUri);

      if (await directory.exists()) {
        // Process as a directory.
        addDependency(directory.uri);
        try {
          await for (final entity in directory.list(
            recursive: true,
            followLinks: false,
          )) {
            // Add dependency for every file and directory found.
            addDependency(entity.uri);
          }
        } on FileSystemException catch (e) {
          throw FileSystemException(
            'Error reading directory "$path": ${e.message}',
            directory.path,
            e.osError,
          );
        }
      } else if (await file.exists()) {
        addDependency(file.parent.uri);
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

extension AddFoundCodeAssetsExtension on BuildOutputBuilder {
  /// Searches recursively through the entire expected output directory
  /// for native library files that match the expected target filename
  /// based on a list of asset mappings. An output directory can be optionally
  /// provided, otherwise the output directory from the input is used.
  ///
  /// Each mapping in [assetMappings] is a Map with a single key-value pair
  /// where:
  /// - The key represents the filename (given without prefix and extension) to
  ///   search for.
  /// - The value represents the linked CodeAsset name that should be used.
  ///
  /// The expected filename is computed using the current operating system's
  /// naming conventions and a concrete [LinkMode] derived from the input's
  /// link preference.
  ///
  /// For each file that ends with the computed library filename for one of the
  /// provided mappings, a [CodeAsset] is created and added via
  /// [addEncodedAsset] if it hasn't already been added.
  ///
  /// Returns a list of URIs corresponding to all the added code assets.
  Future<List<Uri>> addFoundCodeAssets({
    required BuildInput input,
    required List<Map<String, String>> assetMappings,
    Uri? outputDirectory,
  }) async {
    final linkMode = getLinkMode(input);
    final outDir = outputDirectory ?? input.outputDirectory;
    final searchDir = Directory.fromUri(outDir);
    final addedPaths = <String>{};
    final foundFiles = <Uri>[];

    await for (final entity in searchDir.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final filePath = entity.path;
      // Iterate over each mapping in the list.
      for (final mapping in assetMappings) {
        for (final entry in mapping.entries) {
          final searchName = entry.key;
          final assetName = entry.value;
          final expectedLibName = input.config.code.targetOS.libraryFileName(
            searchName,
            linkMode,
          );
          if (filePath.endsWith(expectedLibName)) {
            if (addedPaths.contains(filePath)) break;
            addEncodedAsset(
              CodeAsset(
                package: input.packageName,
                name: assetName,
                linkMode: linkMode,
                os: input.config.code.targetOS,
                file: entity.uri,
                architecture: input.config.code.targetArchitecture,
              ),
            );
            addedPaths.add(filePath);
            foundFiles.add(entity.uri);
            // Once a file matches one mapping, no need to check further.
            break;
          }
        }
      }
    }
    return foundFiles;
  }

  /// Adds a [CodeAsset] by converting it into an encoded asset and appending
  /// it to the internal list of assets.
  /// Checks if an asset with the same uri already exists.
  void addEncodedAsset(CodeAsset asset) {
    final assetsJson = _syntax.assets ?? [];
    final duplicate = assetsJson.any((savedAsset) {
      final encoded = EncodedAsset.fromJson(savedAsset.json);
      final codeAsset = CodeAsset.fromEncoded(encoded);
      return asset.file == codeAsset.file;
    });
    if (!duplicate) {
      assetsJson.add(syntax.Asset.fromJson(asset.encode().toJson()));
      _syntax.assets = assetsJson;
    }
  }
}

extension GetLinkMode on BuildOutputBuilder {
  /// Returns the [LinkMode] that should be used for linking code assets.
  /// The link mode is determined by the [LinkModePreference] in the input
  /// configuration.
  LinkMode getLinkMode(BuildInput input) {
    final preference = input.config.code.linkModePreference;
    if (preference == LinkModePreference.dynamic ||
        preference == LinkModePreference.preferDynamic) {
      return DynamicLoadingBundled();
    }
    assert(
      preference == LinkModePreference.static ||
          preference == LinkModePreference.preferStatic,
    );
    return StaticLinking();
  }
}

extension type EncodedAssetBuildOutputBuilder._(BuildOutputBuilder _output) {
  /// Adds [EncodedAsset]s produced by this build.
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
    if (linkInPackage != null) {
      final assetsForLinking = _syntax.assetsForLinking ?? {};
      assetsForLinking[linkInPackage] ??= [];
      assetsForLinking[linkInPackage]!.add(
        syntax.Asset.fromJson(asset.toJson()),
      );
      _syntax.assetsForLinking = assetsForLinking;
    } else {
      final assets = _syntax.assets ?? [];
      assets.add(syntax.Asset.fromJson(asset.toJson()));
      _syntax.assets = assets;
    }
  }

  /// Adds [EncodedAsset]s produced by this build.
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
    if (linkInPackage != null) {
      final assetsForLinking = _syntax.assetsForLinking ?? {};
      final list = assetsForLinking[linkInPackage] ??= [];
      for (final asset in assets) {
        list.add(syntax.Asset.fromJson(asset.toJson()));
      }
      _syntax.assetsForLinking = assetsForLinking;
    } else {
      final list = _syntax.assets ?? [];
      for (final asset in assets) {
        list.add(syntax.Asset.fromJson(asset.toJson()));
      }
      _syntax.assets = list;
    }
  }

  syntax.BuildOutput get _syntax =>
      syntax.BuildOutput.fromJson(_output._syntax.json);
}

class LinkOutput extends HookOutput {
  /// Creates a [BuildOutput] from the given [json].
  LinkOutput(super.json)
    : _syntax = syntax.LinkOutput.fromJson(json),
      super._();

  LinkOutputAssets get assets => LinkOutputAssets._(this);

  @override
  final syntax.LinkOutput _syntax;
}

extension type LinkOutputAssets._(LinkOutput _output) {
  /// The assets produced by this build.
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
    final list = _syntax.assets ?? [];
    list.add(syntax.Asset.fromJson(asset.toJson()));
    _syntax.assets = list;
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
    final list = _syntax.assets ?? [];
    for (final asset in assets) {
      list.add(syntax.Asset.fromJson(asset.toJson()));
    }
    _syntax.assets = list;
  }

  syntax.LinkOutput get _syntax =>
      syntax.LinkOutput.fromJson(_builder._syntax.json);
}

/// The latest supported input version.
///
/// We'll never bump the major version. Removing old keys from the input and
/// output is done via modifying [latestParsableVersion].
final latestVersion = Version(1, 9, 0);

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
final latestParsableVersion = Version(1, 7, 0);

/// The configuration for a build or link hook invocation.
final class HookConfig {
  Map<String, Object?> get json => _syntax.json;

  final syntax.Config _syntax;

  /// The asset types that should be built by an invocation of a hook.
  ///
  /// The invoker of a hook may, and in most cases will, invoke the hook
  /// separately for different asset types.
  ///
  /// This means that hooks should be written in a way that they are a no-op if
  /// they are invoked for an asset type that is not emitted by the hook. Most
  /// asset extensions provide a to check [buildAssetTypes] for their own asset
  /// type. For example, `CodeAsset`s can be used as follows:
  ///
  /// ```dart
  /// if (input.config.buildCodeAssets) {
  ///   // Emit code asset.
  /// }
  /// ```
  List<String> get buildAssetTypes => _syntax.buildAssetTypes;

  HookConfig._(HookInput input) : _syntax = input._syntax.config;
}

final class BuildConfig extends HookConfig {
  @override
  // ignore: overridden_fields
  final syntax.BuildConfig _syntax;

  bool get linkingEnabled => _syntax.linkingEnabled;

  BuildConfig._(super.input)
    : _syntax = syntax.BuildConfig.fromJson(input._syntax.config.json),
      super._();
}
