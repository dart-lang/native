/// The two types of scripts which are hooked into the compilation process.
///
/// The `build.dart` script runs before, and the `link.dart` script after
/// compilation.
enum PipelineStep {
  link('link.dart'),
  build('build.dart');

  final String scriptName;

  const PipelineStep(this.scriptName);
}
