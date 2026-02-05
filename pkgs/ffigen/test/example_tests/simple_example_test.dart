// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('simple_example_test', () {
    test('simple', () {
      final config = testConfigFromPath(
        path.join(packagePathForTests, 'example', 'simple', 'config.yaml'),
      );
      final context = testContext(config);
      final library = parse(context);

      matchLibraryWithExpected(context, library, 'example_simple.dart', [
        config.output.dartFile.toFilePath(),
      ]);
    });
  });
}
