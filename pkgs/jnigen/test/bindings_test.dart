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
import 'kotlin_test/lib/kotlin.dart';
import 'simple_package_test/lib/simple_package.dart';
import 'jackson_core_test/third_party/lib/com/fasterxml/jackson/core/_package.dart';

import 'test_util/test_util.dart';

final simplePackageTest = join('test', 'simple_package_test');
final jacksonCoreTest = join('test', 'jackson_core_test');
final kotlinTest = join('test', 'kotlin_test');
final jniJar = join(kotlinTest, 'jni.jar');

final simplePackageTestJava = join(simplePackageTest, 'java');
final kotlinTestKotlin = join(kotlinTest, 'kotlin');

Future<void> setupDylibsAndClasses() async {
  await runCommand('dart', [
    'run',
    'jni:setup',
    '-p',
    'jni',
    '-s',
    join(simplePackageTest, 'src'),
  ]);
  final group = join('com', 'github', 'dart_lang', 'jnigen');
  await runCommand(
      'javac',
      [
        join(group, 'simple_package', 'Example.java'),
        join(group, 'generics', 'MyMap.java'),
        join(group, 'generics', 'MyStack.java'),
        join(group, 'generics', 'GrandParent.java'),
        join(group, 'generics', 'StringStack.java'),
        join(group, 'generics', 'StringValuedMap.java'),
        join(group, 'generics', 'StringKeyedMap.java'),
        join(group, 'generics', 'StringMap.java'),
        join(group, 'annotations', 'JsonSerializable.java'),
        join(group, 'annotations', 'MyDataClass.java'),
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

  await runCommand('dart', [
    'run',
    'jni:setup',
    '-p',
    'jni',
    '-s',
    join(kotlinTest, 'src'),
  ]);
  await runCommand(
    'mvn',
    ['package'],
    workingDirectory: kotlinTestKotlin,
    runInShell: true,
  );
  // Jar including Kotlin runtime and dependencies.
  final kotlinTestJar =
      join(kotlinTestKotlin, 'target', 'kotlin_test-jar-with-dependencies.jar');

  if (!Platform.isAndroid) {
    Jni.spawn(dylibDir: join('build', 'jni_libs'), classPath: [
      jniJar,
      simplePackageTestJava,
      ...jacksonJars,
      kotlinTestJar,
    ]);
  }

  Jni.initDLApi();
}

void main() async {
  await checkLocallyBuiltDependencies();
  setUpAll(setupDylibsAndClasses);

  test('static final fields', () {
    expect(Example.ON, equals(1));
    expect(Example.OFF, equals(0));
  });

  test('static & instance fields', () {
    expect(Example.num, equals(121));
    final aux = Example.aux;
    expect(aux.value, equals(true));
    aux.delete();
    expect(C2.CONSTANT, equals(12));
  });

  test('static methods', () {
    expect(Example.addInts(10, 15), equals(25));
  });

  test('static methods arrays', () {
    final array = Example.getArr();
    expect(array[0], 1);
    expect(array[1], 2);
    expect(array[2], 3);
    expect(Example.addAll(array), 6);
    array[0] = 4;
    expect(Example.addAll(array), 9);
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

  test('array of the class', () {
    final ex1 = Example();
    final ex2 = Example();
    ex1.setInternal(1);
    ex2.setInternal(2);
    final array = JArray(Example.type, 2);
    array[0] = ex1;
    array[1] = ex2;
    expect(array[0].getInternal(), 1);
    expect(array[1].getInternal(), 2);
    array.delete();
    ex1.delete();
    ex2.delete();
  });

  test("Check bindings for same-named classes", () {
    expect(Example().whichExample(), 0);
    expect(Example1().whichExample(), 1);
  });

  test('simple json parsing test', () {
    final json = JString.fromString('[1, true, false, 2, 4]');
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
          .createParser6("<html>".toJString()..deletedIn(arena))
        ..deletedIn(arena);
      expect(() => erroneous.nextToken(), throwsA(isA<JniException>()));
    });
  });
  test('exceptions', () {
    expect(() => Example.throwException(), throwsException);
  });
  group('generics', () {
    test('GrandParent constructor', () {
      using((arena) {
        final grandParent = GrandParent('Hello'.toJString()..deletedIn(arena))
          ..deletedIn(arena);
        expect(grandParent, isA<GrandParent<JString>>());
        expect(grandParent.$type, isA<$GrandParentType<JString>>());
        expect(grandParent.value.toDartString(deleteOriginal: true), 'Hello');
      });
    });
    test('MyStack<T>', () {
      using((arena) {
        final stack = MyStack(T: JString.type)..deletedIn(arena);
        stack.push('Hello'.toJString()..deletedIn(arena));
        stack.push('World'.toJString()..deletedIn(arena));
        expect(stack.pop().toDartString(deleteOriginal: true), 'World');
        expect(stack.pop().toDartString(deleteOriginal: true), 'Hello');
      });
    });
    test('MyMap<K, V>', () {
      using((arena) {
        final map = MyMap(K: JString.type, V: Example.type)..deletedIn(arena);
        final helloExample = Example.ctor1(1)..deletedIn(arena);
        final worldExample = Example.ctor1(2)..deletedIn(arena);
        map.put('Hello'.toJString()..deletedIn(arena), helloExample);
        map.put('World'.toJString()..deletedIn(arena), worldExample);
        expect(
          (map.get0('Hello'.toJString()..deletedIn(arena))..deletedIn(arena))
              .getInternal(),
          1,
        );
        expect(
          (map.get0('World'.toJString()..deletedIn(arena))..deletedIn(arena))
              .getInternal(),
          2,
        );
        expect(
          ((map.entryStack()..deletedIn(arena)).pop()..deletedIn(arena))
              .key
              .castTo(JString.type, deleteOriginal: true)
              .toDartString(deleteOriginal: true),
          anyOf('Hello', 'World'),
        );
      });
    });
    group('classes extending generics', () {
      test('StringStack', () {
        using((arena) {
          final stringStack = StringStack()..deletedIn(arena);
          stringStack.push('Hello'.toJString()..deletedIn(arena));
          expect(stringStack.pop().toDartString(deleteOriginal: true), 'Hello');
        });
      });
      test('StringKeyedMap', () {
        using((arena) {
          final map = StringKeyedMap(V: Example.type)..deletedIn(arena);
          final example = Example()..deletedIn(arena);
          map.put('Hello'.toJString()..deletedIn(arena), example);
          expect(
            (map.get0('Hello'.toJString()..deletedIn(arena))..deletedIn(arena))
                .getInternal(),
            0,
          );
        });
      });
      test('StringValuedMap', () {
        using((arena) {
          final map = StringValuedMap(K: Example.type)..deletedIn(arena);
          final example = Example()..deletedIn(arena);
          map.put(example, 'Hello'.toJString()..deletedIn(arena));
          expect(
            map.get0(example).toDartString(deleteOriginal: true),
            'Hello',
          );
        });
      });
      test('StringMap', () {
        using((arena) {
          final map = StringMap()..deletedIn(arena);
          map.put('hello'.toJString()..deletedIn(arena),
              'world'.toJString()..deletedIn(arena));
          expect(
            map
                .get0('hello'.toJString()..deletedIn(arena))
                .toDartString(deleteOriginal: true),
            'world',
          );
        });
      });
    });
    test('superclass count', () {
      expect(JObject.type.superCount, 0);
      expect(MyMap.type(JObject.type, JObject.type).superCount, 1);
      expect(StringKeyedMap.type(JObject.type).superCount, 2);
      expect(StringValuedMap.type(JObject.type).superCount, 2);
      expect(StringMap.type.superCount, 3);
    });
    test('nested generics', () {
      using((arena) {
        final grandParent =
            GrandParent(T: JString.type, "!".toJString()..deletedIn(arena))
              ..deletedIn(arena);
        expect(
          grandParent.value.toDartString(deleteOriginal: true),
          "!",
        );

        final strStaticParent = GrandParent.stringStaticParent()
          ..deletedIn(arena);
        expect(
          strStaticParent.value.toDartString(deleteOriginal: true),
          "Hello",
        );

        final exampleStaticParent = GrandParent.varStaticParent(
            S: Example.type, Example()..deletedIn(arena))
          ..deletedIn(arena);
        expect(
          (exampleStaticParent.value..deletedIn(arena)).getInternal(),
          0,
        );

        final strParent = grandParent.stringParent()..deletedIn(arena);
        expect(
          strParent.parentValue
              .castTo(JString.type, deleteOriginal: true)
              .toDartString(deleteOriginal: true),
          "!",
        );
        expect(
          strParent.value.toDartString(deleteOriginal: true),
          "Hello",
        );

        final exampleParent = grandParent.varParent(
            S: Example.type, Example()..deletedIn(arena))
          ..deletedIn(arena);
        expect(
          exampleParent.parentValue
              .castTo(JString.type, deleteOriginal: true)
              .toDartString(deleteOriginal: true),
          "!",
        );
        expect(
          (exampleParent.value..deletedIn(arena)).getInternal(),
          0,
        );
        // TODO(#139): test constructing Child, currently does not work due
        // to a problem with C-bindings.
      });
    });
  });
  group('Generic type inference', () {
    test('MyStack.of1', () {
      using((arena) {
        final emptyStack = MyStack(T: JString.type)..deletedIn(arena);
        expect(emptyStack.size(), 0);
        final stack = MyStack.of1(
          "Hello".toJString()..deletedIn(arena),
        )..deletedIn(arena);
        expect(stack, isA<MyStack<JString>>());
        expect(stack.$type, isA<$MyStackType<JString>>());
        expect(
          stack.pop().toDartString(deleteOriginal: true),
          "Hello",
        );
      });
    });
    test('MyStack.of 2 strings', () {
      using((arena) {
        final stack = MyStack.of2(
          "Hello".toJString()..deletedIn(arena),
          "World".toJString()..deletedIn(arena),
        )..deletedIn(arena);
        expect(stack, isA<MyStack<JString>>());
        expect(stack.$type, isA<$MyStackType<JString>>());
        expect(
          stack.pop().toDartString(deleteOriginal: true),
          "World",
        );
        expect(
          stack.pop().toDartString(deleteOriginal: true),
          "Hello",
        );
      });
    });
    test('MyStack.of a string and an array', () {
      using((arena) {
        final array = JArray.filled(1, "World".toJString()..deletedIn(arena))
          ..deletedIn(arena);
        final stack = MyStack.of2(
          "Hello".toJString()..deletedIn(arena),
          array,
        )..deletedIn(arena);
        expect(stack, isA<MyStack<JObject>>());
        expect(stack.$type, isA<$MyStackType<JObject>>());
        expect(
          stack
              .pop()
              .castTo(JArray.type(JString.type), deleteOriginal: true)[0]
              .toDartString(deleteOriginal: true),
          "World",
        );
        expect(
          stack
              .pop()
              .castTo(JString.type, deleteOriginal: true)
              .toDartString(deleteOriginal: true),
          "Hello",
        );
      });
    });
    test('MyStack.from array of string', () {
      using((arena) {
        final array = JArray.filled(1, "Hello".toJString()..deletedIn(arena))
          ..deletedIn(arena);
        final stack = MyStack.fromArray(array)..deletedIn(arena);
        expect(stack, isA<MyStack<JString>>());
        expect(stack.$type, isA<$MyStackType<JString>>());
        expect(
          stack.pop().toDartString(deleteOriginal: true),
          "Hello",
        );
      });
    });
    test('MyStack.fromArrayOfArrayOfGrandParents', () {
      using((arena) {
        final firstDimention = JArray.filled(
          1,
          GrandParent("Hello".toJString()..deletedIn(arena))..deletedIn(arena),
        )..deletedIn(arena);
        final twoDimentionalArray = JArray.filled(1, firstDimention)
          ..deletedIn(arena);
        final stack =
            MyStack.fromArrayOfArrayOfGrandParents(twoDimentionalArray)
              ..deletedIn(arena);
        expect(stack, isA<MyStack<JString>>());
        expect(stack.$type, isA<$MyStackType<JString>>());
        expect(
          stack.pop().toDartString(deleteOriginal: true),
          "Hello",
        );
      });
    });
  });
  group('Kotlin support', () {
    test('Suspend functions', () async {
      await using((arena) async {
        final suspendFun = SuspendFun()..deletedIn(arena);
        final hello = await suspendFun.sayHello();
        expect(hello.toDartString(deleteOriginal: true), "Hello!");
        const name = "Bob";
        final helloBob =
            await suspendFun.sayHello1(name.toJString()..deletedIn(arena));
        expect(helloBob.toDartString(deleteOriginal: true), "Hello $name!");
      });
    });
  });
}
