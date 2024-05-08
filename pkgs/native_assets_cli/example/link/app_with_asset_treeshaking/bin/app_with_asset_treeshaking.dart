// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:app_with_asset_treeshaking/app_with_asset_treeshaking.dart'
    as app_with_asset_treeshaking;

void main(List<String> arguments) {
  print('Hello world: ${app_with_asset_treeshaking.callOther()}!');
}
