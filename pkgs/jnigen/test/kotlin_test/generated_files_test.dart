// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/jnigen.dart';
import 'package:test/test.dart';

import 'generate.dart';
import '../test_util/test_util.dart';

void main() async {
  // This is not run in setupAll, because we want to exit with one line of
  // error message, not throw a long exception.
  await checkLocallyBuiltDependencies();
  generateAndCompareBothModes(
    'Generate and compare bindings for kotlin_test',
    getConfig(BindingsType.cBased),
    getConfig(BindingsType.dartOnly),
  );
  test(
    "Generate and analyze bindings for kotlin_test - pure dart",
    () async {
      await generateAndAnalyzeBindings(
        getConfig(BindingsType.dartOnly),
      );
    },
    timeout: const Timeout.factor(1.5),
    tags: largeTestTag,
  );
}
