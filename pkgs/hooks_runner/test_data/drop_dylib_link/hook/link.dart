// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    for (final codeAsset in input.assets.code) {
      print('Got code asset: ${codeAsset.id}');
      if (codeAsset.id.endsWith('add')) {
        output.assets.code.add(codeAsset);
        print('-> Keeping ${codeAsset.id}');
      } else {
        print('-> Dropping ${codeAsset.id}');
      }
    }
  });
}
