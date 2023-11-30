// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:test/test.dart';

void main() {
  late Uri tempUri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  final buildOutput = BuildOutput(
    timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
    assets: [
      Asset(
        id: 'foo',
        path: AssetAbsolutePath(Uri(path: 'path/to/libfoo.so')),
        target: Target.androidX64,
        linkMode: LinkMode.dynamic,
      ),
      Asset(
        id: 'foo2',
        path: AssetRelativePath(Uri(path: 'path/to/libfoo2.so')),
        target: Target.androidX64,
        linkMode: LinkMode.dynamic,
      ),
    ],
    dependencies: Dependencies([
      Uri.file('path/to/file.ext'),
    ]),
    metadata: const Metadata({
      'key': 'value',
    }),
  );

  final yamlEncoding = '''timestamp: 2022-11-10 13:25:01.000
assets:
  - id: foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_x64
    type: code
  - id: foo2
    link_mode: dynamic
    path:
      path_type: relative
      uri: path/to/libfoo2.so
    target: android_x64
    type: code
dependencies:
  - path/to/file.ext
metadata:
  key: value
version: ${BuildOutput.version}''';

  test('built info yaml', () {
    final yaml = buildOutput.toYamlString().replaceAll('\\', '/');
    expect(yaml, yamlEncoding);
    final buildOutput2 = BuildOutput.fromYamlString(yaml);
    expect(buildOutput.hashCode, buildOutput2.hashCode);
    expect(buildOutput, buildOutput2);
  });

  test('BuildOutput.toString', buildOutput.toString);

  test('BuildOutput.hashCode', () {
    final buildOutput2 = BuildOutput.fromYamlString(yamlEncoding);
    expect(buildOutput.hashCode, buildOutput2.hashCode);

    final buildOutput3 = BuildOutput(
      timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
    );
    expect(buildOutput.hashCode != buildOutput3.hashCode, true);
  });

  test('BuildOutput.readFromFile BuildOutput.writeToFile', () async {
    final outDir = tempUri.resolve('out_dir/');
    await buildOutput.writeToFile(outDir: outDir, step: const BuildStep());
    final buildOutput2 =
        await BuildOutput.readFromFile(outDir: outDir, step: const BuildStep());
    expect(buildOutput2, buildOutput);
  });

  test('Round timestamp', () {
    final buildOutput3 = BuildOutput(
      timestamp: DateTime.parse('2022-11-10 13:25:01.372257'),
    );
    expect(buildOutput3.timestamp, DateTime.parse('2022-11-10 13:25:01.000'));
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('BuildOutput version $version', () {
      expect(
        () => BuildOutput.fromYamlString('version: $version'),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(version) &&
              e.message.contains(BuildConfig.version.toString()),
        )),
      );
    });
  }

  test('format exception', () {
    expect(
      () => BuildOutput.fromYamlString('''timestamp: 2022-11-10 13:25:01.000
assets:
  - name: foo
    link_mode: dynamic
    path:
      path_type:
        some: map
      uri: path/to/libfoo.so
    target: android_x64
dependencies: []
metadata:
  key: value
version: ${BuildOutput.version}'''),
      throwsFormatException,
    );
    expect(
      () => BuildOutput.fromYamlString('''timestamp: 2022-11-10 13:25:01.000
assets:
  - name: foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_x64
dependencies:
  1: foo
metadata:
  key: value
version: ${BuildOutput.version}'''),
      throwsFormatException,
    );
    expect(
      () => BuildOutput.fromYamlString('''timestamp: 2022-11-10 13:25:01.000
assets:
  - name: foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_x64
dependencies: []
metadata:
  123: value
version: ${BuildOutput.version}'''),
      throwsFormatException,
    );
  });

  test('BuildOutput dependencies can be modified', () {
    // TODO(https://github.com/dart-lang/native/issues/25):
    // Remove once dependencies are made immutable.
    final buildOutput = BuildOutput();
    expect(
      () => buildOutput.dependencies.dependencies
          .add(Uri.file('path/to/file.ext')),
      returnsNormally,
    );
  });
}
