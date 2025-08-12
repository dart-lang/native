// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:jnigen/jnigen.dart';

void main() {
  generateJniBindings(
    Config(
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample: 'example/',
      ),
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: Uri.file('lib/src/plugin/generated_plugin.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      classes: ['com.github.dart_lang.jni.JniPlugin'],
      preamble: '''
// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_relative_imports''',
    ),
  );
}
