// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    final builtDylib = input.assets.code.first;
    output
      ..assets.code.add(
        CodeAsset(
          package: 'add_asset_link',
          name: 'dylib_add_link',
          linkMode: builtDylib.linkMode,
          file: builtDylib.file,
        ),
      )
      ..dependencies.add(input.packageRoot.resolve('hook/link.dart'));
  });
}
