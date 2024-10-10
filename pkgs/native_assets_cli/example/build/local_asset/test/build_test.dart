// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/test.dart';
import 'package:test/test.dart';

import '../hook/build.dart' as build;

void main() {
  testBuildHook(
    description: 'test my build hook',
    mainMethod: build.main,
    extraConfigSetup: (config) {
      config.setupCodeConfig(
        linkModePreference: LinkModePreference.dynamic,
        targetArchitecture: Architecture.current,
      );
    },
    check: (_, output) {
      expect(output.codeAssets, isNotEmpty);
      expect(
        output.codeAssets.first.id,
        'package:local_asset/asset.txt',
      );
    },
    supportedAssetTypes: [CodeAsset.type],
  );
}
