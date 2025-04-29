// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:code_assets/code_assets.dart';
import 'package:data_assets/data_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> arguments) async {
  await link(arguments, (input, output) async {
    output.assets.code.addAll(input.assets.code);
    output.assets.data.addAll(input.assets.data);
  });
}
