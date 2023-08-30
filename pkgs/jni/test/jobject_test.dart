// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:ffi';
import 'dart:isolate';

import 'package:test/test.dart';

import 'package:jni/jni.dart';

import 'test_util/test_util.dart';

const maxLongInJava = 9223372036854775807;

void main() {
  // Don't forget to initialize JNI.
  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    Jni.spawnIfNotExists(dylibDir: "build/jni_libs", jvmOptions: ["-Xmx128m"]);
  }
  run(testRunner: test);
}

void run({required TestRunnerCallback testRunner}) {
  // The API based on JniEnv is intended to closely mimic C API of JNI,
  // And thus can be too verbose for simple experimenting and one-off uses
  // JObject API provides an easier way to perform some common operations.
  //
  // However, if binding generation using jnigen is possible, that should be
  // the first choice.
  testRunner("Long.intValue() using JObject", () {
    // JClass wraps a local class reference, and
    // provides convenience functions.
    final longClass = Jni.findJClass("java/lang/Long");

    // looks for a constructor with given signature.
    // equivalently you can lookup a method with name <init>
    final longCtor = longClass.getCtorID("(J)V");

    // note that the arguments are just passed as a list.
    // allowed argument types are primitive types, JObject and its subclasses,
    // and raw JNI references (JObject). Strings will be automatically converted
    // to JNI strings.
    final long = longClass.newInstance(longCtor, [176]);

    final intValue = long.callMethodByName<int>("intValue", "()I", []);
    expect(intValue, equals(176));

    // Release any JObject and JClass instances using `.release()` after use.
    // This is not strictly required since JNI objects / classes have
    // a [NativeFinalizer]. But deleting them after use is a good practice.
    long.release();
    longClass.release();
  });

  testRunner("call a static method using JClass APIs", () {
    final integerClass = Jni.findJClass("java/lang/Integer");
    final result = integerClass.callStaticMethodByName<JString>(
        "toHexString", "(I)Ljava/lang/String;", [JValueInt(31)]);

    // If the object is supposed to be a Java string you can call
    // [toDartString] on it.
    final resultString = result.toDartString();

    // Dart string is a copy, original object can be released.
    result.release();
    expect(resultString, equals("1f"));

    // Also don't forget to release the class.
    integerClass.release();
  });

  testRunner("Call method with null argument, expect exception", () {
    final integerClass = Jni.findJClass("java/lang/Integer");
    expect(
        () => integerClass.callStaticMethodByName<int>(
            "parseInt", "(Ljava/lang/String;)I", [nullptr]),
        throwsException);
    integerClass.release();
  });

  // Skip this test on Android integration test because it fails there, possibly
  // due to a CheckJNI precondition check.
  if (!Platform.isAndroid) {
    testRunner("Try to find a non-exisiting class, expect exception", () {
      expect(() => Jni.findJClass("java/lang/NotExists"), throwsException);
    });
  }

  // [callMethodByName] will be expensive if making same call many times.
  // Use [getMethodID] to get a method ID and use it in subsequent calls.
  testRunner("Example for using getMethodID", () {
    final longClass = Jni.findJClass("java/lang/Long");
    final bitCountMethod = longClass.getStaticMethodID("bitCount", "(J)I");

    // Use newInstance if you want only one instance.
    // It finds the class, gets constructor ID and constructs an instance.
    final random = Jni.newInstance("java/util/Random", "()V", []);

    // You don't need a [JClass] reference to get instance method IDs.
    final nextIntMethod = random.getMethodID("nextInt", "(I)I");

    for (int i = 0; i < 100; i++) {
      int r = random.callMethod<int>(nextIntMethod, [JValueInt(256 * 256)]);
      int bits = 0;
      final jbc = longClass.callStaticMethod<int>(bitCountMethod, [r]);
      while (r != 0) {
        bits += r % 2;
        r = (r / 2).floor();
      }
      expect(jbc, equals(bits));
    }
    random.release();
    longClass.release();
  });

  // One-off invocation of static method in single call.
  testRunner("invoke_", () {
    final m = Jni.invokeStaticMethod<int>("java/lang/Short", "compare", "(SS)I",
        [JValueShort(1234), JValueShort(1324)]);
    expect(m, equals(1234 - 1324));
  });

  testRunner("Java char from string", () {
    final m = Jni.invokeStaticMethod<bool>("java/lang/Character", "isLowerCase",
        "(C)Z", [JValueChar.fromString('X')]);
    expect(m, isFalse);
  });

  // One-off access of static field in single call.
  testRunner("Get static field directly", () {
    final maxLong = Jni.retrieveStaticField<int>(
        "java/lang/Short", "MAX_VALUE", "S", JniCallType.shortType);
    expect(maxLong, equals(32767));
  });

  // Use [callStringMethod] if all you care about is a string result
  testRunner("callStaticStringMethod", () {
    final longClass = Jni.findJClass("java/lang/Long");
    const n = 1223334444;
    final strFromJava = longClass.callStaticMethodByName<String>(
        "toOctalString", "(J)Ljava/lang/String;", [n]);
    expect(strFromJava, equals(n.toRadixString(8)));
    longClass.release();
  });

  // In [JObject], [JClass], and retrieve_/invoke_ methods
  // you can also pass Dart strings, apart from range of types
  // allowed by [Jni.jvalues].
  // They will be converted automatically.
  testRunner(
    "Passing strings in arguments",
    () {
      final out = Jni.retrieveStaticField<JObject>(
          "java/lang/System", "out", "Ljava/io/PrintStream;");
      // uncomment next line to see output
      // (\n because test runner prints first char at end of the line)
      //out.callMethodByName<Null>(
      //    "println", "(Ljava/lang/Object;)V", ["\nWorks (Apparently)"]);
      out.release();
    },
  );

  testRunner("Passing strings in arguments 2", () {
    final twelve = Jni.invokeStaticMethod<int>("java/lang/Byte", "parseByte",
        "(Ljava/lang/String;)B", ["12"], JniCallType.byteType);
    expect(twelve, equals(12));
  });

  // You can use() method on JObject for using once and deleting.
  testRunner("use() method", () {
    final randomInt = Jni.newInstance("java/util/Random", "()V", []).use(
        (random) =>
            random.callMethodByName<int>("nextInt", "(I)I", [JValueInt(15)]));
    expect(randomInt, lessThan(15));
  });

  // The JObject and JClass have NativeFinalizer. However, it's possible to
  // explicitly use `Arena`.
  testRunner('Using arena', () {
    final objects = <JObject>[];
    using((arena) {
      final r = Jni.findJClass('java/util/Random')..releasedBy(arena);
      final ctor = r.getCtorID("()V");
      for (int i = 0; i < 10; i++) {
        objects.add(r.newInstance(ctor, [])..releasedBy(arena));
      }
    });
    for (var object in objects) {
      expect(object.isReleased, isTrue);
    }
  });

  testRunner("enums", () {
    // Don't forget to escape $ in nested type names
    final ordinal = Jni.retrieveStaticField<JObject>(
            "java/net/Proxy\$Type", "HTTP", "Ljava/net/Proxy\$Type;")
        .use((f) => f.callMethodByName<int>("ordinal", "()I", []));
    expect(ordinal, equals(1));
  });

  testRunner("casting", () {
    using((arena) {
      final str = "hello".toJString()..releasedBy(arena);
      final obj = str.castTo(JObject.type)..releasedBy(arena);
      final backToStr = obj.castTo(JString.type);
      expect(backToStr.toDartString(), str.toDartString());
      final _ = backToStr.castTo(JObject.type, releaseOriginal: true)
        ..releasedBy(arena);
      expect(backToStr.toDartString, throwsA(isA<UseAfterReleaseException>()));
      expect(backToStr.release, throwsA(isA<DoubleReleaseException>()));
    });
  });

  testRunner("Isolate", () {
    Isolate.spawn(doSomeWorkInIsolate, null);
  });

  testRunner("Methods rethrow exceptions in Java as JniException", () {
    expect(
      () => Jni.invokeStaticMethod<int>(
          "java/lang/Integer", "parseInt", "(Ljava/lang/String;)I", ["X"]),
      throwsA(isA<JniException>()),
    );
  });

  testRunner("Passing long integer values to JNI", () {
    final maxLongStr = Jni.invokeStaticMethod<String>(
      "java/lang/Long",
      "toString",
      "(J)Ljava/lang/String;",
      [maxLongInJava],
    );
    expect(maxLongStr, equals('$maxLongInJava'));
  });

  testRunner('Returning long integers from JNI', () {
    final maxLong = Jni.retrieveStaticField<int>(
      "java/lang/Long",
      "MAX_VALUE",
      "J",
      JniCallType.longType,
    );
    expect(maxLong, equals(maxLongInJava));
  });
}

void doSomeWorkInIsolate(Void? _) {
  // On standalone target, make sure to call [setDylibDir] before accessing
  // any JNI function in a new isolate.
  //
  // otherwise subsequent JNI calls will throw a "library not found" exception.
  Jni.setDylibDir(dylibDir: "build/jni_libs");
  final random = Jni.newInstance("java/util/Random", "()V", []);
  // final r = random.callMethodByName<int>("nextInt", "(I)I", [256]);
  // expect(r, lessThan(256));
  // Expect throws an [OutsideTestException]
  // but you can uncomment below print and see it works
  // print("\n$r");
  random.release();
}
