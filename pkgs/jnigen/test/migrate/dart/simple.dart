// ignore_for_file: unused_import
import 'dart:io';

import 'package:jnigen/jnigen.dart';

const preamble = '''
// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''';

Future<void> main() async {
  final packageRoot = Uri.directory('test/simple_package_test/');
  await JniGenerator(
    input: Input(
      sourcePath: [
        packageRoot.resolve('java'),
      ],
      classes: [
        'com.github.dart_lang.jnigen.enums.Colors',
      ],
    ),
    output: Output(
      dart: DartOutput(
        path: packageRoot.resolve('simple.dart'),
        structure: OutputStructure.singleFile,
      ),
      preamble: preamble,
    ),
    imports: const SymbolImports(
      hide: [
        'java.lang.Object',
      ],
    ),
  ).generate();
}
