// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

const packageName = 'simple_link';

void main(List<String> args) async => build(args, (config, output) async {
      output.addAssets(
        List.generate(
          4,
          (index) => DataAsset(
            name: 'data_$index',
            // TODO(mosuem): Simplify specifying files/file paths
            file: config.packageRoot.resolve('assets/data_$index.json'),
            package: packageName,
          ),
        ),
        linkInPackage: config.linkingAvailable ? 'simple_link' : null,
      );
    });
