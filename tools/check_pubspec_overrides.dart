import 'dart:io';

void main(List<String> arguments) async {
  final allPubspecs = await Directory.current
      .list(recursive: true)
      .where((f) => f.path.endsWith('pubspec.yaml'))
      .map((f) => f as File)
      .toList();
  final nativePubspecs =
      allPubspecs.where((f) => f.path.contains('pkgs/native_')).toList();
  final missingOverrides = nativePubspecs
      .map((element) =>
          File.fromUri(element.uri.resolve('pubspec_overrides.yaml')))
      .where((f) => !f.existsSync())
      .where((f) =>
          !f.path.endsWith('pkgs/native_assets_cli/pubspec_overrides.yaml'))
      .toList()
      .join('\n');
  if (missingOverrides.isEmpty) {
    print('No missing overrides.');
  } else {
    print('Missing overrides:');
    print(missingOverrides);
    exit(1);
  }
}
