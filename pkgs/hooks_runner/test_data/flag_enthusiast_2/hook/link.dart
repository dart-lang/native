// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:fun_with_flags/src/hook.dart';
import 'package:hooks/hooks.dart';

// TODO(mosuem): Actually use the information from the usage recording after
// it lands on stable https://github.com/dart-lang/sdk/issues/61166.
void main(List<String> args) async {
  await link(args, (input, output) async {
    output.registerCountryUse(input.packageName, ['fr']);
  });
}
