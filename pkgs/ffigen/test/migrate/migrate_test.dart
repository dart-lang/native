// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'util.dart';

export 'util.dart';

void main() {
  group('migrate_test', () {
    final yamlDir = Directory(
      path.join(packagePathForTests, 'test', 'migrate', 'yaml'),
    );

    final yamlFiles =
        yamlDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.yaml'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

    for (final yamlFile in yamlFiles) {
      final testName = path.basenameWithoutExtension(yamlFile.path);
      test('verifyMigration for $testName', () async {
        await verifyMigration(yamlFile);
      }, timeout: const Timeout(Duration(minutes: 2)));
    }
  });
}
