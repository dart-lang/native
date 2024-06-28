// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) => build(
      args,
      (config, output) async {
        output.addAsset(
          DataAsset(
            package: config.packageName,
            name: 'assetId',
            file: config.packageRoot.resolve('asset/test_asset.txt'),
          ),
        );
        output.addDependency(config.packageRoot.resolve('hook/build.dart'));
      },
    );
