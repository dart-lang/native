// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    output.addAsset(
      DataAsset(
        name: 'data',
        file: config.packageRoot.resolve('assets/data.json'),
        package: config.packageName,
      ),
      linkInPackage: 'fail_on_os_sdk_version_linker',
    );
  });
}
