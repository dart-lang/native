// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:jnigen/jnigen.dart';

const testName = 'simple_package_test';
final testRoot = join('test', testName);
final javaPath = join(testRoot, 'java');

const preamble = '''
// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

''';

var javaPrefix = join('com', 'github', 'dart_lang', 'jnigen');

var javaFiles = [
  join(javaPrefix, 'simple_package', 'Example.java'),
  join(javaPrefix, 'pkg2', 'C2.java'),
  join(javaPrefix, 'pkg2', 'Example.java'),
];

void compileJavaSources(String workingDir, List<String> files) async {
  final procRes = Process.runSync('javac', files, workingDirectory: workingDir);
  if (procRes.exitCode != 0) {
    throw "javac exited with ${procRes.exitCode}\n"
        "$procRes.stderr";
  }
}

Config getConfig() {
  compileJavaSources(javaPath, javaFiles);
  final cWrapperDir = Uri.directory(join(testRoot, "src"));
  final dartWrappersRoot = Uri.directory(join(testRoot, "lib"));
  final config = Config(
    sourcePath: [Uri.directory(javaPath)],
    classPath: [Uri.directory(javaPath)],
    classes: [
      'com.github.dart_lang.jnigen.simple_package',
      'com.github.dart_lang.jnigen.pkg2',
    ],
    preamble: preamble,
    cRoot: cWrapperDir,
    dartRoot: dartWrappersRoot,
    logLevel: Level.INFO,
    libraryName: 'simple_package',
  );
  return config;
}

void main() async => await generateJniBindings(getConfig());
