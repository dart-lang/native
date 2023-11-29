import 'link_input.dart';

/// The two types of scripts which are hooked into the compilation process.
///
/// The `build.dart` script runs before, and the `link.dart` script after
/// compilation.
sealed class RunStep {
  String get scriptName;
  String get outputName;
  List<String> args(Uri configFile, Uri buildOutput, Uri? resources);

  const RunStep();
}

final class LinkStep extends RunStep {
  @override
  String get outputName => 'link_output.yaml';

  @override
  String get scriptName => 'link.dart';

  @override
  List<String> args(Uri configFile, Uri buildOutput, Uri? resources) =>
      LinkInput.toArgs(buildOutput, configFile, resources);

  const LinkStep();
}

final class BuildStep extends RunStep {
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
}
