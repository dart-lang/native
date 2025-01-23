// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/data_assets.dart';

void main(List<String> args) async {
  await build(
    args,
    (input, output) async {
      if (input.config.buildAssetTypes.contains(DataAsset.type)) {
        output.assets.data.add(
          DataAsset(
            package: input.packageName,
            name: 'assets/test_asset.txt',
            file: File('assets/test_asset.txt').uri,
          ),
        );
      }
    },
  );
}
