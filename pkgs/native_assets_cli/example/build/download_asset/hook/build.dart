// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:download_asset/src/hook_helpers/c_build.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  const localBuild = false;

  await build(args, (config, output) async {
    // ignore: dead_code
    if (localBuild) {
      await runBuild(config, output);
    } else {
      // TODO(dcharkes): Download from GitHub.
    }
  });
}
