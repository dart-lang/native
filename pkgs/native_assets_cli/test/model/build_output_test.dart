// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:native_assets_cli/src/utils/yaml.dart';
import 'package:pub_semver/pub_semver.dart';
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
      NativeCodeAssetImpl(
        id: 'package:my_package/foo',
        file: Uri(path: 'path/to/libfoo.so'),
        dynamicLoading: BundledDylibImpl(),
        os: OSImpl.android,
        architecture: ArchitectureImpl.x64,
        linkMode: LinkModeImpl.dynamic,
      ),
      NativeCodeAssetImpl(
        id: 'package:my_package/foo2',
        dynamicLoading: SystemDylibImpl(Uri(path: 'path/to/libfoo2.so')),
        os: OSImpl.android,
        architecture: ArchitectureImpl.x64,
        linkMode: LinkModeImpl.dynamic,
      ),
      NativeCodeAssetImpl(
        id: 'package:my_package/foo3',
        dynamicLoading: LookupInProcessImpl(),
        os: OSImpl.android,
        architecture: ArchitectureImpl.x64,
        linkMode: LinkModeImpl.dynamic,
      ),
      NativeCodeAssetImpl(
        id: 'package:my_package/foo4',
        dynamicLoading: LookupInExecutableImpl(),
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
  - id: package:my_package/foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_x64
  - id: package:my_package/foo2
    link_mode: dynamic
    path:
      path_type: system
      uri: path/to/libfoo2.so
    target: android_x64
  - id: package:my_package/foo3
    link_mode: dynamic
    path:
      path_type: process
    target: android_x64
  - id: package:my_package/foo4
    link_mode: dynamic
    path:
      path_type: executable
    target: android_x64
dependencies:
  - path/to/file.ext
metadata:
  key: value
version: 1.0.0''';

  final yamlEncoding = '''timestamp: 2022-11-10 13:25:01.000
assets:
  - architecture: x64
    dynamic_loading:
      type: bundle
    file: path/to/libfoo.so
    id: package:my_package/foo
    link_mode: dynamic
    os: android
    type: native_code
  - architecture: x64
    dynamic_loading:
      type: system
      uri: path/to/libfoo2.so
    id: package:my_package/foo2
    link_mode: dynamic
    os: android
    type: native_code
  - architecture: x64
    dynamic_loading:
      type: process
    id: package:my_package/foo3
    link_mode: dynamic
    os: android
    type: native_code
  - architecture: x64
    dynamic_loading:
      type: executable
    id: package:my_package/foo4
    link_mode: dynamic
    os: android
    type: native_code
dependencies:
  - path/to/file.ext
metadata:
  key: value
version: ${BuildOutputImpl.latestVersion}''';

  test('built info yaml', () {
    final yaml = buildOutput
        .toYamlString(BuildOutputImpl.latestVersion)
        .replaceAll('\\', '/');
    expect(yaml, yamlEncoding);
    final buildOutput2 = BuildOutputImpl.fromYamlString(yaml);
    expect(buildOutput.hashCode, buildOutput2.hashCode);
    expect(buildOutput, buildOutput2);
  });

  test('built info yaml v1.0.0 parsing keeps working', () {
    final buildOutput2 = BuildOutputImpl.fromYamlString(yamlEncodingV1_0_0);
    expect(buildOutput.hashCode, buildOutput2.hashCode);
    expect(buildOutput, buildOutput2);
  });

  test('built info yaml v1.0.0 serialization keeps working', () {
    final yamlEncoding =
        yamlEncode(buildOutput.toYaml(Version(1, 0, 0))).replaceAll('\\', '/');
    expect(yamlEncoding, yamlEncodingV1_0_0);
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
    final packageRoot = tempUri.resolve('package_root/');
    await Directory.fromUri(outDir).create();
    await Directory.fromUri(packageRoot).create();
    final config = BuildConfigImpl(
      outDir: outDir,
      packageName: 'dontcare',
      packageRoot: packageRoot,
      buildMode: BuildModeImpl.debug,
      targetArchitecture: ArchitectureImpl.arm64,
      targetOS: OSImpl.macOS,
      linkModePreference: LinkModePreferenceImpl.dynamic,
    );
    await buildOutput.writeToFile(config: config);
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
              e.message.contains(BuildOutputImpl.latestVersion.toString()),
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
version: ${BuildOutputImpl.latestVersion}'''),
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
version: ${BuildOutputImpl.latestVersion}'''),
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
version: ${BuildOutputImpl.latestVersion}'''),
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

  test('BuildOutput setters', () {
    final buildOutput = BuildOutputImpl(
      timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
      assets: [
        NativeCodeAssetImpl(
          id: 'package:my_package/foo',
          file: Uri(path: 'path/to/libfoo.so'),
          dynamicLoading: BundledDylibImpl(),
          os: OSImpl.android,
          architecture: ArchitectureImpl.x64,
          linkMode: LinkModeImpl.dynamic,
        ),
        NativeCodeAssetImpl(
          id: 'package:my_package/foo2',
          dynamicLoading: SystemDylibImpl(Uri(path: 'path/to/libfoo2.so')),
          os: OSImpl.android,
          architecture: ArchitectureImpl.x64,
          linkMode: LinkModeImpl.dynamic,
        ),
      ],
      dependencies: Dependencies([
        Uri.file('path/to/file.ext'),
        Uri.file('path/to/file2.ext'),
      ]),
      metadata: const Metadata({
        'key': 'value',
        'key2': 'value2',
      }),
    );

    final buildOutput2 = BuildOutputImpl(
      timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
    );
    buildOutput2.addAsset(
      NativeCodeAssetImpl(
        id: 'package:my_package/foo',
        file: Uri(path: 'path/to/libfoo.so'),
        dynamicLoading: BundledDylibImpl(),
        os: OSImpl.android,
        architecture: ArchitectureImpl.x64,
        linkMode: LinkModeImpl.dynamic,
      ),
    );
    buildOutput2.addAssets([
      NativeCodeAssetImpl(
        id: 'package:my_package/foo2',
        dynamicLoading: SystemDylibImpl(Uri(path: 'path/to/libfoo2.so')),
        os: OSImpl.android,
        architecture: ArchitectureImpl.x64,
        linkMode: LinkModeImpl.dynamic,
      ),
    ]);
    buildOutput2.addDependency(
      Uri.file('path/to/file.ext'),
    );
    buildOutput2.addDependencies([
      Uri.file('path/to/file2.ext'),
    ]);
    buildOutput2.addMetadata({
      'key': 'value',
    });
    buildOutput2.addMetadatum('key2', 'value2');

    expect(buildOutput2, equals(buildOutput));
    expect(
        buildOutput2.dependenciesModel, equals(buildOutput.dependenciesModel));
    expect(buildOutput2.metadataModel, equals(buildOutput.metadataModel));
  });
}
