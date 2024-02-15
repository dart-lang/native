// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cli_config/cli_config.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  final config = await Config.fromArgs(args: args);
  final buildConfig = BuildConfig.fromConfig(config);
  if (!buildConfig.dryRun) {
    final someValue =
        buildConfig.metadatum('package_with_metadata', 'some_key');
    assert(someValue != null);
    final someInt = buildConfig.metadatum('package_with_metadata', 'some_int');
    assert(someInt != null);
    print({
      'some_int': someInt,
      'some_key': someValue,
    });
  } else {
    print('meta data not available in dry run');
  }
}
