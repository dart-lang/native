// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:native_test_helpers/native_test_helpers.dart';
import 'package:test/test.dart';

void main() {
  // The examples in this repository are large, make sure only the examples
  // README.md is published and not the examples.
  test('Do not publish samples', () {
    final packageRoot = findPackageRoot('code_assets');

    final dryRunResult = Process.runSync(
      'dart',
      ['pub', 'publish', '--dry-run'],
      workingDirectory: packageRoot.toFilePath(),
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    printOnFailure(dryRunResult.stderr as String);
    printOnFailure(dryRunResult.stdout as String);
    expect(
      dryRunResult.stdout,
      contains(
        // Expect that the _only_ file in example is README.md.
        '''
├── example
│   └── README.md
'''
            .trim(),
      ),
    );
  });
}
