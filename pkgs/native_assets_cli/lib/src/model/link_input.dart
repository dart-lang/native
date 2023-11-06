import 'build_config.dart';
import 'build_output.dart';
import 'resources.dart';

/// The input to the linking script.
///
/// It consists of the [buildConfig] already passed to the build script, the
/// result of the build step [buildOutput], and the [resourceIdentifiers]
/// generated during the kernel compilation.
class LinkInput {
  final BuildConfig buildConfig;
  final BuildOutput buildOutput;
  final ResourceIdentifiers resourceIdentifiers;

  LinkInput._({
    required this.buildConfig,
    required this.buildOutput,
    required this.resourceIdentifiers,
  });

  /// Generate the [LinkInput] from the input arguments to the linking script.
  static Future<LinkInput> fromArgs(List<String> args) async {
    final buildConfig = await BuildConfig.fromArgs(args);
    final buildOutput = BuildOutput.fromYamlString(args);
    final resourceIdentifiers = ResourceIdentifiers.fromFile();
    return LinkInput._(
      buildConfig: buildConfig,
      buildOutput: buildOutput,
      resourceIdentifiers: resourceIdentifiers,
    );
  }
}
