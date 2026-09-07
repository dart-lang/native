// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../example/simple/tool/ffigen.dart' as simple_example;
import '../test_utils.dart';

void main() {
  group('simple_example_test', () {
    test('simple', () async {
      final packageRoot = path.join(packagePathForTests, 'example', 'simple/');
      final context = testContext(
        simple_example.getConfig(Uri.file(packageRoot)),
      );
      final library = parse(context);

      await matchLibraryWithExpected(context, library, 'example_simple.dart', [
        'example',
        'simple',
        'generated_bindings.dart',
      ]);
    });
  });
}
