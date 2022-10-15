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
import 'package:path/path.dart' hide equals;
import 'package:test/test.dart';

// ignore_for_file: avoid_relative_lib_imports
import 'simple_package_test/lib/com/github/dart_lang/jnigen/simple_package.dart';
import 'simple_package_test/lib/com/github/dart_lang/jnigen/pkg2.dart' as pkg2;
import 'jackson_core_test/third_party/lib/com/fasterxml/jackson/core.dart';

import 'test_util/test_util.dart';

final simplePackageTest = join('test', 'simple_package_test');
final jacksonCoreTest = join('test', 'jackson_core_test');
final simplePackageTestJava = join(simplePackageTest, 'java');

Future<void> setupDylibsAndClasses() async {
  await runCommand('dart', [
    'run',
    'jni:setup',
    '-p',
    'jni',
    '-s',
    join(simplePackageTest, 'src'),
    '-s',
    join(jacksonCoreTest, 'third_party', 'src')
  ]);
  final group = join('com', 'github', 'dart_lang', 'jnigen');
  await runCommand(
      'javac',
      [
        join(group, 'simple_package', 'Example.java'),
        join(group, 'pkg2', 'C2.java'),
        join(group, 'pkg2', 'Example.java'),
      ],
      workingDirectory: simplePackageTestJava);
  await runCommand('dart', [
    'run',
    'jnigen:download_maven_jars',
    '--config',
    join(jacksonCoreTest, 'jnigen.yaml')
  ]);

  final jacksonJars = await getJarPaths(join(jacksonCoreTest, 'third_party'));

  if (!Platform.isAndroid) {
    Jni.spawn(
        dylibDir: join('build', 'jni_libs'),
        classPath: [simplePackageTestJava, ...jacksonJars]);
  }
}

void main() async {
  await setupDylibsAndClasses();

  test('static final fields', () {
    expect(Example.ON, equals(1));
    expect(Example.OFF, equals(0));
  });

  test('static & instance fields', () {
    expect(Example.num, equals(121));
    final aux = Example.aux;
    expect(aux.value, equals(true));
    aux.delete();
    expect(pkg2.C2.CONSTANT, equals(12));
  });

  test('static methods', () {
    expect(Example.addInts(10, 15), equals(25));
  });

  test('instance methods', () {
    final ex = Example();
    expect(ex.getNum(), equals(Example.num));
    final aux = Example.getAux();
    expect(aux.getValue(), equals(true));
    aux.setValue(false);
    expect(aux.getValue(), equals(false));
    aux.setValue(true);
    aux.delete();
    ex.delete();
  });

  test("Check bindings for same-named classes", () {
    expect(Example().whichExample(), 0);
    expect(pkg2.Example().whichExample(), 1);
  });

  test('simple json parsing test', () {
    final json = JniString.fromString('[1, true, false, 2, 4]');
    JsonFactory factory;
    factory = JsonFactory();
    final parser = factory.createParser6(json);
    final values = <bool>[];
    while (!parser.isClosed()) {
      final next = parser.nextToken();
      if (next.isNull) continue;
      values.add(next.isNumeric());
      next.delete();
    }
    expect(values, equals([false, true, false, false, true, true, false]));
    Jni.deleteAll([factory, parser, json]);
  });
  test("parsing invalid JSON throws JniException", () {
    using((arena) {
      final factory = JsonFactory()..deletedIn(arena);
      final erroneous = factory
          .createParser6("<html>".jniString()..deletedIn(arena))
        ..deletedIn(arena);
      expect(() => erroneous.nextToken(), throwsA(isA<JniException>()));
    });
  });
  test('exceptions', () {
    expect(() => Example.throwException(), throwsException);
  });
}
