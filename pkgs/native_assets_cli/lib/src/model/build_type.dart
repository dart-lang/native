import 'link_input.dart';

/// The two types of scripts which are hooked into the compilation process.
///
/// The [build] script runs before, and the [link] script after compilation.
// enum BuildType {
//   build,
//   link;

//   static RunType getType(BuildType type) => switch (type) {
//         BuildType.build => const BuildType2(),
//         BuildType.link => const LinkType(),
//       };
// }

/// The two types of scripts which are hooked into the compilation process.
///
/// The [build] script runs before, and the [link] script after compilation.
sealed class RunType {
  String get scriptName;
  String get outputName;
  List<String> args(Uri configFile, Uri buildOutput, Uri? resources);
}

final class LinkType extends RunType {
  @override
  String get outputName => 'link_output.yaml';

  @override
  String get scriptName => 'link.dart';

  @override
  List<String> args(Uri configFile, Uri buildOutput, Uri? resources) =>
      LinkInput.toArgs(buildOutput, configFile, resources);
}

final class BuildType extends RunType {
  @override
  String get outputName => 'build_output.yaml';

  @override
  String get scriptName => 'build.dart';

  @override
  @override
  List<String> args(Uri configFile, Uri buildOutput, Uri? resources) => [
        '--config=${configFile.toFilePath()}',
      ];
}
