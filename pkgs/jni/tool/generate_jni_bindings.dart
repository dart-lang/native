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
    'java.lang.Boolean',
    'java.lang.Byte',
    'java.lang.Character',
    'java.lang.Double',
    'java.lang.Float',
    'java.lang.Integer',
    'java.lang.Long',
    'java.lang.Number',
    'java.lang.Short',
    'java.lang.String',
    'java.util.ArrayList',
    'java.util.Collection',
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

  final packageRoot = Platform.script.resolve('..');
  final renaming = <String, Map<String, String>>{};
  for (final binaryName in [
    'java.lang.Boolean',
    'java.lang.Byte',
    'java.lang.Double',
    'java.lang.Float',
    'java.lang.Integer',
    'java.lang.Long',
    'java.lang.Short',
  ]) {
    final className = binaryName.split('.').last;
    final sig = switch (className) {
      'Boolean' => '(Z)V',
      'Byte' => '(B)V',
      'Double' => '(D)V',
      'Float' => '(F)V',
      'Integer' => '(I)V',
      'Long' => '(J)V',
      'Short' => '(S)V',
      _ => throw UnimplementedError(),
    };
    renaming[binaryName] = {
      '<init>$sig': 'J$className',
      '<init>(Ljava/lang/String;)V': 'fromString',
    };
  }

  await generateJniBindings(
    Config(
      androidSdkConfig: AndroidSdkConfig(
        addGradleDeps: true,
        androidExample: packageRoot.resolve('example/').toFilePath(),
      ),
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/src/core_bindings.dart'),
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
        androidExample: packageRoot.resolve('example/').toFilePath(),
      ),
      outputConfig: OutputConfig(
        dartConfig: DartCodeOutputConfig(
          path: packageRoot.resolve('lib/src/plugin/generated_plugin.dart'),
          structure: OutputStructure.singleFile,
        ),
      ),
      classes: ['com.github.dart_lang.jni.JniPlugin'],
      preamble: preamble,
    ),
  );
}
