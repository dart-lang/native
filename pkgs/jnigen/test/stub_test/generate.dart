// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

void main() async {
  final testRoot = join('test', 'stub_test');
  final javaPath = join(testRoot, 'java');
  final dartPath = join(testRoot, 'bindings.dart');

  final javaFiles = [
    join('com', 'example', 'A.java'),
    join('com', 'example', 'B.java'),
    join('com', 'example', 'C.java'),
    join('com', 'example', 'D.java'),
    join('com', 'example', 'E.java'),
  ].map((f) => join(javaPath, f)).toList();

  final javac = Process.runSync('javac', javaFiles);
  if (javac.exitCode != 0) {
    stderr.writeln(javac.stderr);
    exit(1);
  }

  final config = Config(
    sourcePath: [Uri.directory(javaPath)],
    classPath: [Uri.directory(javaPath)],
    classes: ['com.example.A', 'com.example.C'],
    outputConfig: OutputConfig(
      dartConfig: DartCodeOutputConfig(
        path: Uri.file(dartPath),
        structure: OutputStructure.singleFile,
      ),
    ),
    generateStubs: true,
    logLevel: Level.INFO,
  );

  await generateJniBindings(config);
}
