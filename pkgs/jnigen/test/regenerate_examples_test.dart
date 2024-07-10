// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/tools.dart';
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

import 'test_util/test_util.dart';

final inAppJava = join('example', 'in_app_java');
final inAppJavaYaml = join(inAppJava, 'jnigen.yaml');
final notificationPlugin = join('example', 'notification_plugin');
final notificationPluginYaml = join(notificationPlugin, 'jnigen.yaml');
final kotlinPlugin = join('example', 'kotlin_plugin');
final kotlinPluginYaml = join(kotlinPlugin, 'jnigen.yaml');

/// Generates bindings using jnigen config in [exampleName] and compares
/// them to provided reference outputs.
///
/// [dartOutput] and [cOutput] are relative paths from example project dir.
///
/// Pass [isLargeTest] as true if the test will take considerable time.
void testExample(String exampleName, String dartOutput, String? cOutput,
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

void main() async {
  await checkLocallyBuiltDependencies();
  testExample(
    'in_app_java',
    join('lib', 'android_utils.dart'),
    join('src', 'android_utils'),
    isLargeTest: true,
  );
  testExample(
    'pdfbox_plugin',
    join('lib', 'src', 'third_party'),
    'src',
    isLargeTest: false,
  );
  testExample(
    'notification_plugin',
    join('lib', 'notifications.dart'),
    'src',
    isLargeTest: true,
  );
  testExample(
    'kotlin_plugin',
    join('lib', 'kotlin_bindings.dart'),
    'src',
    isLargeTest: true,
  );
}
