// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:hooks/src/utils/datetime.dart';
import 'package:test/test.dart';

void main() {
  test('BuildOutputBuilder->JSON->BuildOutput', () {
    final assets = [
      for (int i = 0; i < 3; i++)
        EncodedAsset('my-asset-type', {'a-$i': 'v-$i'}),
    ];
    final uris = [for (int i = 0; i < 3; ++i) Uri.file('path$i')];
    final before = DateTime.now().roundDownToSeconds();
    final builder = BuildOutputBuilder();
    final after = DateTime.now().roundDownToSeconds();

    builder.addDependency(uris.first);
    builder.addDependencies(uris.skip(1).toList());

    builder.assets.addEncodedAsset(assets.first);
    builder.assets.addEncodedAsset(
      assets.skip(2).first,
      routing: const ToBuildHooks(),
    );
    builder.assets.addEncodedAsset(
      assets.skip(1).first,
      routing: const ToLinkHook('package:linker1'),
    );
    builder.assets.addEncodedAssets(assets.skip(2).take(2).toList());
    builder.assets.addEncodedAssets(
      assets.take(2),
      routing: const ToBuildHooks(),
    );
    builder.assets.addEncodedAssets(
      assets.skip(4).toList(),
      routing: const ToLinkHook('package:linker2'),
    );

    final input = BuildOutput(builder.json);
    expect(input.timestamp.compareTo(before), greaterThanOrEqualTo(0));
    expect(input.timestamp.compareTo(after), lessThanOrEqualTo(0));
    expect(
      input.timestamp.isAtSameMomentAs(input.timestamp.roundDownToSeconds()),
      true,
    );

    // The JSON format of the build output.
    final expectedJson = <String, Object?>{
      'dependencies': ['path0', 'path1', 'path2'],
      'assets': [
        {
          'encoding': {'a-0': 'v-0'},
          'type': 'my-asset-type',
        },
        {
          'encoding': {'a-2': 'v-2'},
          'type': 'my-asset-type',
        },
      ],
      'assets_for_build': [
        {
          'encoding': {'a-2': 'v-2'},
          'type': 'my-asset-type',
        },
        {
          'encoding': {'a-0': 'v-0'},
          'type': 'my-asset-type',
        },
        {
          'encoding': {'a-1': 'v-1'},
          'type': 'my-asset-type',
        },
      ],
      'assets_for_linking': {
        'package:linker1': [
          {
            'encoding': {'a-1': 'v-1'},
            'type': 'my-asset-type',
          },
        ],
        'package:linker2': <Object?>[],
      },
      'timestamp': input.timestamp.toString(),
    };

    expect(input.json, equals(expectedJson));
  });

  for (final version in ['9001.0.0', '0.0.1']) {
    test('BuildOutput version $version', () {
      expect(() => BuildOutput({'version': version}), isNot(throwsException));
    });
  }
}
