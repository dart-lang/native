// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';

Future<void> main() async {
  final testRoot = Platform.script.resolve('.');
  await generateJniBindings(
    Config(
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: testRoot.resolve('lib/large_test.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      sourcePath: [testRoot.resolve('java/')],
      classes: ['com.example'],
    ),
  );
}
