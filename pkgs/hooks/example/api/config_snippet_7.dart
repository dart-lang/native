// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=74

import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    // snippet-start
    final assetsUri = input.userDefines.path('prebuilt_assets_dir');
    if (assetsUri != null) {
      output.dependencies.add(assetsUri);
      // Read assets from the directory...
    }
    // snippet-end
  });
}
