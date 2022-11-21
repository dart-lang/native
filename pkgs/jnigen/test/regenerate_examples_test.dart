// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' hide equals;

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/tools.dart';

import 'test_util/test_util.dart';

final inAppJava = join('example', 'in_app_java');
final inAppJavaYaml = join(inAppJava, 'jnigen.yaml');
final notificationPlugin = join('example', 'notification_plugin');
final notificationPluginYaml = join(notificationPlugin, 'jnigen.yaml');

/// Generates bindings using jnigen config in [exampleName] and compares
/// them to provided reference outputs.
///
/// [dartOutput] and [cOutput] are relative paths from example project dir.
void testExample(String exampleName, String dartOutput, String? cOutput) {
  test('Generate and compare bindings for $exampleName',
      timeout: Timeout.factor(2), () async {
    final examplePath = join('example', exampleName);
    final configPath = join(examplePath, 'jnigen.yaml');

    final dartBindingsPath = join(examplePath, dartOutput);
    String? cBindingsPath;
    if (cOutput != null) {
      cBindingsPath = join(examplePath, cOutput);
    }

    final config = Config.parseArgs(['--config', configPath]);
    try {
      await generateAndCompareBindings(config, dartBindingsPath, cBindingsPath);
    } on GradleException catch (_) {
      stderr.writeln('Skip: $exampleName');
    }
  });
}

void main() {
  testExample(
    'in_app_java',
    join('lib', 'android_utils.dart'),
    join('src', 'android_utils'),
  );
  testExample('pdfbox_plugin', join('lib', 'src', 'third_party'), 'src');
  testExample(
    'notification_plugin',
    join('lib', 'notifications.dart'),
    'src',
  );
}
