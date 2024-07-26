// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli_test.dart';
import 'package:test/test.dart';

import '../hook/build.dart' as build;

void main() {
  testBuild(
    description: 'test my build hook',
    mainMethod: build.main,
    check: (output) {
      expect(output.assets, isNotEmpty);
      expect(output.assets.first, isA<NativeCodeAsset>());
      expect(
        (output.assets.first as NativeCodeAsset).id,
        'package:local_asset/asset.txt',
      );
    },
  );
}
