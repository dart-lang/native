// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert' hide json;
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart' show sha256;

import 'api/build_and_link.dart';
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

  /// The configuration for this hook input.
  HookConfig get config => HookConfig._(this);

  /// The user-defines for this hook input.
  HookInputUserDefines get userDefines => HookInputUserDefines._(this);
}

/// The user-defines in [HookInput.userDefines].
final class HookInputUserDefines {
  final HookInput _input;

  HookInputUserDefines._(this._input);

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

/// The builder for [HookInput].
sealed class HookInputBuilder {
  final _syntax = HookInputSyntax.fromJson({})
    ..config = ConfigSyntax(buildAssetTypes: [], extensions: null);

  /// The JSON representation of this hook input builder.
  Map<String, Object?> get json => _syntax.json;

  /// Sets up the hook input.
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

  /// The configuration for this hook input.
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

  ///// Creates a [BuildInput] from the given [json].
  BuildInput(super.json) : _syntaxBuildInput = BuildInputSyntax.fromJson(json);

  @override
  BuildConfig get config => BuildConfig._(this);

  /// The assets emitted by `hook/build.dart` of direct dependencies with [ToBuildHooks].
  BuildInputAssets get assets => BuildInputAssets._(this);

  /// The metadata emitted by dependent build hooks.
  BuildInputMetadata get metadata => BuildInputMetadata._(this);
}

/// The metadata in [BuildInput.metadata].
final class BuildInputMetadata {
  final BuildInput _input;

  BuildInputMetadata._(this._input);

  /// The metadata emitted by the build hook of package [packageName].
  PackageMetadata operator [](String packageName) => PackageMetadata._(
    (_input.assets.encodedAssets[packageName] ?? [])
        .where((e) => e.isMetadataAsset)
        .map((e) => e.asMetadataAsset)
        .toList(),
  );
}

/// The metadata from a specific package, available in [BuildInput.metadata].
final class PackageMetadata {
  PackageMetadata._(this._metadata);

  final List<MetadataAsset> _metadata;

  /// Retrieves the metadata value for the given [key].
  Object? operator [](String key) =>
      _metadata.firstWhereOrNull((e) => e.key == key)?.value;
}

/// The assets in [BuildInput.assets].
final class BuildInputAssets {
  final BuildInput _input;

  BuildInputAssets._(this._input);

  /// The encoded assets from direct dependencies.
  Map<String, List<EncodedAsset>> get encodedAssets => {
    for (final MapEntry(:key, :value)
        in (_input._syntaxBuildInput.assets ?? {}).entries)
      key: EncodedAssetSyntax._fromSyntax(value),
  };

  /// The encoded assets from the direct dependency [packageName].
  List<EncodedAsset> operator [](String packageName) =>
      encodedAssets[packageName] ?? [];
}

/// The builder for [BuildInput].
final class BuildInputBuilder extends HookInputBuilder {
  @override
  BuildInputSyntax get _syntax => BuildInputSyntax.fromJson(super._syntax.json);

  /// Sets up the build input with the given [assets].
  void setupBuildInput({Map<String, List<EncodedAsset>>? assets}) {
    _syntax.setup(
      assets: assets == null
          ? null
          : {
              for (final MapEntry(:key, :value) in assets.entries)
                key: [for (final asset in value) asset.toSyntax()],
            },
    );
  }

  @override
  BuildConfigBuilder get config => BuildConfigBuilder._(this);

  @override
  void addExtension(ProtocolExtension extension) =>
      extension.setupBuildInput(this);

  /// Builds the [BuildInput].
  BuildInput build() => BuildInput(json);
}

/// The builder for [HookConfig].
final class HookConfigBuilder {
  ///// The build for the parent (the hook input).
  final HookInputBuilder builder;

  HookConfigBuilder._(this.builder);

  ConfigSyntax get _syntax => builder._syntax.config;

  /// The JSON representation of this config.
  Map<String, Object?> get json => _syntax.json;

  /// Adds asset types to this hook configuration.
  void addBuildAssetTypes(Iterable<String> assetTypes) {
    _syntax.buildAssetTypes.addAll(assetTypes);
  }
}

/// The builder for [BuildConfig].
final class BuildConfigBuilder extends HookConfigBuilder {
  @override
  late final BuildConfigSyntax _syntax = BuildConfigSyntax.fromJson(
    super._syntax.json,
  );

  BuildConfigBuilder._(super.builder) : super._();

  /// Sets up the build configuration.
  void setupBuild({required bool linkingEnabled}) {
    _syntax.setup(linkingEnabled: linkingEnabled);
  }
}

/// The input for a `hook/link.dart`.
final class LinkInput extends HookInput {
  List<EncodedAsset> get _encodedAssets => assets.encodedAssets;

  /// The file containing recorded usages, if any.
  Uri? get recordedUsagesFile => _syntaxLinkInput.resourceIdentifiers;

  @override
  Uri get outputFile => _syntax.outFile;

  final LinkInputSyntax _syntaxLinkInput;

  /// Creates a [LinkInput] from the given [json].
  LinkInput(super.json) : _syntaxLinkInput = LinkInputSyntax.fromJson(json) {
    // Run validation.
    _encodedAssets;
  }

  @override
  LinkConfig get config => LinkConfig._(this);

  /// The assets passed to `hook/link.dart`.
  LinkInputAssets get assets => LinkInputAssets._(this);

  /// The metadata sent to this link hook by dependent link hooks.
  Map<String, Object?> get metadata => Map.fromEntries(
    assets.assetsFromLinking
        .where((e) => e.isMetadataAsset)
        .map((e) => e.asMetadataAsset)
        .map((e) => MapEntry(e.key, e.value)),
  );
}

/// The assets in [LinkInput.assets];
final class LinkInputAssets {
  final LinkInput _input;

  LinkInputAssets._(this._input);

  /// The encoded assets passed to `hook/link.dart`.
  List<EncodedAsset> get encodedAssets =>
      EncodedAssetSyntax._fromSyntax(_input._syntaxLinkInput.assets);

  /// The encoded assets from direct dependencies.
  List<EncodedAsset> get assetsFromLinking =>
      EncodedAssetSyntax._fromSyntax(_input._syntaxLinkInput.assetsFromLinking);
}

/// The builder for [LinkInput].
final class LinkInputBuilder extends HookInputBuilder {
  @override
  LinkInputSyntax get _syntax => LinkInputSyntax.fromJson(super._syntax.json);

  /// Sets up the link input.
  void setupLink({
    required List<EncodedAsset> assets,
    required List<EncodedAsset> assetsFromLinking,
    required Uri? recordedUsesFile,
  }) {
    _syntax.setup(
      assets: [for (final asset in assets) asset.toSyntax()],
      assetsFromLinking: [
        for (final asset in assetsFromLinking) asset.toSyntax(),
      ],
      resourceIdentifiers: recordedUsesFile,
    );
  }

  @override
  void addExtension(ProtocolExtension extension) =>
      extension.setupLinkInput(this);

  @override
  LinkConfigBuilder get config => LinkConfigBuilder._(this);

  /// Builds the [LinkInput].
  LinkInput build() => LinkInput(json);
}

/// The builder for [BuildConfig].
final class LinkConfigBuilder extends HookConfigBuilder {
  @override
  late final BuildConfigSyntax _syntax = BuildConfigSyntax.fromJson(
    super._syntax.json,
  );

  LinkConfigBuilder._(super.builder) : super._();
}

/// Extension methods for [EncodedAsset] to convert to and from the syntax
/// model.
extension EncodedAssetSyntax on List<EncodedAsset> {
  static List<EncodedAsset> _fromSyntax(List<AssetSyntax>? assets) {
    if (assets == null) {
      return [];
    }
    return [
      for (final asset in assets) EncodedAsset.fromJson(asset.json, asset.path),
    ];
  }
}

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
  List<EncodedAsset> get _encodedAssets =>
      EncodedAssetSyntax._fromSyntax(_syntax.assets);

  HookOutputSyntax get _syntax;

  HookOutput._(Map<String, Object?> json);

  @override
  String toString() => const JsonEncoder.withIndent('  ').convert(json);
}

/// The builder for [HookOutput].
sealed class HookOutputBuilder {
  final _syntax = HookOutputSyntax(
    timestamp: DateTime.now().roundDownToSeconds().toString(),
    assets: null,
    dependencies: null,
    status: OutputStatusSyntax.success,
    failureDetails: null,
    assetsForLinking: {},
  );

  /// The JSON representation of this hook output builder.
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

  /// Sets the failure of this output.
  void setFailure(FailureType value) {
    _syntax.status = OutputStatusSyntax.failure;
    _syntax.failureDetails = FailureSyntax(
      type: switch (value) {
        FailureType.build => FailureTypeSyntax.build,
        FailureType.infra => FailureTypeSyntax.infra,
        FailureType.uncategorized => FailureTypeSyntax.uncategorized,
        _ => FailureTypeSyntax.uncategorized,
      },
    );
  }
}

/// The output from a `hook/build.dart` on success.
///
/// See [BuildOutputFailure] for failure.
final class BuildOutput extends HookOutput implements BuildOutputMaybeFailure {
  /// The assets produced by this build which should be linked.
  ///
  /// Every key in the map is a package name. These assets in the values are not
  /// bundled with the application, but are sent to the link hook of the package
  /// specified in the key, which can decide if they are bundled or not.
  Map<String, List<EncodedAsset>> get _encodedAssetsForLinking => {
    for (final MapEntry(:key, :value)
        in (_syntax.assetsForLinking ?? {}).entries)
      key: EncodedAssetSyntax._fromSyntax(value),
  };

  List<EncodedAsset> get _encodedAssetsForBuild =>
      EncodedAssetSyntax._fromSyntax(_syntax.assetsForBuild ?? []);

  @override
  final BuildOutputSyntax _syntax;

  /// Creates a [BuildOutput] from the given [json].
  BuildOutput(super.json)
    : _syntax = BuildOutputSyntax.fromJson(json),
      super._();

  /// The assets produced by this build.
  BuildOutputAssets get assets => BuildOutputAssets._(this);
}

/// The assets in [BuildOutput.assets].
final class BuildOutputAssets {
  final BuildOutput _output;

  BuildOutputAssets._(this._output);

  /// The assets produced by this build.
  List<EncodedAsset> get encodedAssets => _output._encodedAssets;

  /// The assets produced by this build which should be linked.
  ///
  /// Every key in the map is a package name. These assets in the values are not
  /// bundled with the application, but are sent to the link hook of the package
  /// specified in the key, which can decide if they are bundled or not.
  Map<String, List<EncodedAsset>> get encodedAssetsForLinking =>
      _output._encodedAssetsForLinking;

  /// The assets produced by this build which should be available to subsequent
  /// build hooks.
  List<EncodedAsset> get encodedAssetsForBuild =>
      _output._encodedAssetsForBuild;
}

/// The builder for [BuildOutput].
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
/// The builder for [BuildOutput].
final class BuildOutputBuilder extends HookOutputBuilder {
  /// The metadata builder for this build output.
  BuildOutputMetadataBuilder get metadata => BuildOutputMetadataBuilder._(this);

  /// The assets builder for this build output.
  BuildOutputAssetsBuilder get assets => BuildOutputAssetsBuilder._(this);

  @override
  BuildOutputSyntax get _syntax =>
      BuildOutputSyntax.fromJson(super._syntax.json);

  /// Builds the [BuildOutput].
  BuildOutput build() => BuildOutput(json);
}

/// The builder for [BuildOutputBuilder.metadata].
final class BuildOutputMetadataBuilder {
  final BuildOutputBuilder _output;

  BuildOutputMetadataBuilder._(this._output);

  /// Sets the metadata [value] for the given [key].
  void operator []=(String key, Object value) {
    _output.assets.addEncodedAsset(
      MetadataAsset(key: key, value: value).encode(),
      routing: const ToBuildHooks(),
    );
  }

  /// Adds all entries from [metadata].
  void addAll(Map<String, Object> metadata) {
    for (final MapEntry(:key, :value) in metadata.entries) {
      this[key] = value;
    }
  }
}

/// The builder for [LinkOutputBuilder.metadata].
final class LinkOutputMetadataBuilder {
  final LinkOutputBuilder _output;

  LinkOutputMetadataBuilder._(this._output);

  /// Sets the metadata [value] for the given [key] to be sent to [packageName].
  void add(String packageName, String key, Object value) {
    _output.assets.addEncodedAsset(
      MetadataAsset(key: key, value: value).encode(),
      routing: ToLinkHook(packageName),
    );
  }

  /// Adds all entries from [metadata] to be sent to [packageName].
  void addAll(String packageName, Map<String, Object> metadata) {
    metadata.forEach((key, value) => add(packageName, key, value));
  }
}

/// The destination for assets in the [BuildOutput].
///
/// Currently supported routings:
///  * [ToBuildHooks]: From build hook to all dependent builds hooks.
///  * [ToLinkHook]: From build hook to a specific link hook.
///  * [ToAppBundle]: From build hook to the application Bundle.
sealed class AssetRouting {}

/// The destination for assets in the [LinkOutput].
///
/// An asset can be either sent to other link hooks with [ToLinkHook] or
/// directly to the application Bundle with [ToAppBundle].
///
/// Currently supported routings:
///  * [ToLinkHook]: From link hook to another depending link hook.
///  * [ToAppBundle]: From link hook to the application Bundle.
sealed class LinkAssetRouting {}

/// Assets with this [AssetRouting] in the [HookOutput] will be sent to the SDK
/// to be bundled with the app.
final class ToAppBundle implements AssetRouting, LinkAssetRouting {
  /// Creates a [ToAppBundle].
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
final class ToBuildHooks implements AssetRouting {
  /// Creates a [ToBuildHooks].
  const ToBuildHooks();
}

/// Assets with this [AssetRouting] in the [HookOutput] will be sent to the
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
final class ToLinkHook implements AssetRouting, LinkAssetRouting {
  /// The name of the package that contains the `hook/link.dart` to which assets
  /// should be sent.
  final String packageName;

  /// Creates a [ToLinkHook] with the given [packageName].
  const ToLinkHook(this.packageName);
}

/// The builder for [BuildOutputAssets].
final class BuildOutputAssetsBuilder {
  final BuildOutputBuilder _output;

  BuildOutputAssetsBuilder._(this._output);

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
        assets.add(asset.toSyntax());
        _syntax.assets = assets;
      case ToBuildHooks():
        final assets = _syntax.assetsForBuild ?? [];
        assets.add(asset.toSyntax());
        _syntax.assetsForBuild = assets;
      case ToLinkHook():
        final packageName = routing.packageName;
        final assetsForLinking = _syntax.assetsForLinking ?? {};
        assetsForLinking[packageName] ??= [];
        assetsForLinking[packageName]!.add(asset.toSyntax());
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
          list.add(asset.toSyntax());
        }
        _syntax.assets = list;
      case ToBuildHooks():
        final list = _syntax.assetsForBuild ?? [];
        for (final asset in assets) {
          list.add(asset.toSyntax());
        }
        _syntax.assetsForBuild = list;
      case ToLinkHook():
        final linkInPackage = routing.packageName;
        final assetsForLinking = _syntax.assetsForLinking ?? {};
        final list = assetsForLinking[linkInPackage] ??= [];
        for (final asset in assets) {
          list.add(asset.toSyntax());
        }
        _syntax.assetsForLinking = assetsForLinking;
    }
  }

  BuildOutputSyntax get _syntax =>
      BuildOutputSyntax.fromJson(_output._syntax.json);
}

/// The output for a `hook/link.dart` on success.
///
/// See [LinkOutputFailure] for failure.
final class LinkOutput extends HookOutput implements LinkOutputMaybeFailure {
  /// The assets produced by this link hook which are routed to link hooks in
  /// other packages.
  ///
  /// These can only be the packages which are direct dependencies of the
  /// current package.
  /// Every key in the map is a package name. These assets in the values are not
  /// bundled with the application, but are sent to the link hook of the package
  /// specified in the key, which can decide what to do with them.
  Map<String, List<EncodedAsset>> get _encodedAssetsForLink => {
    for (final MapEntry(:key, :value)
        in (_syntax.assetsForLinking ?? {}).entries)
      key: EncodedAssetSyntax._fromSyntax(value),
  };

  /// Creates a [LinkOutput] from the given [json].
  LinkOutput(super.json) : _syntax = LinkOutputSyntax.fromJson(json), super._();

  /// The assets produced by this link hook.
  LinkOutputAssets get assets => LinkOutputAssets._(this);

  @override
  final LinkOutputSyntax _syntax;
}

/// The assets in [LinkOutput.assets].
final class LinkOutputAssets {
  final LinkOutput _output;

  LinkOutputAssets._(this._output);

  /// The assets produced by this build.
  List<EncodedAsset> get encodedAssets => _output._encodedAssets;

  /// The assets produced by this link hook sent to a specific link hook.
  ///
  /// The key of the map is the package name of the destination link hook.
  Map<String, List<EncodedAsset>> get encodedAssetsForLink =>
      _output._encodedAssetsForLink;
}

/// The builder for [LinkOutput].
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
  /// The metadata builder for this link output.
  LinkOutputMetadataBuilder get metadata => LinkOutputMetadataBuilder._(this);

  /// The assets builder for this link output.
  LinkOutputAssetsBuilder get assets => LinkOutputAssetsBuilder._(this);

  /// Builds the [LinkOutput].
  LinkOutput build() => LinkOutput(json);
}

/// The builder for [LinkOutput.assets] in [LinkOutputBuilder].
final class LinkOutputAssetsBuilder {
  final LinkOutputBuilder _builder;

  LinkOutputAssetsBuilder._(this._builder);

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
  void addEncodedAsset(
    EncodedAsset asset, {
    LinkAssetRouting routing = const ToAppBundle(),
  }) {
    switch (routing) {
      case ToAppBundle():
        final assets = _syntax.assets ?? [];
        assets.add(asset.toSyntax());
        _syntax.assets = assets;
      case ToLinkHook():
        final packageName = routing.packageName;
        final assetsForLinking = _syntax.assetsForLinking ?? {};
        assetsForLinking[packageName] ??= [];
        assetsForLinking[packageName]!.add(asset.toSyntax());
        _syntax.assetsForLinking = assetsForLinking;
    }
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
  void addEncodedAssets(
    Iterable<EncodedAsset> assets, {
    LinkAssetRouting routing = const ToAppBundle(),
  }) {
    switch (routing) {
      case ToAppBundle():
        final list = _syntax.assets ?? [];
        for (final asset in assets) {
          list.add(asset.toSyntax());
        }
        _syntax.assets = list;
      case ToLinkHook():
        final linkInPackage = routing.packageName;
        final assetsForLinking = _syntax.assetsForLinking ?? {};
        final list = assetsForLinking[linkInPackage] ??= [];
        for (final asset in assets) {
          list.add(asset.toSyntax());
        }
        _syntax.assetsForLinking = assetsForLinking;
    }
  }

  LinkOutputSyntax get _syntax =>
      LinkOutputSyntax.fromJson(_builder._syntax.json);
}

/// The configuration in [HookInput.config].
final class HookConfig {
  /// The JSON representation of this config.
  Map<String, Object?> get json => _syntax.json;

  /// The JSON path to this config inside the input.
  ///
  /// This is a public member such that [ProtocolExtension]s  can access it.
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

/// The configuration in [BuildInput.config].
final class BuildConfig extends HookConfig {
  @override
  // ignore: overridden_fields
  final BuildConfigSyntax _syntax;

  /// Whether linking is enabled for this build.
  bool get linkingEnabled => _syntax.linkingEnabled;

  BuildConfig._(super.input)
    : _syntax = BuildConfigSyntax.fromJson(
        input._syntax.config.json,
        path: input._syntax.config.path,
      ),
      super._();
}

/// The configuration in [LinkInput.config].
final class LinkConfig extends HookConfig {
  LinkConfig._(super.input) : super._();
}

/// A type of failure that occurred during a hook execution.
class FailureType {
  /// The name of this failure type.
  final String name;

  const FailureType._(this.name);

  /// A failure that occurred due to a problem in the build logic of the hook.
  static const build = FailureType._('build');

  /// A failure that occurred due to an infrastructure issue.
  ///
  /// For example, a network issue, or a tool not being available.
  ///
  /// Typically fixed by investigating infra reliability.
  static const infra = FailureType._('infra');

  /// A failure that is not categorized as [build] or [infra].
  ///
  /// Typically treated as [build].
  static const uncategorized = FailureType._('uncategorized');

  @override
  String toString() => name;
}

/// The output of a hook that has failed.
final class HookOutputFailure {
  /// The JSON representation of this failure.
  Map<String, Object?> get json => _syntax.json;

  final HookOutputSyntax _syntax;

  HookOutputFailure._(Map<String, Object?> json)
    : _syntax = HookOutputSyntax.fromJson(json);

  /// The type of failure.
  ///
  /// This helps in categorizing the error and determining the appropriate
  /// response or fix.
  FailureType get type => switch (_syntax.failureDetails?.type) {
    FailureTypeSyntax.build => FailureType.build,
    FailureTypeSyntax.infra => FailureType.infra,
    FailureTypeSyntax.uncategorized => FailureType.uncategorized,
    _ => FailureType.uncategorized,
  };
}

/// The output from a `hook/build.dart` on failure.
///
/// See [BuildOutput] for success.
final class BuildOutputFailure extends HookOutputFailure
    implements BuildOutputMaybeFailure {
  BuildOutputFailure._(super.json) : super._();
}

/// The output from a `hook/link.dart` on failure.
///
/// See [LinkOutput] for success.
final class LinkOutputFailure extends HookOutputFailure
    implements LinkOutputMaybeFailure {
  LinkOutputFailure._(super.json) : super._();
}

/// Either a successful [BuildOutput] or a [BuildOutputFailure].
sealed class BuildOutputMaybeFailure {
  /// The JSON representation of this output.
  Map<String, Object?> get json;

  factory BuildOutputMaybeFailure(Map<String, Object?> json) {
    final syntax = HookOutputSyntax.fromJson(json);
    final status = syntax.status;
    switch (status) {
      case null: // backwards compatibility.
      case OutputStatusSyntax.success:
        return BuildOutput(json);
      case OutputStatusSyntax.failure:
        return BuildOutputFailure._(json);
    }
    throw StateError('Unknown status: $status.');
  }
}

/// Either a successful [LinkOutput] or a [LinkOutputFailure].
sealed class LinkOutputMaybeFailure {
  /// The JSON representation of this output.
  Map<String, Object?> get json;

  factory LinkOutputMaybeFailure(Map<String, Object?> json) {
    final syntax = HookOutputSyntax.fromJson(json);
    final status = syntax.status;
    switch (status) {
      case null: // backwards compatibility.
      case OutputStatusSyntax.success:
        return LinkOutput(json);
      case OutputStatusSyntax.failure:
        return LinkOutputFailure._(json);
    }
    throw StateError('Unknown status: $status.');
  }
}

/// Base class for errors that can be thrown during a [build] or [link]
/// invocation.
///
/// Throwing these errors in [build] or [link] will automatically set the
/// [HookOutputBuilder.setFailure] and exit the process with the exit code
/// belonging to that error type.
abstract class HookError extends Error {
  /// The error message.
  final String message;

  /// An optional underlying exception that caused this error.
  final Object? wrappedException;

  /// An optional stack trace associated with the [wrappedException].
  final StackTrace? wrappedTrace;

  /// Creates a [HookError] with the given [message].
  HookError({required this.message, this.wrappedException, this.wrappedTrace});

  /// The exit code that should be used if the process terminates due to this
  /// error.
  int get exitCode;

  /// The [FailureType] associated with this error.
  FailureType get failureType;
}

/// An error indicating a problem with the build logic within a hook.
///
/// Throwing this error in [build] or [link] will automatically set the
/// [HookOutputBuilder.setFailure] and exit the process with [exitCode].
///
/// This typically means something went wrong during the asset generation or
/// transformation process.
final class BuildError extends HookError {
  /// Creates a [BuildError] with the given [message].
  BuildError({
    required super.message,
    super.wrappedException,
    super.wrappedTrace,
  });

  @override
  int get exitCode => 1;

  /// The failure type for build errors is [FailureType.build].
  @override
  FailureType get failureType => FailureType.build;
}

/// An error indicating an infrastructure-related problem during hook execution.
///
/// Throwing this error in [build] or [link] will automatically set the
/// [HookOutputBuilder.setFailure] and exit the process with [exitCode].
///
/// This could be due to issues like network problems.
final class InfraError extends HookError {
  /// Creates a [InfraError] with the given [message].
  InfraError({
    required super.message,
    super.wrappedException,
    super.wrappedTrace,
  });

  @override
  int get exitCode => 2;

  /// The failure type for infrastructure errors is [FailureType.infra].
  @override
  FailureType get failureType => FailureType.infra;
}
