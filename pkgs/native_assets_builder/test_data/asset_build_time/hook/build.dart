// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> arguments) async {
  await build(arguments, (config, output) async {
    final buildTimeFileUri = config.packageRoot.resolve('build_time');
    final buildTime =
        DateTime.parse(File.fromUri(buildTimeFileUri).readAsStringSync());
    output.addDependency(buildTimeFileUri);

    final name = config.packageName;

    final cbuilder = CBuilder.library(
      name: config.packageName,
      assetName: 'src/${name}_bindings_generated.dart',
      sources: [
        'src/$name.c',
      ],
      defines: {
        'BUILD_TIME': '"${buildTime.toIso8601String()}"',
      },
    );
    await cbuilder.run(
      config: config,
      output: output,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) {
          print('${record.level.name}: ${record.time}: ${record.message}');
        }),
    );

    if (config.supportedAssetTypes.contains(DataAsset.type)) {
      final buildTimeDataAssetUri =
          config.outputDirectory.resolve('build_time');
      output.addAsset(
        DataAsset(
          package: config.packageName,
          name: 'build_time',
          file: buildTimeDataAssetUri,
        ),
      );

      if (!config.dryRun) {
        File.fromUri(buildTimeDataAssetUri)
            .writeAsStringSync(buildTime.toIso8601String());
      }
    }

    if (!config.dryRun) {
      for (final asset in output.assets) {
        File.fromUri(asset.file!).setLastModifiedSync(buildTime);
      }
    }
  });
}
