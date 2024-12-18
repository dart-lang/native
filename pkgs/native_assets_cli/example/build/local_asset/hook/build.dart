// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/code_assets.dart';

const assetName = 'asset.txt';
final packageAssetPath = Uri.file('assets/$assetName');

Future<void> main(List<String> args) async {
  await build(args, (config, output) async {
    if (config.codeConfig.linkModePreference == LinkModePreference.static) {
      // Simulate that this build hook only supports dynamic libraries.
      throw UnsupportedError(
        'LinkModePreference.static is not supported.',
      );
    }

    final packageName = config.packageName;
    final assetPath = config.outputDirectory.resolve(assetName);
    final assetSourcePath = config.packageRoot.resolveUri(packageAssetPath);
    // ignore: deprecated_member_use
    if (!config.dryRun) {
      // Insert code that downloads or builds the asset to `assetPath`.
      await File.fromUri(assetSourcePath).copy(assetPath.toFilePath());

      output.addDependencies([
        assetSourcePath,
      ]);
    }

    output.codeAssets.add(
      // TODO: Change to DataAsset once the Dart/Flutter SDK can consume it.
      CodeAsset(
        package: packageName,
        name: 'asset.txt',
        file: assetPath,
        linkMode: DynamicLoadingBundled(),
        os: config.codeConfig.targetOS,
        architecture:
            // ignore: deprecated_member_use
            config.dryRun ? null : config.codeConfig.targetArchitecture,
      ),
    );
  });
}
