// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Tests on generated code.
//
// Both the simple java example & jackson core classes example have tests in
// same file, because the test runner will reuse the process, which leads to
// reuse of the old JVM with old classpath if we have separate tests with
// different classpaths.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:jnigen/src/tools/gradle_tools.dart';
import 'package:path/path.dart' hide equals;

import 'test_util.dart';

final simplePackageTest = join('test', 'simple_package_test');
final jacksonCoreTest = join('test', 'jackson_core_test');
final kotlinTest = join('test', 'kotlin_test', 'kotlin');
final jniJar = join('build', 'jni_libs', 'jni.jar');

final simplePackageTestJava = join(simplePackageTest, 'java');

late Directory tempClassDir;

Future<void> bindingsTestSetup() async {
  await runCommand('dart', [
    'run',
    'jni:setup',
  ]);
  tempClassDir =
      Directory.current.createTempSync('jnigen_runtime_test_classpath_');
  await compileJavaFiles(Directory(simplePackageTestJava), tempClassDir);
  await runCommand('dart', [
    'run',
    'jnigen:download_maven_jars',
    '--config',
    join(jacksonCoreTest, 'jnigen.yaml')
  ]);

  final jacksonJars = await getJarPaths(join(jacksonCoreTest, 'third_party'));

  final gradlew = await GradleTools.getGradleWExecutable();
  await runCommand(
    gradlew!.path,
    [
      'buildFatJar',
      '-b',
      join(Directory.current.path, kotlinTest, 'build.gradle.kts')
    ],
    workingDirectory: kotlinTest,
    runInShell: true,
  );
  // Jar including Kotlin runtime and dependencies.
  final kotlinTestJar =
      join(kotlinTest, 'build', 'libs', 'kotlin_test-all.jar');

  if (!Platform.isAndroid) {
    Jni.spawn(dylibDir: join('build', 'jni_libs'), classPath: [
      jniJar,
      tempClassDir.path,
      ...jacksonJars,
      kotlinTestJar,
    ], jvmOptions: [
      '-Xcheck:jni',
    ]);
  }
}

void bindingsTestTeardown() {
  tempClassDir.deleteSync(recursive: true);
}
