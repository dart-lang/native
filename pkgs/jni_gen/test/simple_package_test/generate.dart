// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart';
import 'package:jni_gen/jni_gen.dart';

import '../test_util/test_util.dart';

const testName = 'simple_package_test';
final testRoot = join('test', testName);
final javaPath = join(testRoot, 'java');

var javaPrefix = join('com', 'github', 'dart_lang', 'jni_gen');

var javaFiles = [
  join(javaPrefix, 'simple_package', 'Example.java'),
  join(javaPrefix, 'pkg2', 'C2.java'),
];

Future<void> compileJavaSources(String workingDir, List<String> files) async {
  await runCmd('javac', files, workingDirectory: workingDir);
}

Future<void> generateSources(String lib, String src) async {
  await compileJavaSources(javaPath, javaFiles);
  final cWrapperDir = Uri.directory(join(testRoot, src));
  final dartWrappersRoot = Uri.directory(join(testRoot, lib));
  final cDir = Directory.fromUri(cWrapperDir);
  final dartDir = Directory.fromUri(dartWrappersRoot);
  for (var dir in [cDir, dartDir]) {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
  final config = Config(
    sourcePath: [Uri.directory(javaPath)],
    classPath: [Uri.directory(javaPath)],
    classes: [
      'com.github.dart_lang.jni_gen.simple_package',
      'com.github.dart_lang.jni_gen.pkg2',
    ],
    cRoot: cWrapperDir,
    dartRoot: dartWrappersRoot,
    libraryName: 'simple_package',
  );
  await generateJniBindings(config);
}

void main() async => await generateSources('lib', 'src');
