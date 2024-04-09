// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import '../helpers.dart';

void main() {
  late Uri tempUri;

  setUp(() async {
    tempUri = (await Directory.systemTemp.createTemp()).uri;
  });

  tearDown(() async {
    await Directory.fromUri(tempUri).delete(recursive: true);
  });

  final dryRunOutput = HookOutputImpl(
    timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
    assets: [
      NativeCodeAssetImpl(
        id: 'package:my_package/foo',
        file: Uri(path: 'path/to/libfoo.so'),
        linkMode: DynamicLoadingBundledImpl(),
        os: OSImpl.android,
      ),
    ],
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

  const yamlEncodingV1_0_0dryRun = '''timestamp: 2022-11-10 13:25:01.000
assets:
  - id: package:my_package/foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_arm
  - id: package:my_package/foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_arm64
  - id: package:my_package/foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_ia32
  - id: package:my_package/foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_x64
  - id: package:my_package/foo
    link_mode: dynamic
    path:
      path_type: absolute
      uri: path/to/libfoo.so
    target: android_riscv64
version: 1.0.0''';

  final jsonEncoding = {
    'timestamp': '2022-11-10 13:25:01.000',
    'assets': [
      {
        'architecture': 'x64',
        'file': Uri.file('path/to/libfoo.so').toFilePath(),
        'id': 'package:my_package/foo',
        'link_mode': {'type': 'dynamic_loading_bundle'},
        'os': 'android',
        'type': 'native_code'
      },
      {
        'architecture': 'x64',
        'id': 'package:my_package/foo2',
        'link_mode': {
          'type': 'dynamic_loading_system',
          'uri': Uri.file('path/to/libfoo2.so').toFilePath(),
        },
        'os': 'android',
        'type': 'native_code'
      },
      {
        'architecture': 'x64',
        'id': 'package:my_package/foo3',
        'link_mode': {'type': 'dynamic_loading_process'},
        'os': 'android',
        'type': 'native_code'
      },
      {
        'architecture': 'x64',
        'id': 'package:my_package/foo4',
        'link_mode': {'type': 'dynamic_loading_executable'},
        'os': 'android',
        'type': 'native_code'
      }
    ],
    'assetsForLinking': {
      'my_package': [
        {
          'name': 'data',
          'package': 'my_package',
          'file': Uri.file('path/to/data').toFilePath(),
          'type': 'data'
        }
      ],
      'my_package_2': [
        {
          'name': 'data',
          'package': 'my_package',
          'file': Uri.file('path/to/data2').toFilePath(),
          'type': 'data'
        }
      ]
    },
    'dependencies': [
      Uri.file('path/to/file.ext').toFilePath(),
    ],
    'metadata': {'key': 'value'},
    'version': '${HookOutputImpl.latestVersion}'
  };

  test('built info json', () {
    final buildOutput = getBuildOutput();
    final json = buildOutput.toJson(HookOutputImpl.latestVersion);
    expect(json, jsonEncoding);

    final buildOutput2 = HookOutputImpl.fromJson(json);
    expect(buildOutput.hashCode, buildOutput2.hashCode);
    expect(buildOutput, buildOutput2);
  });

  test('built info yaml v1.0.0 parsing keeps working', () {
    final buildOutput = getBuildOutput(withLinkedAssets: false);
    final buildOutput2 = HookOutputImpl.fromJsonString(yamlEncodingV1_0_0);
    expect(buildOutput.hashCode, buildOutput2.hashCode);
    expect(buildOutput, buildOutput2);
  });

  test('built info yaml v1.0.0 serialization keeps working', () {
    final buildOutput = getBuildOutput(withLinkedAssets: false);
    final yamlEncoding =
        yamlEncode(buildOutput.toJson(Version(1, 0, 0))).unescape();
    expect(yamlEncoding, yamlEncodingV1_0_0);
  });

  test('built info yaml v1.0.0 serialization keeps working dry run', () {
    final yamlEncoding =
        yamlEncode(dryRunOutput.toJson(Version(1, 0, 0))).unescape();
    expect(yamlEncoding, yamlEncodingV1_0_0dryRun);
  });

  test('BuildOutput.toString', getBuildOutput().toString);

  test('BuildOutput.hashCode', () {
    final buildOutput = getBuildOutput();
    final buildOutput2 = HookOutputImpl.fromJson(jsonEncoding);
    expect(buildOutput.hashCode, buildOutput2.hashCode);

    final buildOutput3 = HookOutputImpl(
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
    final buildOutput = getBuildOutput();
    await buildOutput.writeToFile(config: config);
    final buildOutput2 = HookOutputImpl.readFromFile(file: config.outputFile);
    expect(buildOutput2, buildOutput);
  });

  test('BuildOutput.readFromFile BuildOutput.writeToFile V1.1.0', () async {
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
      version: Version(1, 1, 0),
    );
    final buildOutput = getBuildOutput(withLinkedAssets: false);
    await buildOutput.writeToFile(config: config);
    final buildOutput2 = HookOutputImpl.readFromFile(file: config.outputFile);
    expect(buildOutput2, buildOutput);
  });

  test('Round timestamp', () {
    final buildOutput3 = HookOutputImpl(
      timestamp: DateTime.parse('2022-11-10 13:25:01.372257'),
    );
    expect(buildOutput3.timestamp, DateTime.parse('2022-11-10 13:25:01.000'));
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('BuildOutput version $version', () {
      expect(
        () => HookOutputImpl.fromJsonString('version: $version'),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(version) &&
              e.message.contains(HookOutputImpl.latestVersion.toString()),
        )),
      );
    });
  }

  test('format exception', () {
    expect(
      () => HookOutputImpl.fromJsonString('''timestamp: 2022-11-10 13:25:01.000
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
version: 1.0.0'''),
      throwsFormatException,
    );
    expect(
      () => HookOutputImpl.fromJsonString('''timestamp: 2022-11-10 13:25:01.000
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
version: 1.0.0'''),
      throwsFormatException,
    );
    expect(
      () => HookOutputImpl.fromJsonString('''timestamp: 2022-11-10 13:25:01.000
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
version: 1.0.0'''),
      throwsFormatException,
    );
  });

  test('BuildOutput dependencies can be modified', () {
    final buildOutput = HookOutputImpl();
    expect(
      () => buildOutput.addDependencies([Uri.file('path/to/file.ext')]),
      returnsNormally,
    );
  });

  test('BuildOutput setters', () {
    final buildOutput = HookOutputImpl(
      timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
      assets: [
        NativeCodeAssetImpl(
          id: 'package:my_package/foo',
          file: Uri(path: 'path/to/libfoo.so'),
          linkMode: DynamicLoadingBundledImpl(),
          os: OSImpl.android,
          architecture: ArchitectureImpl.x64,
        ),
        NativeCodeAssetImpl(
          id: 'package:my_package/foo2',
          linkMode: DynamicLoadingSystemImpl(Uri(path: 'path/to/libfoo2.so')),
          os: OSImpl.android,
          architecture: ArchitectureImpl.x64,
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

    final buildOutput2 = HookOutputImpl(
      timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
    );
    buildOutput2.addAsset(
      NativeCodeAssetImpl(
        id: 'package:my_package/foo',
        file: Uri(path: 'path/to/libfoo.so'),
        linkMode: DynamicLoadingBundledImpl(),
        os: OSImpl.android,
        architecture: ArchitectureImpl.x64,
      ),
    );
    buildOutput2.addAssets([
      NativeCodeAssetImpl(
        id: 'package:my_package/foo2',
        linkMode: DynamicLoadingSystemImpl(Uri(path: 'path/to/libfoo2.so')),
        os: OSImpl.android,
        architecture: ArchitectureImpl.x64,
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

HookOutputImpl getBuildOutput({bool withLinkedAssets = true}) => HookOutputImpl(
      timestamp: DateTime.parse('2022-11-10 13:25:01.000'),
      assets: [
        NativeCodeAssetImpl(
          id: 'package:my_package/foo',
          file: Uri(path: 'path/to/libfoo.so'),
          linkMode: DynamicLoadingBundledImpl(),
          os: OSImpl.android,
          architecture: ArchitectureImpl.x64,
        ),
        NativeCodeAssetImpl(
          id: 'package:my_package/foo2',
          linkMode: DynamicLoadingSystemImpl(Uri(path: 'path/to/libfoo2.so')),
          os: OSImpl.android,
          architecture: ArchitectureImpl.x64,
        ),
        NativeCodeAssetImpl(
          id: 'package:my_package/foo3',
          linkMode: LookupInProcessImpl(),
          os: OSImpl.android,
          architecture: ArchitectureImpl.x64,
        ),
        NativeCodeAssetImpl(
          id: 'package:my_package/foo4',
          linkMode: LookupInExecutableImpl(),
          os: OSImpl.android,
          architecture: ArchitectureImpl.x64,
        ),
      ],
      assetsForLinking: withLinkedAssets
          ? {
              'my_package': [
                DataAssetImpl(
                  file: Uri.file('path/to/data'),
                  name: 'data',
                  package: 'my_package',
                )
              ],
              'my_package_2': [
                DataAssetImpl(
                  file: Uri.file('path/to/data2'),
                  name: 'data',
                  package: 'my_package',
                )
              ]
            }
          : null,
      dependencies: Dependencies([
        Uri.file('path/to/file.ext'),
      ]),
      metadata: const Metadata({
        'key': 'value',
      }),
    );
