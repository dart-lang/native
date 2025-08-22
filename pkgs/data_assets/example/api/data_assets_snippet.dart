// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=76

// snippet-start
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final assetPath = input.outputDirectory.resolve('...');

    output.assets.data.add(
      DataAsset(package: packageName, name: '...', file: assetPath),
    );
  });
}

// snippet-end
