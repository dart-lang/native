import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_config/cli_config.dart';

import 'build_config.dart';
import 'build_output.dart';
import 'resources.dart';

/// The input to the linking script.
///
/// It consists of the [buildConfig] already passed to the build script, the
/// result of the build step [buildOutput], and the [resourceIdentifiers]
/// generated during the kernel compilation.
class LinkConfig {
  final Map<String, BuildOutput> buildOutput;
  final BuildConfig buildConfig;
  final ResourceIdentifiers? resourceIdentifiers;

  LinkConfig._({
    required this.buildOutput,
    required this.buildConfig,
    required this.resourceIdentifiers,
  });

  /// Generate the [LinkConfig] from the input arguments to the linking script.
  static Future<LinkConfig> fromArgs(List<String> args) async {
    final argParser = ArgParser()
      ..addOption('build_output')
      ..addOption('resource_identifiers')
      ..addOption('config');

    final results = argParser.parse(args);
    final config = Config.fromConfigFileContents(
        fileContents: File(results['config'] as String).readAsStringSync());
    final buildConfig = BuildConfig.fromConfig(config);

    final buildOutputPath = results['build_output'] as String;
    final buildOutput =
        BuildOutput.fromYamlString(File(buildOutputPath).readAsStringSync());

    final resourceIdentifierPath = results['resource_identifiers'] as String?;
    ResourceIdentifiers? resourceIdentifiers;
    if (resourceIdentifierPath != null) {
      resourceIdentifiers =
          ResourceIdentifiers.fromFile(resourceIdentifierPath);
    }

    return LinkConfig._(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      resourceIdentifiers: resourceIdentifiers,
    );
  }

  static List<String> toArgs(
          Uri buildOutput, Uri buildConfig, Uri? resources) =>
      [
        '--config=${buildConfig.toFilePath()}',
        '--build_output=${buildOutput.toFilePath()}',
        if (resources != null)
          '--resource_identifiers=${resources.toFilePath()}',
      ];
}
