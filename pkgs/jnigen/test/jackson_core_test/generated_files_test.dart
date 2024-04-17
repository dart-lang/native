// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import '../test_util/test_util.dart';
import 'generate.dart';

void main() async {
  await checkLocallyBuiltDependencies();

  generateAndCompare(
    'Generate and compare bindings for jackson_core library',
    getConfig(),
  );
  test(
      'generate and analyze bindings for complete library, '
      'not just required classes', () async {
    final config = getConfig(generateFullVersion: true);
    await generateAndAnalyzeBindings(config);
  }, timeout: const Timeout(Duration(minutes: 2)), tags: largeTestTag);

  test('generate and analyze bindings using ASM', () async {
    final config = getConfig(generateFullVersion: true, useAsm: true);
    await generateAndAnalyzeBindings(config);
  }, timeout: const Timeout(Duration(minutes: 2)), tags: largeTestTag);
}
