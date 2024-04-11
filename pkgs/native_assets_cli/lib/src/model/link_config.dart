// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_config.dart';

/// The input to the linking script.
///
/// It consists of the [_buildConfig] already passed to the build script, the
/// [assets] from the build step, and the [resources] generated during the
/// kernel compilation.
class LinkConfigImpl extends HookConfigImpl implements LinkConfig {
  @override
  final List<LinkableAsset> assets;

  final BuildConfigImpl _buildConfig;

  @override
  final List<Resource> resources;

  final _LinkConfigArgs _args;

  LinkConfigImpl._(
    this._args, {
    required this.assets,
    required BuildConfigImpl buildConfig,
    required ResourceIdentifiers? resourceIdentifiers,
  })  : _buildConfig = buildConfig,
        resources = fromIdentifiers(resourceIdentifiers);

  @override
  Uri get configFile => outputDirectory.resolve('../link_config.json');

  @override
  Uri get outputDirectory => _buildConfig.outputDirectory;

  @override
  String get outputName => 'link_output.json';

  @override
  String get packageName => _buildConfig.packageName;

  @override
  Uri get packageRoot => _buildConfig.packageRoot;

  @override
  Uri get script => packageRoot.resolve('hook/').resolve(Hook.link.scriptName);

  @override
  String toJsonString() =>
      const JsonEncoder.withIndent('  ').convert(_args.toJson());

  @override
  Version get version => _buildConfig.version;

  static LinkConfig fromArguments(List<String> arguments) =>
      _LinkConfigArgs.fromArguments(arguments).toLinkConfig();

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

  @override
  BuildMode get buildMode => _buildConfig.buildMode;

  @override
  CCompilerConfig get cCompiler => _buildConfig.cCompiler;

  @override
  bool get dryRun => _buildConfig.dryRun;

  @override
  Iterable<String> get supportedAssetTypes => _buildConfig.supportedAssetTypes;

  @override
  int? get targetAndroidNdkApi => _buildConfig.targetAndroidNdkApi;

  @override
  Architecture? get targetArchitecture => _buildConfig.targetArchitecture;

  @override
  IOSSdk get targetIOSSdk => _buildConfig.targetIOSSdk;

  @override
  OS get targetOS => _buildConfig.targetOS;

  /// The version of [BuildConfigImpl].
  ///
  /// This class is used in the protocol between the Dart and Flutter SDKs
  /// and packages through build hook invocations.
  ///
  /// If we ever were to make breaking changes, it would be useful to give
  /// proper error messages rather than just fail to parse the JSON
  /// representation in the protocol.
  static Version latestVersion = Version(1, 0, 0);
}

List<Resource> fromIdentifiers(ResourceIdentifiers? resourceIdentifiers) =>
    (resourceIdentifiers?.identifiers ?? [])
        .map((e) => Resource(name: e.name, metadata: e.id))
        .toList();

class _LinkConfigArgs {
  final Uri? resourceIdentifierUri;
  final BuildConfigImpl buildConfig;
  final List<AssetImpl> assetsForLinking;

  static const resourceIdentifierKey = 'resource_identifiers';
  static const buildConfigKey = 'build_config';
  static const assetsKey = 'assets';

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

  LinkConfigImpl toLinkConfig() => LinkConfigImpl._(
        this,
        buildConfig: buildConfig,
        resourceIdentifiers: resourceIdentifierUri != null
            ? ResourceIdentifiers.fromFile(resourceIdentifierUri!.toFilePath())
            : null,
        assets: assetsForLinking
            .map(
              (asset) => switch (asset) {
                DataAssetImpl() => LinkableDataAssetImpl(asset),
                NativeCodeAssetImpl() => LinkableCodeAssetImpl(asset),
                AssetImpl() => throw UnimplementedError(),
              },
            )
            .toList(),
      );

  Map<String, Object> toJson() => {
        if (resourceIdentifierUri != null)
          resourceIdentifierKey: resourceIdentifierUri!.toFilePath(),
        buildConfigKey: buildConfig.toJson(),
        assetsKey: AssetImpl.listToJson(assetsForLinking, buildConfig.version),
      }.sortOnKey();
}
