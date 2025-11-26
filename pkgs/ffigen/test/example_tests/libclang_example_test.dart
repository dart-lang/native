// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator/library.dart';
import 'package:ffigen/src/config_provider/config.dart';
import 'package:ffigen/src/header_parser.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import '../test_utils.dart';

void main() {
  group('example_test', () {
    test('libclang-example', () {
      final configYaml = File(
        path.join(
          packagePathForTests,
          'example',
          'libclang-example',
          'config.yaml',
        ),
      ).absolute;
      final generator = testConfigFromPath(configYaml.path);

      // The clang parser is run using the current working directory, and the
      // libclang-example config relies on relative paths for one of its '-I'
      // compiler options. It can't use absolute paths because it's checked in
      // yaml code. To support concurrent tests, we can't set Directory.current.
      // As a workaround, add an extra '-I' option that uses the absolute path.
      generator.headers.compilerOptions!.add(
        '-I${path.join(packagePathForTests, 'third_party/libclang/include')}'
      );

      final context = testContext(generator);
      final library = parse(context);

      matchLibraryWithExpected(library, 'example_libclang.dart', [
        generator.output.dartFile.toFilePath(),
      ]);
    });
  });
}
