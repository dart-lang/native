// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:convert';

import 'package:native_assets_cli/native_assets_cli_internal.dart';
import 'package:native_assets_cli/src/utils/datetime.dart';
import 'package:test/test.dart';

void main() {
  test('BuildOutputBuilder->JSON->BuildOutput', () {
    final assets = [
      for (int i = 0; i < 6; i++)
        DataAsset(file: Uri(path: 'asset$i'), name: 'assetId$i', package: 'pkg')
            .encode(),
    ];
    final uris = [
      for (int i = 0; i < 3; ++i) Uri.file('path$i'),
    ];
    final metadata0 = {
      'meta-a': 'meta-b',
    };
    final metadata1 = {
      for (int i = 0; i < 2; ++i) 'meta$i': 'meta$i-value',
    };
    final before = DateTime.now().roundDownToSeconds();
    final builder = BuildOutputBuilder();
    final after = DateTime.now().roundDownToSeconds();

    builder.addDependency(uris.take(1).single);
    builder.addDependencies(uris.skip(1).toList());
    builder.addMetadatum(metadata0.keys.single, metadata0.values.single);
    builder.addMetadata(metadata1);

    builder.addEncodedAsset(assets.take(1).single);
    builder.addEncodedAsset(assets.skip(1).first,
        linkInPackage: 'package:linker1');
    builder.addEncodedAssets(assets.skip(2).take(2).toList());
    builder.addEncodedAssets(assets.skip(4).toList(),
        linkInPackage: 'package:linker2');

    final config = BuildOutput(builder.json);
    expect(config.timestamp, greaterThanOrEqualTo(before));
    expect(config.timestamp, lessThanOrEqualTo(after));
    expect(config.timestamp,
        lessThanOrEqualTo(config.timestamp.roundDownToSeconds()));

    print(const JsonEncoder.withIndent(' ').convert(config.json));

    final expectedJson = {
      'version': '1.5.0',
      'timestamp': config.timestamp.toString(),
      'dependencies': [
        ...uris.map((uri) => uri.toFilePath()),
      ],
      'metadata': {
        ...metadata0,
        ...metadata1,
      },
      'assets': [
        assets.take(1).single.toJson(),
        ...assets.skip(2).take(2).map((e) => e.toJson()),
      ],
      'assetsForLinking': {
        'package:linker1': [
          assets.skip(1).first.toJson(),
        ],
        'package:linker2': [
          ...assets.skip(4).map((e) => e.toJson()),
        ]
      }
    };
    expect(config.json, equals(expectedJson));
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('BuildOutput version $version', () {
      expect(
        () => BuildOutput({'version': version}),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(version) &&
              e.message.contains(HookOutput.latestVersion.toString()),
        )),
      );
    });
  }
}
