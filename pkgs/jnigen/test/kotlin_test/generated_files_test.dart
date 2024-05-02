// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'generate.dart';
import '../test_util/test_util.dart';

void main() async {
  // This is not run in setupAll, because we want to exit with one line of
  // error message, not throw a long exception.
  await checkLocallyBuiltDependencies();
  generateAndCompare(
    'Generate and compare bindings for kotlin_test',
    getConfig(),
  );
}
