// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Run this script after any change which affects generated bindings.
//
// This will update all generated bindings in the whole repository.

import 'dart:io';

import 'command_runner.dart';

const scripts = [
  'test/jackson_core_test/generate.dart',
  'test/simple_package_test/generate.dart',
  'test/kotlin_test/generate.dart',
];

const yamlBasedExamples = [
  'example/in_app_java',
  'example/pdfbox_plugin',
  'example/notification_plugin',
  'example/kotlin_plugin',
];

void main() async {
  final runners = <Runner>[];
  final current = Directory.current.uri;
  for (var script in scripts) {
    runners.add(Runner('Run generate script: $script', current)
      ..chainCommand('dart', ['run', script]));
  }

  for (var yamlDir in yamlBasedExamples) {
    runners.add(
        Runner('Regenerate bindings in $yamlDir', current.resolve(yamlDir))
          ..chainCommand('dart', ['run', 'jnigen', '--config', 'jnigen.yaml']));
  }

  await Future.wait(runners.map((runner) => runner.run()).toList());
}
