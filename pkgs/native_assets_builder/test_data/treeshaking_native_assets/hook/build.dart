// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
      dartBuildFiles: [
        'hook/build.dart',
        'hook/link.dart',
      ],
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
    output.addAsset(
      placeholderAsset(config),
      linkInPackage: packageName,
    );
  });
}

// TODO: Currently, linking cannot add assets, so we add a placeholder here.
// See also https://github.com/dart-lang/native/issues/1084.
NativeCodeAsset placeholderAsset(HookConfig config) {
  final String libraryFileName = config.targetOS.libraryFileName(
    packageName,
    DynamicLoadingBundled(),
  );
  final uri = config.outputDirectory.resolve(libraryFileName);

  return NativeCodeAsset(
    package: packageName,
    name: 'src/${packageName}_bindings.dart',
    linkMode: DynamicLoadingBundled(),
    file: uri,
    os: config.targetOS,
  );
}
