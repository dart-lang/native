// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../example/libclang-example/tool/ffigen.dart' as libclang_example;
import '../test_utils.dart';

void main() {
  group('example_test', () {
    test('libclang-example', () async {
      final packageRoot = path.join(
        packagePathForTests,
        'example',
        'libclang-example/',
      );
      final generator = libclang_example.getConfig(Uri.file(packageRoot));
      final context = testContext(generator);
      final library = parse(context);

      await matchLibraryWithExpected(
        context,
        library,
        'example_libclang.dart',
        ['example', 'libclang-example', 'generated_bindings.dart'],
      );
    });
  });
}
