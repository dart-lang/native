// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  await link(
    args,
    (config, output) async => output.addAssets(treeshake(config.assets)),
  );
}

Iterable<Asset> treeshake(List<Asset> assets) =>
    assets.where((asset) => !asset.id.endsWith('data_helper_2'));
