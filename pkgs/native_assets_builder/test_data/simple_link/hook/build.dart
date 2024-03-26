// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:path/path.dart' as p;

const packageName = 'simple_link';

void main(List<String> args) async => build(args, (config, output) async {
      output.addAssets(
        List.generate(
          4,
          (index) => DataAsset(
            name: 'data_$index',
            // TODO(mosuem): Simplify specifying files/file paths
            file: Uri.file(p.absolute('data_$index.json')),
            package: packageName,
          ),
        ),
        linkInPackage: 'simple_link',
      );
    });
