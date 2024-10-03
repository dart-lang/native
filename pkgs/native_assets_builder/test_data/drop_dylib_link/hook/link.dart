// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> arguments) async {
  await link(arguments, (config, output) async {
    for (final codeAsset in config.codeAssets.all) {
      print('Got code asset: ${codeAsset.id}');
      if (codeAsset.id.endsWith('add')) {
        output.codeAssets.add(codeAsset);
        print('-> Keeping ${codeAsset.id}');
      } else {
        print('-> Dropping ${codeAsset.id}');
      }
    }
  });
}
