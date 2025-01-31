// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/config/config.dart';
import 'package:test/test.dart';

import '../test_util/test_util.dart';
import 'generate.dart';

void main() async {
  await checkLocallyBuiltDependencies();

  generateAndCompare(
    'Generate and compare bindings for simple_package java files',
    getConfig(),
  );

  test('Generate and analyze bindings for simple_package java files - doclet',
      () async {
    await generateAndAnalyzeBindings(getConfig(SummarizerBackend.doclet));
  });
}
