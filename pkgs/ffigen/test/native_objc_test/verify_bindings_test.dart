// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Objective C support is only available on mac.
@TestOn('mac-os')
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';
import 'util.dart';

void main() {
  group('verify_bindings_test', () {
    final testDir = Directory(
      path.join(packagePathForTests, 'test', 'native_objc_test'),
    );

    // These tests don't use verifyBindings because they generate their bindings
    // programmatically.
    const excludedTests = {
      'deprecated_test.dart',
      'ns_range_test.dart',
      'swift_unavailable_test.dart',
      'transitive_test.dart',
      'verify_bindings_test.dart',
    };

    final testFiles =
        testDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('_test.dart'))
            .map((f) => path.basename(f.path))
            .where((f) => !excludedTests.contains(f))
            .toList()
          ..sort();

    for (final testFile in testFiles) {
      final configName = testFile.replaceFirst('_test.dart', '');

      test('verifyBindings for $testFile', () {
        verifyBindings(configName);
      });
    }
  });
}
