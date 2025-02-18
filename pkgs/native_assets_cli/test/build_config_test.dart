// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_builder.dart';
import 'package:native_assets_cli/src/config.dart' show latestVersion;
import 'package:test/test.dart';

void main() async {
  late Uri outFile;
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late Map<String, Metadata> metadata;

  setUp(() async {
    final tempUri = Directory.systemTemp.uri;
    outFile = tempUri.resolve('output.json');
    outDirUri = tempUri.resolve('out1/');
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    metadata = {
      'bar': const Metadata({
        'key': 'value',
        'foo': ['asdf', 'fdsa'],
      }),
      'foo': const Metadata({'key': 321}),
    };
  });

  test('BuildInputBuilder->JSON->BuildInput', () {
    final inputBuilder =
        BuildInputBuilder()
          ..setupShared(
            packageName: packageName,
            packageRoot: packageRootUri,
            outputFile: outFile,
            outputDirectory: outDirUri,
            outputDirectoryShared: outputDirectoryShared,
          )
          ..config.setupShared(buildAssetTypes: ['my-asset-type'])
          ..config.setupBuild(linkingEnabled: false)
          ..setupBuildInput(metadata: metadata);
    final input = BuildInput(inputBuilder.json);

    final expectedInputJson = {
      'config': {
        'build_asset_types': ['my-asset-type'],
        'linking_enabled': false,
      },
      'dependency_metadata': {
        'bar': {
          'key': 'value',
          'foo': ['asdf', 'fdsa'],
        },
        'foo': {'key': 321},
      },
      'out_dir_shared': outputDirectoryShared.toFilePath(),
      'out_dir': outDirUri.toFilePath(),
      'out_file': outFile.toFilePath(),
      'package_name': packageName,
      'package_root': packageRootUri.toFilePath(),
      'version': latestVersion.toString(),
    };

    expect(input.json, expectedInputJson);
    expect(json.decode(input.toString()), expectedInputJson);

    expect(input.outputDirectory, outDirUri);
    expect(input.outputDirectoryShared, outputDirectoryShared);

    expect(input.packageName, packageName);
    expect(input.packageRoot, packageRootUri);
    expect(input.config.buildAssetTypes, ['my-asset-type']);

    expect(input.config.linkingEnabled, false);
    expect(input.metadata, metadata);
  });

  group('BuildInput format issues', () {
    for (final version in ['9001.0.0', '0.0.1']) {
      test('BuildInput version $version', () {
        final outDir = outDirUri;
        final input = {
          'config': {
            'build_asset_types': ['my-asset-type'],
            'linking_enabled': false,
          },
          'link_mode_preference': 'prefer-static',
          'out_dir': outDir.toFilePath(),
          'out_dir_shared': outputDirectoryShared.toFilePath(),
          'out_file': outFile.toFilePath(),
          'package_root': packageRootUri.toFilePath(),
          'target_os': 'linux',
          'version': version,
          'package_name': packageName,
        };
        expect(
          () => BuildInput(input),
          throwsA(
            predicate(
              (e) =>
                  e is FormatException &&
                  e.message.contains(version) &&
                  e.message.contains(latestVersion.toString()),
            ),
          ),
        );
      });
    }

    test('BuildInput FormatExceptions', () {
      expect(
        () => BuildInput({}),
        throwsA(
          predicate(
            (e) =>
                e is FormatException &&
                e.message.contains('No value was provided for required key: '),
          ),
        ),
      );
      expect(
        () => BuildInput({
          'version': latestVersion.toString(),
          'package_name': packageName,
          'package_root': packageRootUri.toFilePath(),
          'target_os': 'android',
        }),
        throwsA(
          predicate(
            (e) =>
                e is FormatException &&
                e.message.contains(
                  'No value was provided for required key: out_dir',
                ),
          ),
        ),
      );
      expect(
        () => BuildInput({
          'config': {
            'build_asset_types': ['my-asset-type'],
            'linking_enabled': false,
          },
          'version': latestVersion.toString(),
          'out_dir': outDirUri.toFilePath(),
          'out_dir_shared': outputDirectoryShared.toFilePath(),
          'out_file': outFile.toFilePath(),
          'package_name': packageName,
          'package_root': packageRootUri.toFilePath(),
          'target_os': 'android',
          'dependency_metadata': {
            'bar': {'key': 'value'},
            'foo': <int>[],
          },
        }),
        throwsA(
          predicate(
            (e) =>
                e is FormatException &&
                e.message.contains("Unexpected value '[]' ") &&
                e.message.contains('Expected a Map<String, Object?>'),
          ),
        ),
      );
    });
  });
}
