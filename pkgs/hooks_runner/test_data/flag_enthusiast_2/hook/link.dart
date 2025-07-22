// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:fun_with_flags/src/hook.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await link(args, (input, output) async {
    output.registerFlagUse(input.packageName, ['fr']);
  });
}
