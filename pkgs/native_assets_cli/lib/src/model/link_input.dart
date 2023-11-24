import 'dart:io';

import 'package:cli_config/cli_config.dart';

import 'build_config.dart';
import 'build_output.dart';
import 'resources.dart';

/// The input to the linking script.
///
/// It consists of the [buildConfig] already passed to the build script, the
/// result of the build step [buildOutput], and the [resourceIdentifiers]
/// generated during the kernel compilation.
class LinkInput {
  final BuildOutput buildOutput;
  final BuildConfig buildConfig;
  final ResourceIdentifiers? resourceIdentifiers;

  LinkInput._({
    required this.buildOutput,
    required this.buildConfig,
    required this.resourceIdentifiers,
  });

  /// Generate the [LinkInput] from the input arguments to the linking script.
  static Future<LinkInput> fromArgs(List<String> args) async {
    final config = await Config.fromArgs(args: args);
    final buildOutputPath = config.string('build_output');
    final buildConfigPath = config.string('build_config');
    final resourceIdentifierPath =
        config.optionalString('resource_identifiers');
    final buildConfig = BuildConfig.fromConfig(Config.fromConfigFileContents(
      fileSourceUri: Uri.parse(buildConfigPath),
    ));
    final buildOutput =
        BuildOutput.fromYamlString(File(buildOutputPath).readAsStringSync());

    ResourceIdentifiers? resourceIdentifiers;
    if (resourceIdentifierPath != null) {
      resourceIdentifiers =
          ResourceIdentifiers.fromFile(resourceIdentifierPath);
    }
    return LinkInput._(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      resourceIdentifiers: resourceIdentifiers,
    );
  }
}
