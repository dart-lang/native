// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
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
    final outDirShared = tempUri.resolve('out_dir_shared/');
    final packageRoot = tempUri.resolve('package_root/');
    await Directory.fromUri(outDir).create();
    await Directory.fromUri(outDirShared).create();
    await Directory.fromUri(packageRoot).create();
    final config = BuildConfigImpl(
      outputDirectory: outDir,
      outputDirectoryShared: outDirShared,
      packageName: 'dontcare',
      packageRoot: packageRoot,
      buildMode: BuildMode.debug,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.macOS,
      linkModePreference: LinkModePreference.dynamic,
      linkingEnabled: false,
      supportedAssetTypes: [CodeAsset.type],
    );
    final buildOutput = getBuildOutput();
    await buildOutput.writeToFile(config: config);
    final buildOutput2 = HookOutputImpl.readFromFile(file: config.outputFile);
    expect(buildOutput2, buildOutput);
  });

  test('BuildOutput.readFromFile BuildOutput.writeToFile V1.1.0', () async {
    final outDir = tempUri.resolve('out_dir/');
    final outDirShared = tempUri.resolve('out_dir_shared/');
    final packageRoot = tempUri.resolve('package_root/');
    await Directory.fromUri(outDir).create();
    await Directory.fromUri(outDirShared).create();
    await Directory.fromUri(packageRoot).create();
    final config = BuildConfigImpl(
      outputDirectory: outDir,
      outputDirectoryShared: outDirShared,
      packageName: 'dontcare',
      packageRoot: packageRoot,
      buildMode: BuildMode.debug,
      targetArchitecture: Architecture.arm64,
      targetOS: OS.macOS,
      linkModePreference: LinkModePreference.dynamic,
      version: Version(1, 1, 0),
      linkingEnabled: null, // version < 1.4.0
      supportedAssetTypes: [CodeAsset.type],
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
        () => HookOutputImpl.fromJsonString('{"version": "$version"}'),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(version) &&
              e.message.contains(HookOutputImpl.latestVersion.toString()),
        )),
      );
    });
  }

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
      encodedAssets: [
        CodeAsset(
          package: 'my_package',
          name: 'foo',
          file: Uri(path: 'path/to/libfoo.so'),
          linkMode: DynamicLoadingBundled(),
          os: OS.android,
          architecture: Architecture.x64,
        ).encode(),
        CodeAsset(
          package: 'my_package',
          name: 'foo2',
          linkMode: DynamicLoadingSystem(Uri(path: 'path/to/libfoo2.so')),
          os: OS.android,
          architecture: Architecture.x64,
        ).encode(),
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
    buildOutput2.addEncodedAsset(
      CodeAsset(
        package: 'my_package',
        name: 'foo',
        file: Uri(path: 'path/to/libfoo.so'),
        linkMode: DynamicLoadingBundled(),
        os: OS.android,
        architecture: Architecture.x64,
      ).encode(),
    );
    buildOutput2.addEncodedAssets([
      CodeAsset(
        package: 'my_package',
        name: 'foo2',
        linkMode: DynamicLoadingSystem(Uri(path: 'path/to/libfoo2.so')),
        os: OS.android,
        architecture: Architecture.x64,
      ).encode(),
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
      encodedAssets: [
        CodeAsset(
          package: 'my_package',
          name: 'foo',
          file: Uri(path: 'path/to/libfoo.so'),
          linkMode: DynamicLoadingBundled(),
          os: OS.android,
          architecture: Architecture.x64,
        ).encode(),
        CodeAsset(
          package: 'my_package',
          name: 'foo2',
          linkMode: DynamicLoadingSystem(Uri(path: 'path/to/libfoo2.so')),
          os: OS.android,
          architecture: Architecture.x64,
        ).encode(),
        CodeAsset(
          package: 'my_package',
          name: 'foo3',
          linkMode: LookupInProcess(),
          os: OS.android,
          architecture: Architecture.x64,
        ).encode(),
        CodeAsset(
          package: 'my_package',
          name: 'foo4',
          linkMode: LookupInExecutable(),
          os: OS.android,
          architecture: Architecture.x64,
        ).encode(),
      ],
      encodedAssetsForLinking: withLinkedAssets
          ? {
              'my_package': [
                DataAsset(
                  file: Uri.file('path/to/data'),
                  name: 'data',
                  package: 'my_package',
                ).encode()
              ],
              'my_package_2': [
                DataAsset(
                  file: Uri.file('path/to/data2'),
                  name: 'data',
                  package: 'my_package',
                ).encode()
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
