// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

const packageName = 'native_add_library';

/// Implements the protocol from `package:native_assets_cli` by building
/// the C code in `src/` and reporting what native assets it built.
void main(List<String> args) async =>
    await BuildState.build(args, (buildState) async {
      const somefile = 'some_file';

      final path = buildState.getDylibName(somefile);

      // Download/Build the asset to path

      buildState.addAsset(
        id: 'src/$somefile.dart',
        path: AssetAbsolutePath(path),
      );
    });
