// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/data_assets_builder.dart';
import 'package:test/test.dart';

void main() async {
  test('DataAsset toJson', () {
    expect(
      DataAsset(
        package: 'my_package',
        name: 'name',
        file: Uri.file('not there'),
      ).encode().toJson(),
      {
        'file': 'not there',
        'package': 'my_package',
        'name': 'name',
        'type': 'data',
        'encoding': {
          'file': 'not there',
          'name': 'name',
          'package': 'my_package',
        },
      },
    );
  });

  for (final assetType in ['data', 'data_assets/data']) {
    for (final nestInEncoding in [true, false]) {
      test('DataAsset fromJson', () {
        final encodedAsset = EncodedAsset.fromJson({
          'type': assetType,
          if (!nestInEncoding) ...{
            'file': 'not there',
            'name': 'name',
            'package': 'my_package',
          },
          if (nestInEncoding)
            'encoding': {
              'file': 'not there',
              'name': 'name',
              'package': 'my_package',
            },
        });
        expect(encodedAsset.isDataAsset, isTrue);
        expect(
          DataAsset.fromEncoded(encodedAsset),
          DataAsset(
            package: 'my_package',
            name: 'name',
            file: Uri.file('not there'),
          ),
        );
      });
    }
  }
}
