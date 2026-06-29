// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jnigen/jnigen.dart';
import 'package:jnigen/src/util/jdk_util.dart' as jdk_util;
import 'package:logging/logging.dart';
import 'package:path/path.dart';

const preamble = '''
// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

''';

Config getConfig() {
  final testRoot = join('test', 'stub_test');
  final javaPath = join(testRoot, 'java');
  final dartPath = join(testRoot, 'bindings.dart');

  final javaFiles = [
    join('com', 'example', 'A.java'),
    join('com', 'example', 'B.java'),
    join('com', 'example', 'C.java'),
    join('com', 'example', 'D.java'),
    join('com', 'example', 'E.java'),
  ];

  final javac = jdk_util.resolveJavaExecutable('javac');
  final procRes = Process.runSync(javac, javaFiles,
      workingDirectory: javaPath, environment: jdk_util.getJavaEnvironment());
  if (procRes.exitCode != 0) {
    stderr.writeln(procRes.stderr);
    exit(1);
  }

  return Config(
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
    preamble: preamble,
  );
}

void main() async {
  await generateJniBindings(getConfig());
}
