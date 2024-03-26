// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:path/path.dart' as p;

const packageName = 'native_add_library';
void main(List<String> args) async {
  await link(args, (config, output) async {
    output.addAssets([
      ...AssetTreeshaker.shake(
        config.assets,
        config.resources,
      ),
      DataAsset(
        name: 'data_asset_link',
        package: packageName,
        file: Uri.file(p.absolute('data_asset_link.json')),
      )
    ]);
  });
}

/// Filters out json files from the assets.
class AssetTreeshaker {
  static List<Asset> shake(
    List<Asset> assets,
    List<Resource>? resourceIdentifiers,
  ) =>
      assets.where((asset) => !asset.id.endsWith('.json')).toList();
}