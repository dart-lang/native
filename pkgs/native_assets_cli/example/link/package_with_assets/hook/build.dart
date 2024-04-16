// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  await build(args, (config, output) async {
    final packageName = config.packageName;
    final allAssets = [
      DataAsset(
        package: packageName,
        name: 'unused_asset',
        file: config.packageRoot.resolve('assets/unused_asset.json'),
      ),
      DataAsset(
        package: packageName,
        name: 'used_asset',
        file: config.packageRoot.resolve('assets/used_asset.json'),
      )
    ];
    output.addAssets(allAssets, linkInPackage: packageName);
  });
}
