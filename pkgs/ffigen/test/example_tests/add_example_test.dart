// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart' show parse;
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../example/add/tool/ffigen.dart' as add_example;
import '../test_utils.dart';

void main() {
  group('add_example_test', () {
    test('add', () {
      final packageRoot = path.join(packagePathForTests, 'example', 'add/');
      final context = testContext(add_example.getConfig(Uri.file(packageRoot)));

      matchLibraryWithExpected(context, parse(context), 'add_example.dart', [
        'example',
        'add',
        'lib',
        'add.g.dart',
      ]);
    });
  });
}
