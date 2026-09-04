// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:hooks/hooks.dart';
import 'package:test/test.dart';
import 'package:web_assets/web_assets.dart';

void main() async {
  test('WebAsset toJson', () {
    expect(
      WebAsset(
        package: 'my_package',
        name: 'name',
        file: Uri.file('not there'),
      ).encode().toJson(),
      {
        'type': 'web_assets/web',
        'encoding': {
          'file': 'not there',
          'name': 'name',
          'package': 'my_package',
        },
      },
    );
  });

  test('WebAsset fromJson', () {
    final encodedAsset = EncodedAsset.fromJson({
      'type': 'web_assets/web',
      'encoding': {
        'file': 'not there',
        'name': 'name',
        'package': 'my_package',
      },
    });
    expect(encodedAsset.isWebAsset, isTrue);
    expect(
      WebAsset.fromEncoded(encodedAsset),
      WebAsset(
        package: 'my_package',
        name: 'name',
        file: Uri.file('not there'),
      ),
    );
  });
}
