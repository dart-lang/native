// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';
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
        'type': 'data_assets/data',
        'encoding': {
          'file': 'not there',
          'name': 'name',
          'package': 'my_package',
        },
      },
    );
  });

  test('DataAsset fromJson', () {
    final encodedAsset = EncodedAsset.fromJson({
      'type': 'data_assets/data',
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
