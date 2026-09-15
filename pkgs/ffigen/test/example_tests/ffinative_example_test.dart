// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../example/ffinative/tool/ffigen.dart' as ffinative_example;
import '../test_utils.dart';

void main() {
  group('ffinative_example_test', () {
    test('ffinative', () async {
      final packageRoot = path.join(
        packagePathForTests,
        'example',
        'ffinative/',
      );
      final context = testContext(
        ffinative_example.getConfig(Uri.file(packageRoot)),
      );
      final library = parse(context);

      await matchLibraryWithExpected(
        context,
        library,
        'example_ffinative.dart',
        ['example', 'ffinative', 'lib', 'generated_bindings.dart'],
      );
    });
  });
}
