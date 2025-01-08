// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:native_assets_cli/data_assets.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final assetDirectory =
        Directory.fromUri(input.packageRoot.resolve('assets/'));
    // If assets are added, rerun hook.
    output.addDependency(assetDirectory.uri);

    await for (final dataAsset in assetDirectory.list()) {
      if (dataAsset is! File) {
        continue;
      }

      // The file path relative to the package root, with forward slashes.
      final name = dataAsset.uri
          .toFilePath(windows: false)
          .substring(input.packageRoot.toFilePath(windows: false).length);

      output.assets.data.add(
        DataAsset(
          package: packageName,
          name: name,
          file: dataAsset.uri,
        ),
        linkInPackage: input.config.linkingEnabled ? packageName : null,
      );
      // TODO(https://github.com/dart-lang/native/issues/1208): Report
      // dependency on asset.
      output.addDependency(dataAsset.uri);
    }
  });
}
