import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:yaml/yaml.dart';

import '../api/link_config.dart' as api;
import '../api/resources.dart';
import 'asset.dart';
import 'build_config.dart';
import 'pipeline_step.dart';

/// The input to the linking script.
///
/// It consists of the [buildConfig] already passed to the build script, the
/// result of the build step [assets], and the [resourceIdentifiers]
/// generated during the kernel compilation.
class LinkConfig extends api.LinkConfig {
  @override
  final List<Asset> assets;

  @override
  final BuildConfig buildConfig;

  @override
  final ResourceIdentifiers? resourceIdentifiers;

  final LinkConfigArgs _args;

  LinkConfig(
    this._args, {
    required this.assets,
    required this.buildConfig,
    required this.resourceIdentifiers,
  });

  @override
  Uri get configFile => outDir.resolve('../link_config.yaml');

  @override
  Uri get outDir => buildConfig.outDir;

  @override
  String get outputName => 'link_output.yaml';

  @override
  String get packageName => buildConfig.packageName;

  @override
  Uri get packageRoot => buildConfig.packageRoot;

  @override
  Map<String, Object> toYaml() => _args.toYaml();

  @override
  Uri get script => packageRoot.resolve(PipelineStep.link.scriptName);
}

class LinkConfigArgs {
  final Uri? resourceIdentifiers;
  final Uri buildConfig;
  final Uri builtAssets;

  static const resourceIdentifierKey = 'resource_identifiers';
  static const assetsKey = 'assets';
  static const buildConfigKey = 'build_config';

  LinkConfigArgs({
    required this.resourceIdentifiers,
    required this.buildConfig,
    required this.builtAssets,
  });

  factory LinkConfigArgs.fromYaml(YamlMap yaml) {
    final resourceUri = yaml[resourceIdentifierKey] as String?;
    return LinkConfigArgs(
      resourceIdentifiers: resourceUri != null ? Uri.parse(resourceUri) : null,
      buildConfig: Uri.parse(yaml[buildConfigKey] as String),
      builtAssets: Uri.parse(yaml[assetsKey] as String),
    );
  }

  LinkConfig fromArgs() {
    final assets =
        Asset.listFromYamlString(File(builtAssets.path).readAsStringSync());
    final config = BuildConfig.fromConfig(
      Config.fromConfigFileContents(
        fileContents: File(buildConfig.path).readAsStringSync(),
      ),
    );
    ResourceIdentifiers? resources;
    if (resourceIdentifiers != null) {
      resources = ResourceIdentifiers.fromFile(resourceIdentifiers!.path);
    }

    return LinkConfig(
      this,
      assets: assets,
      buildConfig: config,
      resourceIdentifiers: resources,
    );
  }

  Map<String, Object> toYaml() => {
        if (resourceIdentifiers != null)
          resourceIdentifierKey: resourceIdentifiers!.toFilePath(),
        assetsKey: builtAssets.toFilePath(),
        buildConfigKey: buildConfig.toFilePath(),
      };
}
