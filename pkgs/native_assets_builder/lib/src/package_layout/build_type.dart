/// The two types of scripts which are hooked into the compilation process.
///
/// The [build] script runs before, and the [link] script after compilation.
enum BuildType {
  build('build.dart'),
  link('link.dart');

  final String scriptName;

  const BuildType(this.scriptName);
}
