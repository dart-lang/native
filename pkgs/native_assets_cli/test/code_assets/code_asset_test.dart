// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/code_assets_builder.dart';
import 'package:test/test.dart';

void main() async {
  test('DataAsset', () {
    expect(
      CodeAsset(
        package: 'my_package',
        name: 'name',
        linkMode: DynamicLoadingBundled(),
        os: OS.android,
        file: Uri.file('not there'),
        architecture: Architecture.riscv64,
      ).encode().toJson(),
      {
        'architecture': 'riscv64',
        'file': 'not there',
        'id': 'package:my_package/name',
        'link_mode': {'type': 'dynamic_loading_bundle'},
        'os': 'android',
        'type': 'native_code',
      },
    );
  });
}
