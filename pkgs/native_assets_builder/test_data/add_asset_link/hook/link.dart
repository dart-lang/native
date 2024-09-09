// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> arguments) async {
  await link(arguments, (config, output) async {
    final builtDylib = config.assets.first as NativeCodeAsset;
    output
      ..addAsset(
        NativeCodeAsset(
          id: 'package:add_asset_link/dylib_add_link',
          linkMode: builtDylib.linkMode,
          os: builtDylib.os,
          architecture: builtDylib.architecture,
          file: builtDylib.file,
        ),
      )
      ..addDependency(config.packageRoot.resolve('hook/link.dart'));
  });
}
