// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
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
        'type': 'code_assets/code',
        'encoding': {
          'file': 'not there',
          'id': 'package:my_package/name',
          'link_mode': {'type': 'dynamic_loading_bundle'},
        },
      },
    );
  });

  test('CodeAsset fromJson', () {
    final encodedAsset = EncodedAsset.fromJson({
      'type': 'code_assets/code',
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
