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

  shakenAssets.add(
    Asset(
      id: 'package:$packageName/a_json_file',
      linkMode: LinkMode.dynamic,
      target: Target.androidArm,
      path: AssetAbsolutePath(
        linkInput.buildConfig.packageRoot.resolve('data_asset_link.json'),
      ),
    ),
  );

  final linkOutput = BuildOutput(assets: shakenAssets);
  await linkOutput.writeToFile(outFile: linkInput.outDir);
}

class MyResourceShaker {
  List<Asset> shake(
    List<Asset> assets,
    ResourceIdentifiers? resourceIdentifiers,
  ) =>
      assets.where((asset) => !asset.id.endsWith('.json')).toList();
}
