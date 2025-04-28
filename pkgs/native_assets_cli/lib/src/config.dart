// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert' hide json;
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:pub_semver/pub_semver.dart';

import 'encoded_asset.dart';
import 'extension.dart';
import 'hooks/syntax.g.dart';
import 'metadata.dart';
import 'user_defines.dart';
import 'utils/datetime.dart';

/// The input for `hook/build.dart` or `hook/link.dart`.
///
/// The shared properties of a [LinkInput] and a [BuildInput]. This abstraction
/// makes it easier to design APIs intended for both kinds of build hooks,
/// building and linking.
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

  final HookInputSyntax _syntax;

  HookInput(Map<String, Object?> json)
    : _syntax = HookInputSyntax.fromJson(json) {
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
  Object? operator [](String key) {
    final syntaxNode = _input._syntax.userDefines;
    if (syntaxNode == null) {
      return null;
    }
    final packageUserDefines = PackageUserDefinesSyntaxExtension.fromSyntax(
      syntaxNode,
    );
    final pubspecSource = packageUserDefines.workspacePubspec;
    return pubspecSource?.defines[key];
  }

  /// The absolute path for user-defines for [key] for this package.key
  ///
  /// The relative path passed as user-define is resolved against the base path.
  /// For user-defines originating from a JSON/YAML, the base path is this
  /// JSON/YAML. For user-defines originating from command-line aruments, the
  /// base path is the working directory of the command-line invocation.
  ///
  /// If the user-define is `null` or not a [String], returns `null`.
  Uri? path(String key) {
    final syntaxNode = _input._syntax.userDefines;
    if (syntaxNode == null) {
      return null;
    }
    final packageUserDefines = PackageUserDefinesSyntaxExtension.fromSyntax(
      syntaxNode,
    );
    final pubspecSource = packageUserDefines.workspacePubspec;
    final sources = <PackageUserDefinesSource>[];
    if (pubspecSource != null) {
      sources.add(pubspecSource);
    }
    // TODO(https://github.com/dart-lang/native/issues/2215): Add commandline
    // arguments.
    for (final source in sources) {
      final relativepath = source.defines[key];
      if (relativepath is String) {
        return source.basePath.resolve(relativepath);
      }
    }
    return null;
  }
}

/// A builder for [HookInput].
sealed class HookInputBuilder {
  final _syntax = HookInputSyntax.fromJson({})
    ..config = ConfigSyntax(buildAssetTypes: [], extensions: null);

  Map<String, Object?> get json => _syntax.json;

  void setupShared({
    required Uri packageRoot,
    required String packageName,
    required Uri outputDirectoryShared,
    required Uri outputFile,
    PackageUserDefines? userDefines,
  }) {
    _syntax.packageRoot = packageRoot;
    _syntax.packageName = packageName;
    _syntax.outDirShared = outputDirectoryShared;
    _syntax.outFile = outputFile;
    _syntax.userDefines = userDefines?.toSyntax();
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

/// The input for `hook/build.dart`.
final class BuildInput extends HookInput {
  @override
  Uri get outputFile => _syntax.outFile;

  final BuildInputSyntax _syntaxBuildInput;

  BuildInput(super.json) : _syntaxBuildInput = BuildInputSyntax.fromJson(json);

  @override
  BuildConfig get config => BuildConfig._(this);

  BuildInputAssets get assets => BuildInputAssets._(this);

  /// The metadata emitted by dependent build hooks.
  BuildInputMetadata get metadata => BuildInputMetadata._(this);
}

extension type BuildInputMetadata._(BuildInput _input) {
  /// The metadata emitted by the build hook of package [packageName].
  PackageMetadata operator [](String packageName) => PackageMetadata(
    (_input.assets.encodedAssets[packageName] ?? [])
        .where((e) => e.isMetadataAsset)
        .map((e) => e.asMetadataAsset)
        .toList(),
  );
}

/// The metadata from a specific package in [BuildInput].
final class PackageMetadata {
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

/// A builder for [BuildInput].
final class BuildInputBuilder extends HookInputBuilder {
  @override
  BuildInputSyntax get _syntax => BuildInputSyntax.fromJson(super._syntax.json);

  void setupBuildInput({Map<String, List<EncodedAsset>>? assets}) {
    _syntax.setup(
      assets: assets == null
          ? null
          : {
              for (final MapEntry(:key, :value) in assets.entries)
                key: [
                  for (final asset in value)
                    AssetSyntax.fromJson(asset.toJson()),
                ],
            },
    );
  }

  @override
  BuildConfigBuilder get config => BuildConfigBuilder._(this);

  @override
  void addExtension(ProtocolExtension extension) =>
      extension.setupBuildInput(this);

  BuildInput build() => BuildInput(json);
}

/// A builder for a [HookConfig].
final class HookConfigBuilder {
  final HookInputBuilder builder;

  HookConfigBuilder._(this.builder);

  ConfigSyntax get _syntax => builder._syntax.config;

  void addBuildAssetTypes(Iterable<String> assetTypes) {
    _syntax.buildAssetTypes.addAll(assetTypes);
  }
}

/// A builder for a [BuildConfig].
final class BuildConfigBuilder extends HookConfigBuilder {
  @override
  late final BuildConfigSyntax _syntax = BuildConfigSyntax.fromJson(
    super._syntax.json,
  );

  BuildConfigBuilder._(super.builder) : super._();
}

extension BuildConfigBuilderSetup on BuildConfigBuilder {
  void setupBuild({required bool linkingEnabled}) {
    _syntax.setup(linkingEnabled: linkingEnabled);
  }
}

/// The input for a `hook/link.dart`.
final class LinkInput extends HookInput {
  List<EncodedAsset> get _encodedAssets {
    final assets = _syntaxLinkInput.assets;
    return _parseAssets(assets);
  }

  Uri? get recordedUsagesFile => _syntaxLinkInput.resourceIdentifiers;

  @override
  Uri get outputFile => _syntax.outFile;

  final LinkInputSyntax _syntaxLinkInput;

  LinkInput(super.json) : _syntaxLinkInput = LinkInputSyntax.fromJson(json) {
    // Run validation.
    _encodedAssets;
  }

  @override
  LinkConfig get config => LinkConfig._(this);

  LinkInputAssets get assets => LinkInputAssets._(this);
}

extension type LinkInputAssets._(LinkInput _input) {
  List<EncodedAsset> get encodedAssets => _input._encodedAssets;
}

/// A builder for [LinkInput].
final class LinkInputBuilder extends HookInputBuilder {
  @override
  LinkInputSyntax get _syntax => LinkInputSyntax.fromJson(super._syntax.json);

  void setupLink({
    required List<EncodedAsset> assets,
    required Uri? recordedUsesFile,
  }) {
    _syntax.setup(
      assets: [
        for (final asset in assets) AssetSyntax.fromJson(asset.toJson()),
      ],
      resourceIdentifiers: recordedUsesFile,
    );
  }

  @override
  void addExtension(ProtocolExtension extension) =>
      extension.setupLinkInput(this);

  @override
  LinkConfigBuilder get config => LinkConfigBuilder._(this);

  LinkInput build() => LinkInput(json);
}

/// A builder for a [BuildConfig].
final class LinkConfigBuilder extends HookConfigBuilder {
  @override
  late final BuildConfigSyntax _syntax = BuildConfigSyntax.fromJson(
    super._syntax.json,
  );

  LinkConfigBuilder._(super.builder) : super._();
}

List<EncodedAsset> _parseAssets(List<AssetSyntax>? assets) => assets == null
    ? []
    : [
        for (final asset in assets)
          EncodedAsset.fromJson(asset.json, asset.path),
      ];

/// The output from a `hook/build.dart` or `hook/link.dart`.
///
/// The shared properties of a [BuildOutput] and a [LinkOutput]. This
/// abstraction makes it easier to design APIs intended for both kinds of build
/// hooks, building and linking.
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

  HookOutputSyntax get _syntax;

  HookOutput._(Map<String, Object?> json);

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(json);
}

/// A builder for [HookOutput].
sealed class HookOutputBuilder {
  final _syntax = HookOutputSyntax(
    timestamp: DateTime.now().roundDownToSeconds().toString(),
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

/// The output from a `hook/build.dart`.
final class BuildOutput extends HookOutput {
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

  List<EncodedAsset> get _encodedAssetsForBuild =>
      _parseAssets(_syntax.assetsForBuild ?? []);

  @override
  final BuildOutputSyntax _syntax;

  /// Creates a [BuildOutput] from the given [json].
  BuildOutput(super.json)
    : _syntax = BuildOutputSyntax.fromJson(json),
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

/// A builder for [BuildOutput].
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
final class BuildOutputBuilder extends HookOutputBuilder {
  MetadataOutputBuilder get metadata => MetadataOutputBuilder._(this);

  EncodedAssetBuildOutputBuilder get assets =>
      EncodedAssetBuildOutputBuilder._(this);

  @override
  BuildOutputSyntax get _syntax =>
      BuildOutputSyntax.fromJson(super._syntax.json);

  BuildOutput build() => BuildOutput(json);
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

/// The destination for assets in the [BuildOutput].
///
/// Currently supported routings:
///  * [ToBuildHooks]: From build hook to all dependent builds hooks.
///  * [ToLinkHook]: From build hook to a specific link hook.
///  * [ToAppBundle]: From build or link hook to the application Bundle.
sealed class AssetRouting {
  const AssetRouting();
}

/// Assets with this [AssetRouting] in the [BuildOutput] will be sent to the SDK
/// to be bundled with the app.
final class ToAppBundle extends AssetRouting {
  const ToAppBundle();
}

/// Assets with this [AssetRouting] in the [BuildOutput] will be sent to build
/// hooks.
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

/// Assets with this [AssetRouting] in the [BuildOutput] will be sent to the
/// link hook of [packageName].
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
        assets.add(AssetSyntax.fromJson(asset.toJson()));
        _syntax.assets = assets;
      case ToBuildHooks():
        final assets = _syntax.assetsForBuild ?? [];
        assets.add(AssetSyntax.fromJson(asset.toJson()));
        _syntax.assetsForBuild = assets;
      case ToLinkHook():
        final packageName = routing.packageName;
        final assetsForLinking = _syntax.assetsForLinking ?? {};
        assetsForLinking[packageName] ??= [];
        assetsForLinking[packageName]!.add(
          AssetSyntax.fromJson(asset.toJson()),
        );
        _syntax.assetsForLinking = assetsForLinking;
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
          list.add(AssetSyntax.fromJson(asset.toJson()));
        }
        _syntax.assets = list;
      case ToBuildHooks():
        final list = _syntax.assetsForBuild ?? [];
        for (final asset in assets) {
          list.add(AssetSyntax.fromJson(asset.toJson()));
        }
        _syntax.assetsForBuild = list;
      case ToLinkHook():
        final linkInPackage = routing.packageName;
        final assetsForLinking = _syntax.assetsForLinking ?? {};
        final list = assetsForLinking[linkInPackage] ??= [];
        for (final asset in assets) {
          list.add(AssetSyntax.fromJson(asset.toJson()));
        }
        _syntax.assetsForLinking = assetsForLinking;
    }
  }

  BuildOutputSyntax get _syntax =>
      BuildOutputSyntax.fromJson(_output._syntax.json);
}

/// The output for a `hook/link.dart`.
final class LinkOutput extends HookOutput {
  /// Creates a [BuildOutput] from the given [json].
  LinkOutput(super.json) : _syntax = LinkOutputSyntax.fromJson(json), super._();

  LinkOutputAssets get assets => LinkOutputAssets._(this);

  @override
  final LinkOutputSyntax _syntax;
}

extension type LinkOutputAssets._(LinkOutput _output) {
  /// The assets produced by this build.
  List<EncodedAsset> get encodedAssets => _output._encodedAssets;
}

/// A builder for [LinkOutput].
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
final class LinkOutputBuilder extends HookOutputBuilder {
  EncodedAssetLinkOutputBuilder get assets =>
      EncodedAssetLinkOutputBuilder._(this);

  LinkOutput build() => LinkOutput(json);
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
    list.add(AssetSyntax.fromJson(asset.toJson()));
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
      list.add(AssetSyntax.fromJson(asset.toJson()));
    }
    _syntax.assets = list;
  }

  LinkOutputSyntax get _syntax =>
      LinkOutputSyntax.fromJson(_builder._syntax.json);
}

// Deprecated, still emitted for backwards compatibility purposes.
final latestVersion = Version(1, 9, 0);

/// The configuration in a [HookInput].
final class HookConfig {
  Map<String, Object?> get json => _syntax.json;

  List<Object> get path => _syntax.path;

  final ConfigSyntax _syntax;

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

/// The configuration in a [BuildInput].
final class BuildConfig extends HookConfig {
  @override
  // ignore: overridden_fields
  final BuildConfigSyntax _syntax;

  bool get linkingEnabled => _syntax.linkingEnabled;

  BuildConfig._(super.input)
    : _syntax = BuildConfigSyntax.fromJson(
        input._syntax.config.json,
        path: input._syntax.config.path,
      ),
      super._();
}

/// The configuration in a [LinkInput].
final class LinkConfig extends HookConfig {
  LinkConfig._(super.input) : super._();
}
