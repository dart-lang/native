import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:yaml/yaml.dart';

import '../api/link_config.dart' as api;
import '../api/resources.dart';
import 'build_config.dart';
import 'build_output.dart';
import 'pipeline_step.dart';

/// The input to the linking script.
///
/// It consists of the [buildConfig] already passed to the build script, the
/// result of the build step [buildOutput], and the [resourceIdentifiers]
/// generated during the kernel compilation.
class LinkConfig extends api.LinkConfig {
  @override
  final BuildOutput buildOutput;

  @override
  final BuildConfig buildConfig;

  @override
  final ResourceIdentifiers? resourceIdentifiers;

  final LinkConfigArgs _args;

  LinkConfig(
    this._args, {
    required this.buildOutput,
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

  Future<LinkConfig> fromArgs() async {
    final config = BuildConfig.fromConfig(
      Config.fromConfigFileContents(
        fileContents: File(buildConfigUri.path).readAsStringSync(),
      ),
    );
    ResourceIdentifiers? resources;
    if (resourceIdentifierUri != null) {
      resources = ResourceIdentifiers.fromFile(resourceIdentifierUri!.path);
    }

    final readFromFile =
        await BuildOutput.readFromFile(outputUri: config.output);
    return LinkConfig(
      this,
      buildOutput: readFromFile!,
      buildConfig: config,
      resourceIdentifiers: resources,
    );
  }

  Map<String, Object> toYaml() => {
        if (resourceIdentifierUri != null)
          resourceIdentifierKey: resourceIdentifierUri!.toFilePath(),
        buildConfigKey: buildConfigUri.toFilePath(),
      };
}
