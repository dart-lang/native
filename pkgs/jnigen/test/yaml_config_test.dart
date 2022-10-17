// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// End-to-end test confirming yaml config works as expected.

import 'package:jnigen/jnigen.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  final thirdParty = join('test', 'jackson_core_test', 'third_party');
  final testLib = join(thirdParty, 'test_lib_yaml');
  final testSrc = join(thirdParty, 'test_src_yaml');
  final lib = join(thirdParty, 'lib');
  final src = join(thirdParty, 'src');
  final configFile = join('test', 'jackson_core_test', 'jnigen.yaml');
  test('generate and compare bindings using YAML config', () async {
    final args = [
      '--config',
      configFile,
      '-Doutput.c.path=$testSrc/',
      '-Doutput.dart.path=$testLib/',
    ];
    final config = Config.parseArgs(args);
    await generateAndCompareBindings(config, lib, src);
  }, timeout: Timeout.factor(4));
}
