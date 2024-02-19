// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:test/test.dart';

void main() {
  late Uri tempUri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  final buildOutput = BuildOutputImpl(
    timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
    assets: [
      CCodeAssetImpl(
        id: 'foo',
        file: Uri(path: 'path/to/libfoo.so'),
        path: AssetAbsolutePathImpl(),
        os: OSImpl.android,
        architecture: ArchitectureImpl.x64,
        linkMode: LinkModeImpl.dynamic,
      ),
      CCodeAssetImpl(
        id: 'foo2',
        path: AssetSystemPathImpl(Uri(path: 'path/to/libfoo2.so')),
        os: OSImpl.android,
        architecture: ArchitectureImpl.x64,
        linkMode: LinkModeImpl.dynamic,
      ),
    ],
    dependencies: Dependencies([
      Uri.file('path/to/file.ext'),
    ]),
    metadata: const Metadata({
      'key': 'value',
    }),
  );

  const yamlEncodingV1_0_0 = '''timestamp: 2022-11-10 13:25:01.000
assets:
  - id: foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_x64
  - id: foo2
    link_mode: dynamic
    path:
      path_type: system
      uri: path/to/libfoo2.so
    target: android_x64
dependencies:
  - path/to/file.ext
metadata:
  key: value
version: 1.0.0''';

  final yamlEncoding = '''timestamp: 2022-11-10 13:25:01.000
assets:
  - architecture: x64
    file: path/to/libfoo.so
    id: foo
    link_mode: dynamic
    os: android
    path:
      path_type: absolute
    type: c_code
  - architecture: x64
    id: foo2
    link_mode: dynamic
    os: android
    path:
      path_type: system
      uri: path/to/libfoo2.so
    type: c_code
dependencies:
  - path/to/file.ext
metadata:
  key: value
version: ${BuildOutputImpl.version}''';

  test('built info yaml', () {
    final yaml = buildOutput.toYamlString().replaceAll('\\', '/');
    expect(yaml, yamlEncoding);
    final buildOutput2 = BuildOutputImpl.fromYamlString(yaml);
    expect(buildOutput.hashCode, buildOutput2.hashCode);
    expect(buildOutput, buildOutput2);
  });

  test('built info yaml v1.0.0 keeps working', () {
    final buildOutput2 = BuildOutputImpl.fromYamlString(yamlEncodingV1_0_0);
    expect(buildOutput.hashCode, buildOutput2.hashCode);
    expect(buildOutput, buildOutput2);
  });

  test('BuildOutput.toString', buildOutput.toString);

  test('BuildOutput.hashCode', () {
    final buildOutput2 = BuildOutputImpl.fromYamlString(yamlEncoding);
    expect(buildOutput.hashCode, buildOutput2.hashCode);

    final buildOutput3 = BuildOutputImpl(
      timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
    );
    expect(buildOutput.hashCode != buildOutput3.hashCode, true);
  });

  test('BuildOutput.readFromFile BuildOutput.writeToFile', () async {
    final outDir = tempUri.resolve('out_dir/');
    await buildOutput.writeToFile(outDir: outDir);
    final buildOutput2 = await BuildOutputImpl.readFromFile(outDir: outDir);
    expect(buildOutput2, buildOutput);
  });

  test('Round timestamp', () {
    final buildOutput3 = BuildOutputImpl(
      timestamp: DateTime.parse('2022-11-10 13:25:01.372257'),
    );
    expect(buildOutput3.timestamp, DateTime.parse('2022-11-10 13:25:01.000'));
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('BuildOutput version $version', () {
      expect(
        () => BuildOutputImpl.fromYamlString('version: $version'),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(version) &&
              e.message.contains(BuildOutputImpl.version.toString()),
        )),
      );
    });
  }

  test('format exception', () {
    expect(
      () => BuildOutputImpl.fromYamlString('''timestamp: 2022-11-10 13:25:01.000
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
version: ${BuildOutputImpl.version}'''),
      throwsFormatException,
    );
    expect(
      () => BuildOutputImpl.fromYamlString('''timestamp: 2022-11-10 13:25:01.000
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
version: ${BuildOutputImpl.version}'''),
      throwsFormatException,
    );
    expect(
      () => BuildOutputImpl.fromYamlString('''timestamp: 2022-11-10 13:25:01.000
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
version: ${BuildOutputImpl.version}'''),
      throwsFormatException,
    );
  });

  test('BuildOutput dependencies can be modified', () {
    // TODO(https://github.com/dart-lang/native/issues/25):
    // Remove once dependencies are made immutable.
    final buildOutput = BuildOutputImpl();
    expect(
      () => buildOutput.addDependencies([Uri.file('path/to/file.ext')]),
      returnsNormally,
    );
  });
}
