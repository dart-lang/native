// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_assets_cli/test.dart';
import 'package:test/test.dart';

import '../hook/build.dart' as build;

void main() {
  testBuildHook(
    description: 'test my build hook',
    mainMethod: build.main,
    check: (_, output) {
      expect(output.codeAssets.all, isNotEmpty);
      expect(
        output.codeAssets.all.first.id,
        'package:local_asset/asset.txt',
      );
    },
    supportedAssetTypes: [CodeAsset.type],
  );
}
