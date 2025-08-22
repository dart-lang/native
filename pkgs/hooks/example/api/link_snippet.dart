// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// dart format width=76

// snippet-start
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await link(args, (input, output) async {
    final dataEncodedAssets = input.assets.encodedAssets.where(
      (e) => e.isDataAsset,
    );
    output.assets.addEncodedAssets(dataEncodedAssets);
  });
}

// snippet-end
