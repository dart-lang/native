// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> arguments) async {
  await link(arguments, (config, output) async {
    output
      ..addAsset(
        DataAsset(
          package: 'add_dylib_link',
          name: 'test_text_file',
          file: config.packageRoot.resolve('assets/test.txt'),
        ),
      )
      ..addDependency(config.packageRoot.resolve('hook/link.dart'));
  });
}
