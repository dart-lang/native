// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'cpp_class_config.dart' as cpp_class_config;
import 'cpp_inheritance_config.dart' as cpp_inheritance_config;
import 'cpp_pod_config.dart' as cpp_pod_config;
import 'memory_edge_cases_config.dart' as memory_edge_cases_config;
import 'util.dart';

void main() {
  group('verify_bindings_test', () {
    final testDir = Directory(
      path.join(packagePathForTests, 'test', 'native_cpp_test'),
    );

    const excludedTests = {'verify_bindings_test.dart'};

    final testFiles =
        testDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('_test.dart'))
            .map((f) => path.basename(f.path))
            .where((f) => !excludedTests.contains(f))
            .toList()
          ..sort();

    final packageRoot = Uri.file(path.join(packagePathForTests, ''));
    final configs = <String, FfiGenerator>{
      'cpp_class': cpp_class_config.getConfig(packageRoot),
      'cpp_pod': cpp_pod_config.getConfig(packageRoot),
      'memory_edge_cases': memory_edge_cases_config.getConfig(packageRoot),
      'cpp_inheritance': cpp_inheritance_config.getConfig(packageRoot),
    };

    for (final testFile in testFiles) {
      final configName = testFile.replaceFirst('_test.dart', '');
      test('verifyBindings for $testFile', () async {
        final config = configs[configName];
        if (config == null) {
          fail('No FfiGenerator config registered for $testFile in `configs`.');
        }
        await verifyBindings(config);
      });
    }
  });
}
