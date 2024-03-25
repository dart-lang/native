// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../api/link_config.dart';

/// The input to the linking script.
///
/// It consists of the [_buildConfig] already passed to the build script, the
/// [assets] from the build step, and the [resourceIdentifiers]
/// generated during the kernel compilation.
class LinkConfigImpl extends PipelineConfigImpl implements LinkConfig {
  @override
  final List<Asset> assets;

  final BuildConfigImpl _buildConfig;

  @override
  final ResourceIdentifiers? resourceIdentifiers;

  final LinkConfigArgs _args;

  LinkConfigImpl(
    this._args, {
    required this.assets,
    required BuildConfigImpl buildConfig,
    required this.resourceIdentifiers,
  }) : _buildConfig = buildConfig;

  @override
  Uri get configFile => outDirectory.resolve('../link_config.json');

  @override
  Uri get outDirectory => _buildConfig.outDirectory;

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
}

class LinkConfigArgs {
  final Uri? resourceIdentifierUri;
  final Uri buildConfigUri;

  static const resourceIdentifierKey = 'resource_identifiers';
  static const buildConfigKey = 'build_config';

  LinkConfigArgs({
    required this.resourceIdentifierUri,
    required this.buildConfigUri,
  });

  factory LinkConfigArgs.fromJson(Map<String, dynamic> linkConfigJson) {
    final resourcesPath = linkConfigJson[resourceIdentifierKey] as String?;
    final buildConfigPath = linkConfigJson[buildConfigKey] as String?;
    if (buildConfigPath == null) {
      throw ArgumentError(
          'Expected to find the build config in $linkConfigJson');
    }
    return LinkConfigArgs(
      resourceIdentifierUri:
          resourcesPath != null ? Uri.file(resourcesPath) : null,
      buildConfigUri: Uri.file(buildConfigPath),
    );
  }

  Future<LinkConfigImpl> toLinkConfig() async {
    final buildConfigFile = File(buildConfigUri.toFilePath());
    if (!buildConfigFile.existsSync()) {
      throw UnsupportedError(
          'A link.dart script needs the build configuration to be executed. '
          'The build configuration at ${buildConfigUri.toFilePath()} could not '
          'be found.');
    }
    final config = BuildConfigImpl.fromConfig(
      Config.fromConfigFileContents(
        fileContents: buildConfigFile.readAsStringSync(),
      ),
    );
    ResourceIdentifiers? resources;
    if (resourceIdentifierUri != null) {
      resources =
          ResourceIdentifiers.fromFile(resourceIdentifierUri!.toFilePath());
    }

    final buildOutput =
        await BuildOutputImpl.readFromFile(file: config.outputFile);
    if (buildOutput == null) {
      throw ArgumentError(
          'Expected to find the build output at ${config.outputFile}');
    }
    return LinkConfigImpl(
      this,
      assets: buildOutput.assetsForLinking[config.packageName] ?? [],
      buildConfig: config,
      resourceIdentifiers: resources,
    );
  }

  Map<String, Object> toJson() => {
        if (resourceIdentifierUri != null)
          resourceIdentifierKey: resourceIdentifierUri!.toFilePath(),
        buildConfigKey: buildConfigUri.toFilePath(),
      };
}
