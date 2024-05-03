// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

const packageName = 'treeshaking_native_assets';

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    final cbuilder = CBuilder.library(
      name: packageName,
      assetName: 'staticlib',
      sources: [
        'src/native_add.c',
        'src/native_multiply.c',
      ],
      dartBuildFiles: ['hook/build.dart'],
      linkModePreference: LinkModePreference.static,
    );
    await cbuilder.run(
      buildConfig: config,
      buildOutput: output,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) {
          print('${record.level.name}: ${record.time}: ${record.message}');
        }),
      linkInPackage: packageName,
    );
    _placeholderAsset(config, output);
  });
}

// TODO: Currently, linking cannot add assets, so we add a placeholder here.
// See also https://github.com/dart-lang/native/issues/1084.
void _placeholderAsset(BuildConfig config, BuildOutput output) {
  final uri = config.outputDirectory.resolve(
      config.targetOS.libraryFileName(packageName, DynamicLoadingBundled()));
  File.fromUri(uri).createSync(recursive: true);
  output.addAsset(
    NativeCodeAsset(
      package: packageName,
      name: 'src/${packageName}_bindings.dart',
      linkMode: DynamicLoadingBundled(),
      file: uri,
      os: config.targetOS,
    ),
    linkInPackage: packageName,
  );
}
