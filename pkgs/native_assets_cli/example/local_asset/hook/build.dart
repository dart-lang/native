// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/native_assets_cli.dart';

const assetName = 'asset.txt';
final packageAssetPath = Uri.file('data/$assetName');

void main(List<String> args) async {
  await build(args, (config, output) async {
    if (config.linkModePreference == LinkModePreference.static) {
      // Simulate that this build hook only supports dynamic libraries.
      throw UnsupportedError(
        'LinkModePreference.static is not supported.',
      );
    }

    final packageName = config.packageName;
    final assetPath = config.outputDirectory.resolve(assetName);
    final assetSourcePath = config.packageRoot.resolveUri(packageAssetPath);
    if (!config.dryRun) {
      // Insert code that downloads or builds the asset to `assetPath`.
      await File.fromUri(assetSourcePath).copy(assetPath.toFilePath());

      output.addDependencies([
        assetSourcePath,
        config.packageRoot.resolve('hook/build.dart'),
      ]);
    }

    output.addAsset(
      // TODO: Change to DataAsset once the Dart/Flutter SDK can consume it.
      NativeCodeAsset(
        package: packageName,
        name: 'asset.txt',
        file: assetPath,
        linkMode: DynamicLoadingBundled(),
        os: config.targetOS,
        architecture: config.targetArchitecture,
      ),
    );
  });
}
