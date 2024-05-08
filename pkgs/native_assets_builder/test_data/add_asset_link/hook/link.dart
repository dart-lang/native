// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> arguments) async {
  await link(arguments, (config, output) async {
    final built_dylib = config.assets.first as NativeCodeAsset;
    output
      ..addAsset(
        NativeCodeAsset(
          package: 'add_asset_link',
          name: 'dylib_add_link',
          linkMode: built_dylib.linkMode,
          os: built_dylib.os,
          architecture: built_dylib.architecture,
          file: built_dylib.file,
        ),
      )
      ..addDependency(config.packageRoot.resolve('hook/link.dart'));
  });
}
