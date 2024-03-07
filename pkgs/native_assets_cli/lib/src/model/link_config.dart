// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_config/cli_config.dart';
import 'package:yaml/yaml.dart';

import '../api/link_config.dart' as api;
import '../api/resources.dart';
import 'asset.dart';
import 'build_config.dart';
import 'build_output.dart';
import 'pipeline_step.dart';

/// The input to the linking script.
///
/// It consists of the [buildConfig] already passed to the build script, the
/// [assets] from the build step, and the [resourceIdentifiers]
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
  Uri get configFile => outDirectory.resolve('../link_config.yaml');

  @override
  Uri get outDirectory => buildConfig.outDirectory;

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
    final buildConfigFile = File(buildConfigUri.path);
    if (!buildConfigFile.existsSync()) {
      throw UnsupportedError(
          'A link.dart script needs a build.dart to be executed');
    }
    final readAsStringSync = buildConfigFile.readAsStringSync();
    final config = BuildConfig.fromConfig(
      Config.fromConfigFileContents(
        fileContents: readAsStringSync,
      ),
    );
    ResourceIdentifiers? resources;
    if (resourceIdentifierUri != null) {
      resources = ResourceIdentifiers.fromFile(resourceIdentifierUri!.path);
    }

    final buildOutput =
        await BuildOutput.readFromFile(outputUri: config.outDir);
    return LinkConfig(
      this,
      assets: buildOutput!.assets
          .where((element) => element.linkInPackage == config.packageName)
          .toList(),
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
