// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';

Future<void> main() async {
  const preamble = '''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_relative_imports''';

  final packageRoot = Platform.script.resolve('..');
  await generateJniBindings(
    Config(
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample:
            packageRoot.resolve('android_test_runner/').toFilePath(),
      ),
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/src/generated_plugin.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      classes: ['com.github.dart_lang.jni_flutter.JniFlutterPlugin'],
      preamble: preamble,
    ),
  );
}
