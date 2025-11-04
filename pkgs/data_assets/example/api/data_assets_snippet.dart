// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=76

// ignore_for_file: unused_local_variable

// snippet-start
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (input.config.buildDataAssets) {
      final packageName = input.packageName;
      final assetPathInPackage = input.packageRoot.resolve('...');
      final assetPathDownload = input.outputDirectoryShared.resolve('...');

      output.assets.data.add(
        DataAsset(
          package: packageName,
          name: '...',
          file: assetPathInPackage,
        ),
      );
    }
  });
}

// snippet-end
