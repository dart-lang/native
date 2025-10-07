// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/tools.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'test_util/test_util.dart';

/// Generates bindings using jnigen config in [exampleName] and compares
/// them to provided reference outputs.
///
/// [dartOutput] is a relative path from the example project dir.
///
/// Pass [isLargeTest] as true if the test will take considerable time.
void testExample(String exampleName, String dartOutput,
    {bool isLargeTest = false}) {
  test(
    'Generate and compare bindings for $exampleName',
    timeout: const Timeout.factor(3),
    () async {
      final examplePath = join('example', exampleName);
      final configPath = join(examplePath, 'jnigen.yaml');

      final config = Config.parseArgs(['--config', configPath]);
      try {
        await generateAndCompareBindings(config);
      } on GradleException catch (_) {
        stderr.writeln('Skip: $exampleName');
      }
    },
    tags: isLargeTest ? largeTestTag : null,
  );
}

void testDartApiExample(
    {required String exampleName,
    required String generatorScriptPath,
    required String outputPath,
    bool isLargeTest = false}) {
  test(
    'Generate and compare bindings for $exampleName',
    timeout: const Timeout.factor(3),
    () async {
      final examplePath = join('example', exampleName);
      try {
        await runCommand(
            Platform.resolvedExecutable, ['run', generatorScriptPath],
            workingDirectory: examplePath);
        final processResults = await Process.run(
            'git', ['diff', '--exit-code', outputPath],
            workingDirectory: examplePath);
        if (processResults.exitCode == 1) {
          fail('The checked-in bindings of $exampleName are out of date. Run '
              'the generator script ($generatorScriptPath) and commit the '
              'changes.\n\n${processResults.stdout}');
        } else if (processResults.exitCode != 0) {
          throw Exception(
              'Invocation of "git diff" failed:\n${processResults.stderr}');
        }
      } on GradleException catch (_) {
        stderr.writeln('Skip: $exampleName');
      }
    },
    tags: isLargeTest ? largeTestTag : null,
  );
}

void main() async {
  await checkLocallyBuiltDependencies();
  testDartApiExample(
    exampleName: 'in_app_java',
    generatorScriptPath: 'tool/jnigen.dart',
    outputPath: join('lib', 'android_utils.g.dart'),
    isLargeTest: true,
  );
  testExample(
    'pdfbox_plugin',
    join('lib', 'src', 'third_party'),
    isLargeTest: false,
  );
  testExample(
    'notification_plugin',
    join('lib', 'notifications.dart'),
    isLargeTest: true,
  );
  testExample(
    'kotlin_plugin',
    join('lib', 'kotlin_bindings.dart'),
    isLargeTest: true,
  );
}
