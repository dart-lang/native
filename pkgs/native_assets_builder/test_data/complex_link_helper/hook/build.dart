// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

const packageName = 'complex_link_helper';

void main(List<String> args) async => build(args, (config, output) async {
      output.addAssets(
        List.generate(
          2,
          (index) => DataAsset(
            name: 'data_helper_$index',
            // TODO(mosuem): Simplify specifying files/file paths
            file: config.packageRoot.resolve('assets/data_helper_$index.json'),
            package: packageName,
          ),
        ),
      );
      output.addAssets(
        List.generate(
          2,
          (index) => DataAsset(
            name: 'data_helper_${index + 2}',
            // TODO(mosuem): Simplify specifying files/file paths
            file: config.packageRoot
                .resolve('assets/data_helper_${index + 2}.json'),
            package: packageName,
          ),
        ),
        linkInPackage: 'complex_link',
      );
    });
