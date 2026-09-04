// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:ffigen/src/header_parser.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../../example/shared_bindings/tool/ffigen.dart' as shared_bindings;
import '../test_utils.dart';

void main() {
  group('shared_bindings_example', () {
    final packageRoot = path.join(
      packagePathForTests,
      'example',
      'shared_bindings/',
    );

    test('base bindings', () async {
      final config = shared_bindings.getBaseConfig(Uri.file(packageRoot));
      final context = testContext(config);
      final library = parse(context);
      await matchLibraryWithExpected(
        context,
        library,
        'example_shared_bindings_base.dart',
        ['example', 'shared_bindings', 'lib', 'generated', 'base_gen.dart'],
      );
    });

    test('a bindings', () async {
      final config = shared_bindings.getAConfig(Uri.file(packageRoot));
      final context = testContext(config);
      final library = parse(context);
      await matchLibraryWithExpected(
        context,
        library,
        'example_shared_bindings_a.dart',
        ['example', 'shared_bindings', 'lib', 'generated', 'a_gen.dart'],
      );
    });

    test('a_shared_base bindings', () async {
      final config = shared_bindings.getASharedBaseConfig(
        Uri.file(packageRoot),
      );
      final context = testContext(config);
      final library = parse(context);
      await matchLibraryWithExpected(
        context,
        library,
        'example_shared_bindings.dart',
        [
          'example',
          'shared_bindings',
          'lib',
          'generated',
          'a_shared_b_gen.dart',
        ],
      );
    });

    test('base symbol file output', () async {
      final config = shared_bindings.getBaseConfig(Uri.file(packageRoot));
      final context = testContext(config);
      final library = parse(context);
      await matchLibrarySymbolFileWithExpected(
        context,
        library,
        'example_shared_bindings.yaml',
        [config.output.symbolFile!.output.toFilePath()],
        config.output.symbolFile!.importPath.toString(),
      );
    });
  });
}
