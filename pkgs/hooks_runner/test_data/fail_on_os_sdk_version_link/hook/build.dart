// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    output.assets.data.add(
      DataAsset(
        name: 'data',
        file: input.packageRoot.resolve('assets/data.json'),
        package: input.packageName,
      ),
      routing:
          input.config.linkingEnabled
              ? const ToLinkHook('fail_on_os_sdk_version_linker')
              : const ToAppBundle(),
    );
  });
}
