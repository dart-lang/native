// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../test_util/test_util.dart';
import 'generate_java.dart';

Future<void> main() async {
  test('Generated JNIgen bindings should pass dart analyze', () async {
    final update = Platform.environment['UPDATE'] == 'true';

    // Generate Java code.
    if (update) {
      generateJava();
    } else {
      print('Skipping Java code gen. Set UPDATE=true to '
          'regenerate the .java files.');
    }

    // Compile Java code.
    final javaFiles =
        Directory(p.join(pkgDir, 'test', 'large_java_test', 'java'))
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.java'))
            .map((f) => p.relative(f.path, from: pkgDir))
            .toList();
    final javacResult =
        await Process.run('javac', [...javaFiles], workingDirectory: pkgDir);
    expect(javacResult.exitCode, 0,
        reason: 'Java compilation failed:\n'
            'STDOUT: ${javacResult.stdout}\n'
            'STDERR: ${javacResult.stderr}');

    // Run JNIgen.
    final thisDir = Uri.directory(p.join(pkgDir, 'test', 'large_java_test'));
    await generateJniBindings(
      Config(
        outputConfig: OutputConfig(
          dartConfig: DartCodeOutputConfig(
            path: thisDir.resolve('temp/large_bindings.dart'),
            structure: OutputStructure.singleFile,
          ),
        ),
        sourcePath: [thisDir.resolve('java/')],
        classes: ['com.example'],
      ),
    );

    // Check for diffs.
    final expPath =
        p.join(pkgDir, 'test', 'large_java_test', 'lib', 'large_bindings.dart');
    final actPath = p.join(
        pkgDir, 'test', 'large_java_test', 'temp', 'large_bindings.dart');
    if (update) {
      print('Updating $expPath');
      File(actPath).renameSync(expPath);
    } else {
      comparePaths(expPath, actPath);
      File(actPath).deleteSync();
    }

    // Run dart analyze.
    final analyzeResult = await Process.run(
        'dart', ['analyze', 'test/large_java_test/lib/large_bindings.dart'],
        workingDirectory: pkgDir);
    expect(analyzeResult.exitCode, 0,
        reason: 'Dart analysis failed:\n'
            'STDOUT: ${analyzeResult.stdout}\n'
            'STDERR: ${analyzeResult.stderr}');
  }, timeout: const Timeout(Duration(minutes: 5)));
}
