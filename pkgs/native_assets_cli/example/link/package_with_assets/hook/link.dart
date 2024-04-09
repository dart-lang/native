// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  await link(args, (config, output) async {
    final remainingAssets = shake(config.assets, config.resources);
    output.linkAssets(remainingAssets);
  });
}

Iterable<LinkableAsset> shake(
        List<LinkableAsset> allAssets, List<Resource> resources) =>
    allAssets.whereType<LinkableDataAsset>().where(
          (asset) => resources.any(
            (resource) => resource.metadata == asset.name,
          ),
        );
