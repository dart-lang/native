import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _whitespace = RegExp(r'\s+');

void expectString(String a, String b) {
  final trimmedA = a.replaceAll(_whitespace, '');
  final trimmedB = b.replaceAll(_whitespace, '');

  expect(trimmedA, trimmedB);
}

String testDir = p.normalize(
  p.join(
    Isolate.resolvePackageUriSync(
      Uri.parse('package:swift2objc/swift2objc.dart'),
    )!.toFilePath(),
    '..',
    '..',
    'test',
  ),
);
