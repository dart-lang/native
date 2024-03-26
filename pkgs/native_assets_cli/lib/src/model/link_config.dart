// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_config.dart';

/// The input to the linking script.
///
/// It consists of the [_buildConfig] already passed to the build script, the
/// [assets] from the build step, and the [resources] generated during the
/// kernel compilation.
class LinkConfigImpl extends PipelineConfigImpl implements LinkConfig {
  @override
  final List<Asset> assets;

  final BuildConfigImpl _buildConfig;

  @override
  final List<Resource> resources;

  final LinkConfigArgs _args;

  LinkConfigImpl(
    this._args, {
    required this.assets,
    required BuildConfigImpl buildConfig,
    required ResourceIdentifiers? resourceIdentifiers,
  })  : _buildConfig = buildConfig,
        resources = (resourceIdentifiers?.identifiers ?? [])
            .map((e) => Resource(name: e.name, metadata: e.id))
            .toList();

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
  Uri get script =>
      packageRoot.resolve('hook/').resolve(PipelineStep.link.scriptName);

  @override
  String toJsonString() => jsonEncode(_args.toJson());

  @override
  Version get version => _buildConfig.version;

  static LinkConfig fromArguments(List<String> arguments) {
    final argParser = ArgParser()..addOption('config');

    final results = argParser.parse(arguments);
    final linkConfigContents =
        File(results['config'] as String).readAsStringSync();
    final linkConfigJson =
        jsonDecode(linkConfigContents) as Map<String, dynamic>;

    return LinkConfigArgs.fromJson(linkConfigJson).toLinkConfig();
  }
}

class LinkConfigArgs {
  final Uri? resourceIdentifierUri;
  final Uri buildConfigUri;
  final List<AssetImpl> assetsForLinking;

  static const resourceIdentifierKey = 'resource_identifiers';
  static const buildConfigKey = 'build_config';
  static const assetsKey = 'assets';

  LinkConfigArgs({
    required this.resourceIdentifierUri,
    required this.buildConfigUri,
    required this.assetsForLinking,
  });

  factory LinkConfigArgs.fromJson(Map<String, dynamic> linkConfigJson) {
    final resourcesPath = linkConfigJson[resourceIdentifierKey] as String?;
    final buildConfigPath = linkConfigJson[buildConfigKey] as String?;
    final assetList = linkConfigJson[assetsKey] as List<Object?>?;
    if (buildConfigPath == null || assetList == null) {
      throw ArgumentError('Expected to find the build config and assetList in '
          '$linkConfigJson');
    }
    return LinkConfigArgs(
      resourceIdentifierUri:
          resourcesPath != null ? Uri.file(resourcesPath) : null,
      buildConfigUri: Uri.file(buildConfigPath),
      assetsForLinking: AssetImpl.listFromJson(assetList),
    );
  }

  LinkConfigImpl toLinkConfig() => LinkConfigImpl(
        this,
        buildConfig: _readBuildConfig(),
        resourceIdentifiers: _readResources(),
        assets: assetsForLinking,
      );

  ResourceIdentifiers? _readResources() {
    if (resourceIdentifierUri == null) {
      return null;
    }
    return ResourceIdentifiers.fromFile(resourceIdentifierUri!.toFilePath());
  }

  BuildConfigImpl _readBuildConfig() {
    final buildConfigFile = File(buildConfigUri.toFilePath());
    if (!buildConfigFile.existsSync()) {
      throw UnsupportedError(
          'A link.dart script needs the build configuration to be executed. '
          'The build configuration at ${buildConfigUri.toFilePath()} could not '
          'be found.');
    }
    return BuildConfigImpl.fromConfig(
      Config.fromConfigFileContents(
        fileContents: buildConfigFile.readAsStringSync(),
      ),
    );
  }

  Map<String, Object> toJson() => {
        if (resourceIdentifierUri != null)
          resourceIdentifierKey: resourceIdentifierUri!.toFilePath(),
        buildConfigKey: buildConfigUri.toFilePath(),
        assetsKey:
            AssetImpl.listToJson(assetsForLinking, _readBuildConfig().version),
      };
}
