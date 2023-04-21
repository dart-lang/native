// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'package:jnigen/jnigen.dart';

import '../test_util/test_util.dart';
import 'generate.dart';

void main() async {
  await checkLocallyBuiltDependencies();

  test("compare generated bindings for jackson_core", () async {
    final lib = join(thirdPartyDir, 'lib');
    final src = join(thirdPartyDir, 'src');
    await generateAndCompareBindings(getConfig(), lib, src);
  }, timeout: const Timeout.factor(2));

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

  test('Generate and analyze pure dart bindings', () async {
    final config = getConfig(generateFullVersion: true);
    config.outputConfig.bindingsType = BindingsType.dartOnly;
    await generateAndAnalyzeBindings(config);
  }, timeout: const Timeout.factor(2), tags: largeTestTag);
}
