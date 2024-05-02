// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_config.dart';

List<Resource>? fromIdentifiers(ResourceIdentifiers resourceIdentifiers) =>
    resourceIdentifiers.identifiers
        .map((e) => Resource(name: e.name, metadata: e.id))
        .toList();

/// The input to the linking script.
///
/// It consists of the fields inherited from the [HookConfig], the [assets] from
/// the build step, and the [treeshakingInformation] generated during the kernel
/// compilation.
class LinkConfigImpl extends HookConfigImpl implements LinkConfig {
  /// The version of [BuildConfigImpl].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the JSON
  /// representation in the protocol.
  static Version latestVersion = Version(1, 0, 0);

  static const resourceIdentifierKey = 'resource_identifiers';

  static const assetsKey = 'assets';

  @override
  final Iterable<AssetImpl> assets;

  Iterable<Resource>? _treeshakingInformation;

  @override
  Iterable<Resource>? get treeshakingInformation {
    if (_resourceIdentifierUri != null && _treeshakingInformation == null) {
      _treeshakingInformation = fromIdentifiers(
          ResourceIdentifiers.fromFile(_resourceIdentifierUri.toFilePath()));
    }
    return _treeshakingInformation;
  }

  final Uri? _resourceIdentifierUri;

  LinkConfigImpl({
    required this.assets,
    Uri? resourceIdentifierUri,
    required super.outputDirectory,
    required super.packageName,
    required super.packageRoot,
    Version? version,
    required super.buildMode,
    super.cCompiler,
    Iterable<String>? supportedAssetTypes,
    super.targetAndroidNdkApi,
    super.targetArchitecture,
    super.targetIOSSdk,
    required super.targetOS,
    required super.linkModePreference,
    super.dryRun,
  })  : _resourceIdentifierUri = resourceIdentifierUri,
        super(
          hook: Hook.link,
          version: version ?? latestVersion,
          supportedAssetTypes: supportedAssetTypes ?? [NativeCodeAsset.type],
        );

  LinkConfigImpl.dryRun({
    required this.assets,
    Uri? resourceIdentifierUri,
    required super.outputDirectory,
    required super.packageName,
    required super.packageRoot,
    Version? version,
    Iterable<String>? supportedAssetTypes,
    required super.linkModePreference,
    required super.targetOS,
  })  : _resourceIdentifierUri = resourceIdentifierUri,
        _treeshakingInformation = resourceIdentifierUri != null
            ? fromIdentifiers(ResourceIdentifiers.fromFile(
                resourceIdentifierUri.toFilePath()))
            : null,
        super.dryRun(
          hook: Hook.link,
          version: version ?? latestVersion,
          supportedAssetTypes: supportedAssetTypes ?? [NativeCodeAsset.type],
        );

  @override
  Hook get hook => Hook.link;
  @override
  String get outputName => 'link_output.json';

  @override
  Map<String, Object> toJson() => {
        ...hookToJson(),
        if (_resourceIdentifierUri != null)
          resourceIdentifierKey: _resourceIdentifierUri.toFilePath(),
        assetsKey: AssetImpl.listToJson(assets, version),
      }.sortOnKey();

  static LinkConfig fromArguments(List<String> arguments) {
    final argParser = ArgParser()..addOption('config');

    final results = argParser.parse(arguments);
    final linkConfigContents =
        File(results['config'] as String).readAsStringSync();
    final linkConfigJson =
        jsonDecode(linkConfigContents) as Map<String, dynamic>;

    return fromJson(linkConfigJson);
  }

  static LinkConfigImpl fromJson(Map<String, dynamic> linkConfigJson) {
    final config =
        Config.fromConfigFileContents(fileContents: jsonEncode(linkConfigJson));
    final dryRun = HookConfigImpl.parseDryRun(config) ?? false;
    final targetOS = HookConfigImpl.parseTargetOS(config);
    return LinkConfigImpl(
      outputDirectory: HookConfigImpl.parseOutDir(config),
      packageName: HookConfigImpl.parsePackageName(config),
      packageRoot: HookConfigImpl.parsePackageRoot(config),
      buildMode: HookConfigImpl.parseBuildMode(config, dryRun),
      targetOS: targetOS,
      targetArchitecture:
          HookConfigImpl.parseTargetArchitecture(config, dryRun, targetOS),
      linkModePreference: HookConfigImpl.parseLinkModePreference(config),
      version: HookConfigImpl.parseVersion(config, latestVersion),
      cCompiler: HookConfigImpl.parseCCompiler(config, dryRun),
      supportedAssetTypes: HookConfigImpl.parseSupportedAssetTypes(config),
      targetAndroidNdkApi:
          HookConfigImpl.parseTargetAndroidNdkApi(config, dryRun, targetOS),
      targetIOSSdk: HookConfigImpl.parseTargetIOSSdk(config, dryRun, targetOS),
      assets: parseAssets(config),
      resourceIdentifierUri: parseResourceIdentifier(config),
      dryRun: dryRun,
    );
  }

  static Uri? parseResourceIdentifier(Config config) =>
      config.optionalPath(resourceIdentifierKey);

  static List<AssetImpl> parseAssets(Config config) =>
      AssetImpl.listFromJson(config.valueOf(assetsKey));

  @override
  bool operator ==(Object other) {
    if (super != other) {
      return false;
    }
    if (other is! LinkConfigImpl) {
      return false;
    }
    if (other._resourceIdentifierUri != _resourceIdentifierUri) {
      return false;
    }
    if (!const DeepCollectionEquality().equals(other.assets, assets)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll([
        super.hashCode,
        _resourceIdentifierUri,
        const DeepCollectionEquality().hash(assets),
      ]);

  @override
  String toString() => 'LinkConfig(${toJson()})';
}
