// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:test/test.dart';

void main() async {
  test('CodeAsset toJson', () {
    expect(
      CodeAsset(
        package: 'my_package',
        name: 'name',
        linkMode: DynamicLoadingBundled(),
        file: Uri.file('not there'),
      ).encode().toJson(),
      {
        'file': 'not there',
        'id': 'package:my_package/name',
        'link_mode': {'type': 'dynamic_loading_bundle'},
        'type': 'code_assets/code',
        'encoding': {
          'file': 'not there',
          'id': 'package:my_package/name',
          'link_mode': {'type': 'dynamic_loading_bundle'},
        },
      },
    );
  });

  for (final assetType in ['native_code', 'code_assets/code']) {
    for (final nestInEncoding in [true, false]) {
      test('CodeAsset fromJson', () {
        final encodedAsset = EncodedAsset.fromJson({
          'type': assetType,
          if (!nestInEncoding) ...{
            'file': 'not there',
            'id': 'package:my_package/name',
            'link_mode': {'type': 'dynamic_loading_bundle'},
          },
          if (nestInEncoding)
            'encoding': {
              'file': 'not there',
              'id': 'package:my_package/name',
              'link_mode': {'type': 'dynamic_loading_bundle'},
            },
        });
        expect(encodedAsset.isCodeAsset, isTrue);
        expect(
          CodeAsset.fromEncoded(encodedAsset),
          CodeAsset(
            package: 'my_package',
            name: 'name',
            linkMode: DynamicLoadingBundled(),
            file: Uri.file('not there'),
          ),
        );
      });
    }
  }
}
