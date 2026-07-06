// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:jnigen/src/util/dart_executable.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

import 'simple_package_test/runtime_test_registrant.dart'
    as simple_package_test;
import 'test_util/test_util.dart';

late Directory tempClassDir;

void main() {
  setUpAll(() async {
    await runCommand(dartExecutable, ['run', 'jni:setup']);
    tempClassDir =
        Directory.current.createTempSync('jnigen_simple_package_test_');
    final simplePackageTestJava = join('test', 'simple_package_test', 'java');
    await compileJavaFiles(Directory(simplePackageTestJava), tempClassDir);
    if (!Platform.isAndroid) {
      Jni.spawnIfNotExists(
        dylibDir: join('build', 'jni_libs'),
        classPath: [
          join('build', 'jni_libs', 'jni.jar'),
          tempClassDir.path,
        ],
        jvmOptions: [
          '-Xcheck:jni',
        ],
      );
    }
  });

  simple_package_test.registerTests('simple_package_test', test);

  tearDownAll(() {
    tempClassDir.deleteSync(recursive: true);
  });
}
