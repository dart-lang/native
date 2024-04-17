// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_config.dart';

List<Resource>? fromIdentifiers(ResourceIdentifiers? resourceIdentifiers) =>
    resourceIdentifiers?.identifiers
        .map((e) => Resource(name: e.name, metadata: e.id))
        .toList();

/// The input to the linking script.
///
/// It consists of the [_buildConfig] already passed to the build script, the
/// [assets] from the build step, and the [treeshakingInformation] generated
/// during the kernel compilation.
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

  @override
  final Iterable<AssetImpl> assets;

  @override
  final Iterable<Resource>? treeshakingInformation;

  factory LinkConfigImpl.fromValues({
    required Uri? resourceIdentifierUri,
    required BuildConfigImpl buildConfig,
    required List<AssetImpl> assetsForLinking,
  }) =>
      _LinkConfigArgs(
        assetsForLinking: assetsForLinking,
        buildConfig: buildConfig,
        resourceIdentifierUri: resourceIdentifierUri,
      ).toLinkConfig();

  LinkConfigImpl({
    required this.assets,
    required Uri? resourceIdentifierUri,
    required super.outputDirectory,
    required super.packageName,
    required super.packageRoot,
    Version? version,
    required super.buildMode,
    required super.cCompiler,
    Iterable<String>? supportedAssetTypes,
    required super.targetAndroidNdkApi,
    required super.targetArchitecture,
    required super.targetIOSSdk,
    required super.targetOS,
  })  : treeshakingInformation = resourceIdentifierUri != null
            ? fromIdentifiers(ResourceIdentifiers.fromFile(
                resourceIdentifierUri.toFilePath()))
            : null,
        super(
          hook: Hook.link,
          version: version ?? latestVersion,
          dryRun: false,
          supportedAssetTypes: supportedAssetTypes ??
              [
                NativeCodeAsset.type,
                DataAsset.type,
              ],
        );

  @override
  Hook get hook => Hook.link;

  @override
  String get outputName => 'link_output.json';

  @override
  String toJsonString() =>
      const JsonEncoder.withIndent('  ').convert(_args.toJson());

  static LinkConfig fromArguments(List<String> arguments) =>
      _LinkConfigArgs.fromArguments(arguments).toLinkConfig();
}

class _LinkConfigArgs {
  static const resourceIdentifierKey = 'resource_identifiers';
  static const buildConfigKey = 'build_config';
  static const assetsKey = 'assets';

  final Uri? resourceIdentifierUri;
  final BuildConfigImpl buildConfig;
  final List<AssetImpl> assetsForLinking;

  _LinkConfigArgs({
    required this.resourceIdentifierUri,
    required this.buildConfig,
    required this.assetsForLinking,
  });

  factory _LinkConfigArgs.fromArguments(List<String> arguments) {
    final argParser = ArgParser()..addOption('config');

    final results = argParser.parse(arguments);
    final linkConfigContents =
        File(results['config'] as String).readAsStringSync();
    final linkConfigJson =
        jsonDecode(linkConfigContents) as Map<String, dynamic>;

    return _LinkConfigArgs.fromJson(linkConfigJson);
  }

  factory _LinkConfigArgs.fromJson(Map<String, dynamic> linkConfigJson) {
    final resourcesPath = linkConfigJson[resourceIdentifierKey] as String?;
    final buildConfigJson =
        linkConfigJson[buildConfigKey] as Map<String, dynamic>;
    final assetList = linkConfigJson[assetsKey] as List<Object?>?;
    if (assetList == null) {
      throw ArgumentError('Expected to find the assetList in $linkConfigJson');
    }
    return _LinkConfigArgs(
      resourceIdentifierUri:
          resourcesPath != null ? Uri.file(resourcesPath) : null,
      buildConfig: BuildConfigImpl.fromJson(buildConfigJson),
      assetsForLinking: AssetImpl.listFromJson(assetList),
    );
  }

  Map<String, Object> toJson() => {
        if (resourceIdentifierUri != null)
          resourceIdentifierKey: resourceIdentifierUri!.toFilePath(),
        buildConfigKey: buildConfig.toJson(),
        assetsKey: AssetImpl.listToJson(assetsForLinking, buildConfig.version),
      }.sortOnKey();

  LinkConfigImpl toLinkConfig() => LinkConfigImpl._(
        this,
        buildConfig: buildConfig,
        resourceIdentifiers: resourceIdentifierUri != null
            ? ResourceIdentifiers.fromFile(resourceIdentifierUri!.toFilePath())
            : null,
        assets: assetsForLinking,
      );
}
