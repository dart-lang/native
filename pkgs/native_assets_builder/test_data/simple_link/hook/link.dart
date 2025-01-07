// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/data_assets.dart';

void main(List<String> args) async {
  await link(args, (input, output) async {
    shake(output, input.dataAssets);
  });
}

void shake(LinkOutputBuilder output, Iterable<DataAsset> assets) {
  for (final asset in assets.skip(2)) {
    output.assets.data.add(asset);

    // If the file changes we'd like to re-run the linker.
    output.addDependency(asset.file);
  }
}
