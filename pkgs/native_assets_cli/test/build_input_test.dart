// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_builder.dart';
import 'package:native_assets_cli/src/config.dart' show latestVersion;
import 'package:test/test.dart';

import 'helpers.dart';

void main() async {
  late Uri outFile;
  late Uri outDirUri;
  late Uri outputDirectoryShared;
  late String packageName;
  late Uri packageRootUri;
  late Map<String, Metadata> metadata;
  late Map<String, Object?> inputJson;

  setUp(() async {
    final tempUri = Directory.systemTemp.uri;
    outFile = tempUri.resolve('output.json');
    outDirUri = tempUri.resolve('out1/');
    outputDirectoryShared = tempUri.resolve('out_shared1/');
    packageName = 'my_package';
    packageRootUri = tempUri.resolve('$packageName/');
    metadata = {
      'bar': Metadata({
        'key': 'value',
        'foo': ['asdf', 'fdsa'],
      }),
      'foo': Metadata({'key': 321}),
    };

    inputJson = {
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
          ..config.addBuildAssetTypes(['my-asset-type'])
          ..config.setupBuild(linkingEnabled: false)
          ..setupBuildInput(metadata: metadata);
    final input = BuildInput(inputBuilder.json);

    expect(input.json, inputJson);
    expect(json.decode(input.toString()), inputJson);

    // The output_directory is deprecated, the hook makes a directory inside the
    // shared output directory.
    expect(input.outputDirectory, isNot(outDirUri));

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
        final input = inputJson;
        input['version'] = version;
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

    test('BuildInput FormatException dependency_metadata', () {
      final input = inputJson;
      input['dependency_metadata'] = {
        'bar': {'key': 'value'},
        'foo': <int>[],
      };
      expect(
        () => BuildInput(input),
        throwsA(
          predicate(
            (e) =>
                e is FormatException &&
                e.message.contains('Unexpected value') &&
                e.message.contains('dependency_metadata.foo') &&
                e.message.contains('Expected a Map<String, Object?>'),
          ),
        ),
      );
    });

    test('BuildInput FormatException config.build_asset_types', () {
      final input = inputJson;
      traverseJson<Map<String, Object?>>(input, [
        'config',
      ]).remove('build_asset_types');
      expect(
        () => BuildInput(input).config.buildAssetTypes,
        throwsA(
          predicate(
            (e) =>
                e is FormatException &&
                e.message.contains(
                  'No value was provided for '
                  "'config.build_asset_types'.",
                ),
          ),
        ),
      );
    });
  });
}
