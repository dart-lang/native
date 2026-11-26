// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Bindings are frozen at jnigen 0.16.0. To regenerate:
//   flutter build apk --debug
//   dart run tool/jnigen.dart

import 'dart:io';

import 'package:jnigen/jnigen.dart';

void main(List<String> args) {
  final packageRoot = Platform.script.resolve('../');
  generateJniBindings(
    Config(
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/legacy_bindings.g.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample: packageRoot.toFilePath(),
      ),
      classPath: [
        packageRoot.resolve(
          'build/app/intermediates/javac/debug/'
          'compileDebugJavaWithJavac/classes',
        ),
        packageRoot.resolve('build/app/tmp/kotlin-classes/debug'),
      ],
      classes: [
        'com.github.dart_lang.jni.legacy',
        // Explicitly list Kotlin classes because ClassFinder stops searching
        // classpath entries once a package is matched in the Java classes dir.
        'com.github.dart_lang.jni.legacy.KotlinLegacy',
        'com.github.dart_lang.jni.legacy.SuspendProvider',
        'android.content.Context',
      ],
      preamble: '''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
''',
    ),
  );
}
