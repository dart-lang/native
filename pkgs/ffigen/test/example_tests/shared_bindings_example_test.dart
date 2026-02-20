// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('shared_bindings_example', () {
    test('a_shared_base bindings', () {
      final config = testConfigFromPath(
        path.join(
          packagePathForTests,
          'example',
          'shared_bindings',
          'ffigen_configs',
          'a_shared_base.yaml',
        ),
      );
      final context = testContext(config);
      final library = parse(context);
      matchLibraryWithExpected(context, library, 'example_shared_bindings.dart', [
        config.output.dartFile.toFilePath(),
      ]);
    });

    test('base symbol file output', () {
      final config = testConfigFromPath(
        path.join(
          packagePathForTests,
          'example',
          'shared_bindings',
          'ffigen_configs',
          'base.yaml',
        ),
      );
      final context = testContext(config);
      final library = parse(context);
      matchLibrarySymbolFileWithExpected(
        context,
        library,
        'example_shared_bindings.yaml',
        [config.output.symbolFile!.output.toFilePath()],
        config.output.symbolFile!.importPath.toString(),
      );
    });
  });
}
