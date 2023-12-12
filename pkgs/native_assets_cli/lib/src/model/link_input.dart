import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_config/cli_config.dart';
import 'package:yaml/yaml.dart';

import 'asset.dart';
import 'build_config.dart';
import 'build_output.dart';
import 'build_type.dart';
import 'pipeline_config.dart';
import 'resources.dart';

/// The input to the linking script.
///
/// It consists of the [buildConfig] already passed to the build script, the
/// result of the build step [assets], and the [resourceIdentifiers]
/// generated during the kernel compilation.
class LinkConfig extends PipelineConfig {
  final List<Asset> assets;
  final BuildConfig buildConfig;
  final ResourceIdentifiers? resourceIdentifiers;

  final LinkConfigArgs _args;

  LinkConfig(
    this._args, {
    required this.assets,
    required this.buildConfig,
    required this.resourceIdentifiers,
  });

  /// Generate the [LinkConfig] from the input arguments to the linking script.
  static Future<LinkConfig> fromArgs(List<String> args) async {
    final argParser = ArgParser()..addOption('link_config');

    final results = argParser.parse(args);
    final yaml =
        loadYaml(File(results['link_config'] as String).readAsStringSync())
            as YamlMap;

    return LinkConfigArgs.fromYaml(yaml).fromArgs();
  }

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

  LinkConfigArgs({
    required this.resourceIdentifiers,
    required this.buildConfig,
    required this.builtAssets,
  });

  factory LinkConfigArgs.fromYaml(YamlMap yaml) {
    final resourceUri = yaml['resource_identifiers'] as String? ?? '';
    return LinkConfigArgs(
      resourceIdentifiers: Uri.tryParse(resourceUri),
      buildConfig: Uri.parse(yaml['build_config'] as String),
      builtAssets: Uri.parse(yaml['built_assets'] as String),
    );
  }

  LinkConfig fromArgs() {
    final assetsYaml =
        loadYaml(File(builtAssets.path).readAsStringSync()) as YamlMap;
    final assetYamlList = assetsYaml['native-assets'] as YamlList;
    final assets = Asset.listFromYamlList(assetYamlList);
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
          'resource_identifiers': resourceIdentifiers!,
        'assets': builtAssets,
        'build_config': buildConfig,
      };
}
