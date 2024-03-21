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

  final BuildConfig _buildConfig;

  @override
  final ResourceIdentifiers? resourceIdentifiers;

  final LinkConfigArgs _args;

  LinkConfigImpl(
    this._args, {
    required this.assets,
    required BuildConfig buildConfig,
    required this.resourceIdentifiers,
  }) : _buildConfig = buildConfig;

  @override
  Uri get configFile => outDirectory.resolve('../link_config.yaml');

  @override
  Uri get outDirectory => _buildConfig.outDirectory;

  @override
  String get outputName => 'link_output.yaml';

  @override
  String get packageName => _buildConfig.packageName;

  @override
  Uri get packageRoot => _buildConfig.packageRoot;

  @override
  Uri get script => packageRoot.resolve(PipelineStep.link.scriptName);

  @override
  String toJsonString() => jsonEncode(_args.toJson());

  @override
  Version get version => throw UnimplementedError();
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

  factory LinkConfigArgs.fromYaml(YamlMap yaml) {
    final resourceUri = yaml[resourceIdentifierKey] as String?;
    return LinkConfigArgs(
      resourceIdentifierUri:
          resourceUri != null ? Uri.parse(resourceUri) : null,
      buildConfigUri: Uri.parse(yaml[buildConfigKey] as String),
    );
  }

  Future<LinkConfigImpl> fromArgs() async {
    final buildConfigFile = File(buildConfigUri.path);
    if (!buildConfigFile.existsSync()) {
      throw UnsupportedError(
          'A link.dart script needs a build.dart to be executed');
    }
    final readAsStringSync = buildConfigFile.readAsStringSync();
    final config = BuildConfigImpl.fromConfig(
      Config.fromConfigFileContents(
        fileContents: readAsStringSync,
      ),
    );
    ResourceIdentifiers? resources;
    if (resourceIdentifierUri != null) {
      resources = ResourceIdentifiers.fromFile(resourceIdentifierUri!.path);
    }

    final buildOutput =
        await BuildOutputImpl.readFromFile(file: config.outputFile);
    return LinkConfigImpl(
      this,
      assets: buildOutput!.assetsForLinking[config.packageName] ?? [],
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
