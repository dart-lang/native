// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli_internal.dart';

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    final assetUri = config.outputDirectory.resolve(
      OS.current.dylibFileName('foo'),
    );
    if (!config.dryRun) {
      await File.fromUri(assetUri).writeAsBytes([1, 2, 3]);
    }

    output.addAsset(
      CodeAsset(
        package: config.packageName,
        name: 'foo',
        file: assetUri,
        linkMode: DynamicLoadingBundled(),
        os: OS.current,
        architecture: Architecture.current,
      ),
      linkInPackage: 'a_package_that_does_not_exist',
    );
  });
}

// Copy from `build`, but without the validation.
Future<void> build(
  List<String> arguments,
  Future<void> Function(BuildConfig config, BuildOutput output) builder,
) async {
  final config = BuildConfigImpl.fromArguments(arguments);
  final output = HookOutputImpl();
  await builder(config, output);
  await output.writeToFile(config: config);
}
