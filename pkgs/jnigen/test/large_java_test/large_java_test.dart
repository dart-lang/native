// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../test_util/test_util.dart';

void main() {
  test('Generated JNIgen bindings should pass dart analyze', () async {
    // 1. Generate Java code (gated by environment variable).
    final regenerate = true;
    // Platform.environment['REGENERATE_LARGE_TEST_JAVA'] == 'true';
    if (regenerate) {
      final genResult = await Process.run(
          'dart', ['test/large_java_test/generate_java.dart'],
          workingDirectory: pkgDir);
      expect(genResult.exitCode, 0,
          reason: 'Java generation failed: ${genResult.stderr}');
    } else {
      print('Skipping Java code gen. Set REGENERATE_LARGE_TEST_JAVA=true to '
        'regenerate the .java files.');
    }

    // 2. Compile Java code.
    final javaFiles = Directory(p.join(
            pkgDir, 'test', 'large_java_test', 'java', 'com', 'example'))
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.java'))
        .map((f) => p.relative(f.path, from: pkgDir))
        .toList();
    final javacResult = await Process.run('javac', [...javaFiles],
        workingDirectory: pkgDir);
    expect(javacResult.exitCode, 0,
        reason: 'Java compilation failed: ${javacResult.stderr}');

    // 3. Run JNIgen.
    final jnigenResult = await Process.run(
        'dart', ['test/large_java_test/generate_bindings.dart'],
        workingDirectory: pkgDir);
    expect(jnigenResult.exitCode, 0,
        reason: 'JNIgen failed: ${jnigenResult.stderr}');

    // 4. Run dart analyze.
    final analyzeResult = await Process.run(
        'dart', ['analyze', 'test/large_java_test/lib/large_test.dart'],
        workingDirectory: pkgDir);
    expect(analyzeResult.exitCode, 0,
        reason: 'Dart analysis failed:\n'
            '${analyzeResult.stdout}\n${analyzeResult.stderr}');
  });
}
