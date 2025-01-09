// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:fail_build/fail_build.dart';
import 'package:native_assets_cli/data_assets.dart';

void main(List<String> arguments) async {
  await build(arguments, (input, output) async {
    // Does nothing, just depends on `package:fail_build`.
    invokeFailBuildCode();
  });
}
