// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

const packageName = 'native_add_library';
void main(List<String> args) async {
  final linkInput = await LinkConfig.fromArgs(args);

  final shakenAssets = MyResourceShaker().shake(
    linkInput.assets,
    linkInput.resourceIdentifiers,
  );

  // Add a new json file to the assets
  const assetName = 'data_asset_link.json';
  shakenAssets.add(
    Asset(
      id: 'package:$packageName/$assetName',
      linkMode: LinkMode.dynamic,
      target: Target.androidArm,
      path: AssetAbsolutePath(
        linkInput.buildConfig.packageRoot.resolve(assetName),
      ),
    ),
  );

  await BuildOutput(assets: shakenAssets).writeToFile(output: linkInput.output);
}

/// Filters out json files from the assets.
class MyResourceShaker {
  List<Asset> shake(
    List<Asset> assets,
    ResourceIdentifiers? resourceIdentifiers,
  ) =>
      assets.where((asset) => !asset.id.endsWith('.json')).toList();
}
