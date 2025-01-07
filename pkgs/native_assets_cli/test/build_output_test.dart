// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: deprecated_member_use_from_same_package

import 'package:native_assets_cli/native_assets_cli_builder.dart';
import 'package:native_assets_cli/src/config.dart';
import 'package:native_assets_cli/src/utils/datetime.dart';
import 'package:test/test.dart';

void main() {
  test('BuildOutputBuilder->JSON->BuildOutput', () {
    final assets = [
      for (int i = 0; i < 3; i++)
        EncodedAsset('my-asset-type', {'a-$i': 'v-$i'})
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

    final input = BuildOutput(builder.json);
    expect(input.timestamp.compareTo(before), greaterThanOrEqualTo(0));
    expect(input.timestamp.compareTo(after), lessThanOrEqualTo(0));
    expect(
        input.timestamp
            .isAtSameMomentAs(input.timestamp.roundDownToSeconds()),
        true);

    // The JSON format of the build output.
    <String, Object?>{
      'version': '1.6.0',
      'dependencies': ['path0', 'path1', 'path2'],
      'metadata': {
        'meta-a': 'meta-b',
        'meta0': 'meta0-value',
        'meta1': 'meta1-value'
      },
      'assets': [
        {'a-0': 'v-0', 'type': 'my-asset-type'},
        {'a-2': 'v-2', 'type': 'my-asset-type'}
      ],
      'assetsForLinking': {
        'package:linker1': [
          {'a-1': 'v-1', 'type': 'my-asset-type'}
        ],
        'package:linker2': <Object?>[],
      }
    }.forEach((k, v) {
      expect(input.json[k], equals(v));
    });
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('BuildOutput version $version', () {
      expect(
        () => BuildOutput({'version': version}),
        throwsA(predicate(
          (e) =>
              e is FormatException &&
              e.message.contains(version) &&
              e.message.contains(latestVersion.toString()),
        )),
      );
    });
  }
}
