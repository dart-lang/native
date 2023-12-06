import 'dart:io';

void main(List<String> arguments) => Directory.current
    .list(recursive: true)
    .where((f) => f.path.endsWith('pubspec_overrides.yaml'))
    .forEach((f) => f.deleteSync());
