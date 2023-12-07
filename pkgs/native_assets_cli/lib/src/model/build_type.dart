import 'link_input.dart';

/// The two types of scripts which are hooked into the compilation process.
///
/// The `build.dart` script runs before, and the `link.dart` script after
/// compilation.
sealed class PipelineStep {
  String get scriptName;
  String get outputName;
  List<String> args(Uri configFile, Uri buildOutput, Uri? resources);

  const PipelineStep();

  String toYaml();
}

final class LinkStep extends PipelineStep {
  @override
  String get outputName => 'link_output.yaml';

  @override
  String get scriptName => 'link.dart';

  @override
  List<String> args(Uri configFile, Uri buildOutput, Uri? resources) =>
      LinkConfig.toArgs(buildOutput, configFile, resources);

  const LinkStep();

  @override
  String toYaml() => 'link';
}

final class BuildStep extends PipelineStep {
  @override
  String get outputName => 'build_output.yaml';

  @override
  String get scriptName => 'build.dart';

  @override
  @override
  List<String> args(Uri configFile, Uri buildOutput, Uri? resources) => [
        '--config=${configFile.toFilePath()}',
      ];

  const BuildStep();

  @override
  String toYaml() => 'build';
}
