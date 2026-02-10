// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/elements/j_elements.dart' as j;

class Renamer extends j.Visitor {
  @override
  void visitClass(j.ClassDecl c) {
    c.name = 'J${c.originalName}';
  }
}

Future<void> main() async {
  final classes = [
    'java.util.ArrayList',
    'java.util.HashMap',
    'java.util.HashSet',
    'java.util.Iterator',
    'java.util.List',
    'java.util.Map',
    'java.util.Set',
  ];
  const preamble = '''
// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: prefer_relative_imports''';

  await generateJniBindings(
    Config(
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample: 'example/',
      ),
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: Platform.script.resolve('../lib/src/core_bindings.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      classes: classes,
      hide: classes,
      preamble: preamble,
      visitors: [Renamer()],
    ),
  );
  await generateJniBindings(
    Config(
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample: 'example/',
      ),
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: Platform.script
              .resolve('../lib/src/plugin/generated_plugin.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      classes: ['com.github.dart_lang.jni.JniPlugin'],
      preamble: preamble,
    ),
  );
}
