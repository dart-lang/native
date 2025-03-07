// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/src/config/config_types.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

void main() {
  test('Java core libraries are generated without providing class path',
      () async {
    await generateAndAnalyzeBindings(
      Config(
        outputConfig: OutputConfig(
          dartConfig: DartCodeOutputConfig(
            path: Uri.file('foo.dart'),
            structure: OutputStructure.singleFile,
          ),
        ),
        classes: [
          // A random assortment of Java core classes.
          'java.lang.StringBuilder',
          'java.lang.ModuleLayer',
          'java.net.SocketOption',
        ],
      ),
    );
  });
}
