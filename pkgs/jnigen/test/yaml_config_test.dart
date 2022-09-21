// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// End-to-end test confirming yaml config works as expected.

import 'dart:io';

import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  final thirdParty = join('test', 'jackson_core_test', 'third_party');
  final testLib = join(thirdParty, 'test_lib_yaml');
  final testSrc = join(thirdParty, 'test_src_yaml');
  final lib = join(thirdParty, 'lib');
  final src = join(thirdParty, 'src');
  final config = join('test', 'jackson_core_test', 'jnigen.yaml');
  test('generate and compare bindings using YAML config', () async {
    final jnigenProc = await Process.start(
        'dart',
        [
          'run',
          'jnigen',
          '--config',
          config,
          '-Dc_root=$testSrc',
          '-Ddart_root=$testLib'
        ],
        mode: ProcessStartMode.inheritStdio);
    expect(await jnigenProc.exitCode, equals(0));

    final analyzeProc =
        Process.runSync('dart', ['analyze', testLib], runInShell: true);
    expect(analyzeProc.exitCode, equals(0));

    compareDirs(lib, testLib);
    compareDirs(src, testSrc);

    for (var dir in [testLib, testSrc]) {
      Directory(dir).deleteSync(recursive: true);
    }
  }, timeout: Timeout.factor(4));
}
