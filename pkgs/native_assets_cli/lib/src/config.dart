// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert' hide json;
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:pub_semver/pub_semver.dart';

import 'api/deprecation_messages.dart';
import 'encoded_asset.dart';
import 'extension.dart';
import 'hooks/syntax.g.dart' as syntax;
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
  Uri get outputDirectory {
    if (_cachedOutputDirectory != null) {
      return _cachedOutputDirectory!.uri;
    }
    final checksum = config.computeChecksum();
    final directory = Directory.fromUri(
      outputDirectoryShared.resolve('$checksum/'),
    );
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    _cachedOutputDirectory = directory;
    return directory.uri;
  }

  Directory? _cachedOutputDirectory;

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
    // Trigger validation, remove with cleanup.
    outputDirectory;
    outputDirectoryShared;
  }

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(json);

  HookConfig get config => HookConfig._(this);

  /// The user-defines for this [packageName].
  HookInputUserDefines get userDefines => HookInputUserDefines._(this);
}

extension type HookInputUserDefines._(HookInput _input) {
  /// The value for the user-define for [key] for this package.
  ///
  /// This can be arbitrary JSON/YAML if provided from the SDK from such source.
  /// If it's provided from command-line arguments, it's likely a string.
  Object? operator [](String key) => _input._syntax.userDefines?.json[key];
}

sealed class HookInputBuilder {
  final _syntax = syntax.HookInput.fromJson({})
    ..version = latestVersion.toString()
    ..config = syntax.Config(buildAssetTypes: [], extensions: null);

  Map<String, Object?> get json => _syntax.json;

  void setupShared({
    required Uri packageRoot,
    required String packageName,
    @Deprecated(
      'This parameter is not read in `HookInput`. '
      'It must still be provided to accommodate `HookInput`s in hooks using an '
      'older version of this package.',
    )
    required Uri outputDirectory,
    required Uri outputDirectoryShared,
    required Uri outputFile,
    Map<String, Object?>? userDefines,
  }) {
    _syntax.version = latestVersion.toString();
    _syntax.packageRoot = packageRoot;
    _syntax.packageName = packageName;
    _syntax.outDir = outputDirectory;
    _syntax.outDirShared = outputDirectoryShared;
    _syntax.outFile = outputFile;
    _syntax.userDefines = userDefines == null
        ? null
        : syntax.JsonObject.fromJson(userDefines);
  }

  /// Constructs a checksum for a [BuildInput].
  ///
  /// This can be used to construct an output directory name specific to the
  /// [HookConfig] being built with this builder. It is therefore assumed the
  /// output directory has not been set yet.
  String computeChecksum() => _jsonChecksum(_syntax.config.json);

  HookConfigBuilder get config => HookConfigBuilder._(this);

  /// Adds the protocol extension to this hook input.
  ///
  /// This will [HookConfigBuilder.addBuildAssetTypes] and add the extensions'
  /// config to [config].
  void addExtension(ProtocolExtension extension);
}

String _jsonChecksum(Map<String, Object?> json) {
  final hash = sha256
      .convert(const JsonEncoder().fuse(const Utf8Encoder()).convert(json))
      .toString()
      // 256 bit hashes lead to 64 hex character strings.
      // To avoid overflowing file paths limits, only use 32.
      // Using 16 hex characters would also be unlikely to have collisions.
      .substring(0, 32);
  return hash;
}

final class BuildInput extends HookInput {
  @Deprecated('Use metadata backed by MetadataAsset instead.')
  Map<String, Metadata> get metadataOld => {
    for (final entry in (_syntaxBuildInput.dependencyMetadata ?? {}).entries)
      entry.key: Metadata(entry.value),
  };

  @override
  Uri get outputFile =>
      _syntax.outFile ?? _syntax.outDir.resolve('build_output.json');

  final syntax.BuildInput _syntaxBuildInput;

  BuildInput(super.json)
    : _syntaxBuildInput = syntax.BuildInput.fromJson(json) {
    // Run validation.
    // ignore: deprecated_member_use_from_same_package
    metadataOld;
  }

  @Deprecated('Use metadata backed by MetadataAsset instead.')
  Object? metadatum(String packageName, String key) =>
      metadataOld[packageName]?.metadata[key];

  @override
  BuildConfig get config => BuildConfig._(this);

  BuildInputAssets get assets => BuildInputAssets._(this);

  BuildInputMetadata get metadata => BuildInputMetadata._(this);
}

extension type BuildInputMetadata._(BuildInput _input) {
  PackageMetadata operator [](String packageName) => PackageMetadata(
    (_input.assets.encodedAssets[packageName] ?? [])
        .where((e) => e.isMetadataAsset)
        .map((e) => e.asMetadataAsset)
        .toList(),
  );
}

class PackageMetadata {
  PackageMetadata(this._metadata);

  final List<MetadataAsset> _metadata;

  Object? operator [](String key) =>
      _metadata.firstWhereOrNull((e) => e.key == key)?.value;
}

extension type BuildInputAssets._(BuildInput _input) {
  Map<String, List<EncodedAsset>> get encodedAssets => {
    for (final MapEntry(:key, :value)
        in (_input._syntaxBuildInput.assets ?? {}).entries)
      key: _parseAssets(value),
  };

  List<EncodedAsset> operator [](String packageName) =>
      encodedAssets[packageName] ?? [];
}

final class BuildInputBuilder extends HookInputBuilder {
  @override
  syntax.BuildInput get _syntax =>
      syntax.BuildInput.fromJson(super._syntax.json);

  void setupBuildInput({
    Map<String, Metadata> metadata = const {},
    Map<String, List<EncodedAsset>>? assets,
  }) {
    if (metadata.isEmpty) {
      return;
    }
    _syntax.setup(
      dependencyMetadata: {
        for (final key in metadata.keys) key: metadata[key]!.toJson(),
      },
      assets: assets == null
          ? null
          : {
              for (final MapEntry(:key, :value) in assets.entries)
                key: [
                  for (final asset in value)
                    syntax.Asset.fromJson(asset.toJson()),
                ],
            },
    );
  }

  @override
  BuildConfigBuilder get config => BuildConfigBuilder._(this);

  @override
  void addExtension(ProtocolExtension extension) =>
      extension.setupBuildInput(this);
}

final class HookConfigBuilder {
  final HookInputBuilder builder;

  HookConfigBuilder._(this.builder);

  syntax.Config get _syntax => builder._syntax.config;

  void addBuildAssetTypes(Iterable<String> assetTypes) {
    _syntax.buildAssetTypes.addAll(assetTypes);
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

  @override
  void addExtension(ProtocolExtension extension) =>
      extension.setupLinkInput(this);
}

List<EncodedAsset> _parseAssets(List<syntax.Asset>? assets) => assets == null
    ? []
    : [
        for (final asset in assets)
          EncodedAsset.fromJson(asset.json, asset.path),
      ];

sealed class HookOutput {
  /// The underlying json configuration of this [HookOutput].
  Map<String, Object?> get json => _syntax.json;

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

  HookOutput._(Map<String, Object?> json);

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(json);
}

sealed class HookOutputBuilder {
  final _syntax = syntax.HookOutput(
    timestamp: DateTime.now().roundDownToSeconds().toString(),
    version: latestVersion.toString(),
    assets: null,
    dependencies: null,
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
        in (_syntax.assetsForLinking ?? _syntax.assetsForLinkingOld ?? {})
            .entries)
      key: _parseAssets(value),
  };

  List<EncodedAsset> get _encodedAssetsForBuild =>
      _parseAssets(_syntax.assetsForBuild ?? []);

  /// Metadata passed to dependent build hook invocations.
  Metadata get metadata => Metadata(_syntax.metadata?.json ?? {});

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

  List<EncodedAsset> get encodedAssetsForBuild =>
      _output._encodedAssetsForBuild;
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
    final metadata = _syntax.metadata?.json ?? {};
    metadata[key] = value;
    metadata.sortOnKey();
    _syntax.metadata = syntax.JsonObject.fromJson(metadata);
  }

  /// Adds metadata to be passed to build hook invocations of dependent
  /// packages.
  @Deprecated(metadataDeprecation)
  void addMetadata(Map<String, Object> metadata) {
    final value = _syntax.metadata?.json ?? {};
    value.addAll(metadata);
    value.sortOnKey();
    _syntax.metadata = syntax.JsonObject.fromJson(value);
  }

  MetadataOutputBuilder get metadata => MetadataOutputBuilder._(this);

  EncodedAssetBuildOutputBuilder get assets =>
      EncodedAssetBuildOutputBuilder._(this);

  @override
  syntax.BuildOutput get _syntax =>
      syntax.BuildOutput.fromJson(super._syntax.json);
}

extension type MetadataOutputBuilder._(BuildOutputBuilder _output) {
  void operator []=(String key, Object value) {
    _output.assets.addEncodedAsset(
      MetadataAsset(key: key, value: value).encode(),
      routing: const ToBuildHooks(),
    );
  }

  void addAll(Map<String, Object> metadata) {
    for (final MapEntry(:key, :value) in metadata.entries) {
      this[key] = value;
    }
  }
}

/// The destination for assets output in a build hook.
sealed class AssetRouting {
  const AssetRouting();
}

/// Assets with this routing will be sent to the SDK to be bundled with the app.
final class ToAppBundle extends AssetRouting {
  const ToAppBundle();
}

/// Assets with this routing will be sent to build hooks.
///
/// The assets are only available for build hooks of packages that have a direct
/// dependency on the package emitting the asset with this routing.
///
/// The assets will not be bundled in the final application unless also added
/// with [ToAppBundle]. Prefer bundling the asset in the sending hook, otherwise
/// multiple receivers might try to bundle the asset leading to duplicate assets
/// in the app bundle.
///
/// The receiver will know about sender package (it must be a direct
/// dependency), the sender does not know about the receiver. Hence this routing
/// is a broadcast with 0-N receivers.
final class ToBuildHooks extends AssetRouting {
  const ToBuildHooks();
}

/// Assets with this routing will be sent to the link hook of [packageName].
///
/// The assets are only available to the link hook of [packageName].
///
/// The assets will not be bundled in the final application unless added with
/// [ToAppBundle] in the link hook of [packageName].
///
/// The receiver will not know about the sender package. The sender knows about
/// the receiver package. Hence, the receiver must be specified and there is
/// exactly one receiver.
final class ToLinkHook extends AssetRouting {
  final String packageName;

  const ToLinkHook(this.packageName);
}

extension type EncodedAssetBuildOutputBuilder._(BuildOutputBuilder _output) {
  /// Adds [EncodedAsset]s produced by this build.
  ///
  /// The asset is routed according to [routing].
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
  void addEncodedAsset(
    EncodedAsset asset, {
    AssetRouting routing = const ToAppBundle(),
  }) {
    switch (routing) {
      case ToAppBundle():
        final assets = _syntax.assets ?? [];
        assets.add(syntax.Asset.fromJson(asset.toJson()));
        _syntax.assets = assets;
      case ToBuildHooks():
        final assets = _syntax.assetsForBuild ?? [];
        assets.add(syntax.Asset.fromJson(asset.toJson()));
        _syntax.assetsForBuild = assets;
      case ToLinkHook():
        final packageName = routing.packageName;
        final assetsForLinking = _syntax.assetsForLinking ?? {};
        assetsForLinking[packageName] ??= [];
        assetsForLinking[packageName]!.add(
          syntax.Asset.fromJson(asset.toJson()),
        );
        _syntax.assetsForLinking = assetsForLinking;
        _syntax.assetsForLinkingOld = assetsForLinking;
    }
  }

  /// Adds [EncodedAsset]s produced by this build.
  ///
  /// The asset is routed according to [routing].
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
    AssetRouting routing = const ToAppBundle(),
  }) {
    switch (routing) {
      case ToAppBundle():
        final list = _syntax.assets ?? [];
        for (final asset in assets) {
          list.add(syntax.Asset.fromJson(asset.toJson()));
        }
        _syntax.assets = list;
      case ToBuildHooks():
        final list = _syntax.assetsForBuild ?? [];
        for (final asset in assets) {
          list.add(syntax.Asset.fromJson(asset.toJson()));
        }
        _syntax.assetsForBuild = list;
      case ToLinkHook():
        final linkInPackage = routing.packageName;
        final assetsForLinking =
            _syntax.assetsForLinking ?? _syntax.assetsForLinkingOld ?? {};
        final list = assetsForLinking[linkInPackage] ??= [];
        for (final asset in assets) {
          list.add(syntax.Asset.fromJson(asset.toJson()));
        }
        _syntax.assetsForLinking = assetsForLinking;
        _syntax.assetsForLinkingOld = assetsForLinking;
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

// Deprecated, still emitted for backwards compatibility purposes.
final latestVersion = Version(1, 9, 0);

/// The configuration for a build or link hook invocation.
final class HookConfig {
  Map<String, Object?> get json => _syntax.json;

  List<Object> get path => _syntax.path;

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

  /// Constructs a checksum for this hook config.
  ///
  /// This can be used to construct an output directory name specific to the
  /// [HookConfig] being built with this builder. It is therefore assumed the
  /// output directory has not been set yet.
  String computeChecksum() => _jsonChecksum(_syntax.json);
}

final class BuildConfig extends HookConfig {
  @override
  // ignore: overridden_fields
  final syntax.BuildConfig _syntax;

  bool get linkingEnabled => _syntax.linkingEnabled;

  BuildConfig._(super.input)
    : _syntax = syntax.BuildConfig.fromJson(
        input._syntax.config.json,
        path: input._syntax.config.path,
      ),
      super._();
}
