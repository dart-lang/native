// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(https://github.com/dart-lang/native/issues/882): A new version of
// `package:native_assets_cli` needs to be published first.
// ignore_for_file: deprecated_member_use

import 'package:cli_config/cli_config.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  final config = await Config.fromArgs(args: args);
  final buildConfig = BuildConfig.fromConfig(config);
  if (!buildConfig.dryRun) {
    final metadata =
        buildConfig.dependencyMetadata!['package_with_metadata']!.metadata;
    final someValue = metadata['some_key'];
    assert(someValue != null);
    final someInt = metadata['some_int'];
    assert(someInt != null);
    print(metadata);
  } else {
    print('meta data not available in dry run');
  }
}
