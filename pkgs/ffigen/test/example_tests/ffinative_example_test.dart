// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('ffinative_example_test', () {
    test('ffinative', () {
      final config = testConfigFromPath(
        path.join(packagePathForTests, 'example', 'ffinative', 'config.yaml'),
      );
      final library = parse(testContext(config));

      matchLibraryWithExpected(library, 'example_ffinative.dart', [
        config.output.dartFile.toFilePath(),
      ]);
    });
  });
}
