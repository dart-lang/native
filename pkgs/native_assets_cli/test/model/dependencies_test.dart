// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  late Uri tempUri;

  setUp(() async => tempUri = (await Directory.systemTemp.createTemp()).uri);

  tearDown(
      () async => await Directory.fromUri(tempUri).delete(recursive: true));

  final dependencies = Dependencies([
    Uri.file('src/bar.c'),
    Uri.file('src/baz.c'),
    Uri.directory('src/bla/'),
    Uri.file('build.dart'),
  ]);

  const yamlEncoding = '''- src/bar.c
- src/baz.c
- src/bla/
- build.dart''';

  test('dependencies yaml', () {
    final yaml = dependencies.toYamlString().replaceAll('\\', '/');
    expect(yaml, yamlEncoding);
    final dependencies2 = Dependencies.fromYamlString(yaml);
    expect(dependencies.hashCode, dependencies2.hashCode);
    expect(dependencies, dependencies2);
  });

  test('dependencies toString', dependencies.toString);

  test('dependencies fromYamlString', () {
    final dependencies = Dependencies.fromYamlString('');
    expect(dependencies, Dependencies([]));
  });

  test('dependencies lastModified', () async {
    final dirUri = tempUri.resolve('foo/');
    final dir = Directory.fromUri(dirUri);
    await dir.create();
    final fileUri = tempUri.resolve('bla.c');
    final file = File.fromUri(fileUri);
    await file.writeAsString('dummy contents');
    final dependencies = Dependencies([dirUri, fileUri]);
    expect(await dependencies.lastModified(), await file.lastModified());
  });

  test('dependencies lastModified symlinks', () async {
    final symlink = Link.fromUri(tempUri.resolve('my_link'));
    await symlink.create(tempUri.toFilePath());

    final someFileUri = tempUri.resolve('foo.txt');
    final someFile = File.fromUri(someFileUri);
    await someFile.writeAsString('yay!');

    final dependencies = Dependencies([tempUri]);
    expect(await dependencies.lastModified(), await someFile.lastModified());
  });

  test('dependencies lastModified does not exist', () async {
    final someFileUri = tempUri.resolve('foo.txt');
    final someFile = File.fromUri(someFileUri);
    await someFile.writeAsString('yay!');

    final deletedFileUri = tempUri.resolve('bar.txt');

    final now = DateTime.now();

    final dependencies = Dependencies([
      someFileUri,
      deletedFileUri,
    ]);
    final depsLastModified = await dependencies.lastModified();
    expect(depsLastModified == now || depsLastModified.isAfter(now), true);
  });
}
