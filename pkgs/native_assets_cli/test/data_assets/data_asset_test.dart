// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/data_assets_builder.dart';
import 'package:test/test.dart';

void main() async {
  test('DataAsset', () {
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
      },
    );
  });
}
