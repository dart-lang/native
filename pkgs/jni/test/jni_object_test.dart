// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:ffi';
import 'dart:isolate';

import 'package:test/test.dart';

import 'package:jni/jni.dart';
import 'package:jni/jni_object.dart';

void main() {
  // Don't forget to initialize JNI.
  if (!Platform.isAndroid) {
    Jni.spawn(helperDir: "build/jni_libs");
  }

  final jni = Jni.getInstance();

  // The API based on JniEnv is intended to closely mimic C API
  // And thus can be too verbose for simple experimenting and one-off uses
  // JniObject API provides an easier way to perform some common operations.
  //
  // However, this is only meant for experimenting and very simple uses.
  // For anything complicated, use JNIGen (The main part of this GSoC project)
  // which will be both more efficient and ergonomic.
  test("Long.intValue() using JniObject", () {
    // findJniClass on a Jni object returns a JniClass
    // which wraps a local class reference and env, and
    // provides convenience functions.
    final longClass = jni.findJniClass("java/lang/Long");

    // looks for a constructor with given signature.
    // equivalently you can lookup a method with name <init>
    final longCtor = longClass.getConstructorID("(J)V");

    // note that the arguments are just passed as a list
    final long = longClass.newObject(longCtor, [176]);

    final intValue = long.callIntMethodByName("intValue", "()I", []);
    expect(intValue, equals(176));

    // delete any JniObject and JniClass instances using .delete() after use.
    long.delete();
    longClass.delete();
  });

  test("call a static method using JniClass APIs", () {
    // you can use wrapClass to wrap a raw JClass (which is basically void*)
    // Original ref is saved & will be deleted when you delete the
    // wrapped JniClass.
    final integerClass = jni.wrapClass(jni.findClass("java/lang/Integer"));
    final result = integerClass.callStaticObjectMethodByName(
        "toHexString", "(I)Ljava/lang/String;", [31]);

    // if the object is supposed to be a Java string
    // you can call asDartString on it.
    final resultString = result.asDartString();

    // Dart string is a copy, original object can be deleted.
    result.delete();
    expect(resultString, equals("1f"));

    // Also don't forget to delete the class
    integerClass.delete();
  });

  test("Call method with null argument, expect exception", () {
    final integerClass = jni.findJniClass("java/lang/Integer");
    expect(
        () => integerClass.callStaticIntMethodByName(
            "parseInt", "(Ljava/lang/String;)I", [nullptr]),
        throwsException);
    integerClass.delete();
  });

  test("Try to find a non-exisiting class, expect exception", () {
    expect(() => jni.findJniClass("java/lang/NotExists"), throwsException);
  });

  /// call<Type>MethodByName will be expensive if making same call many times
  /// Use getMethodID to get a method ID and use it in subsequent calls
  test("Example for using getMethodID", () {
    final longClass = jni.findJniClass("java/lang/Long");
    final bitCountMethod = longClass.getStaticMethodID("bitCount", "(J)I");

    // Use newInstance if you want only one instance.
    // It finds the class, gets constructor ID and constructs an instance.
    final random = jni.newInstance("java/util/Random", "()V", []);

    // You don't need a JniClass reference to get instance method IDs
    final nextIntMethod = random.getMethodID("nextInt", "(I)I");

    for (int i = 0; i < 100; i++) {
      int r = random.callIntMethod(nextIntMethod, [256 * 256]);
      int bits = 0;
      final jbc =
          longClass.callStaticIntMethod(bitCountMethod, [JValueLong(r)]);
      while (r != 0) {
        bits += r % 2;
        r = (r / 2).floor();
      }
      expect(jbc, equals(bits));
    }

    random.delete();
    longClass.delete();
  });

  // Actually it's not even required to get a reference to class
  test("invoke_", () {
    final m = jni.invokeLongMethod(
        "java/lang/Long", "min", "(JJ)J", [JValueLong(1234), JValueLong(1324)]);
    expect(m, equals(1234));
  });

  test("retrieve_", () {
    final maxLong = jni.retrieveShortField("java/lang/Short", "MAX_VALUE", "S");
    expect(maxLong, equals(32767));
  });

  // Use callStringMethod if all you care about is a string result
  test("callStaticStringMethod", () {
    final longClass = jni.findJniClass("java/lang/Long");
    const n = 1223334444;
    final strFromJava = longClass.callStaticStringMethodByName(
        "toOctalString", "(J)Ljava/lang/String;", [JValueLong(n)]);
    expect(strFromJava, equals(n.toRadixString(8)));
    longClass.delete();
  });

  // In JniObject, JniClass, and retrieve_/invoke_ methods
  // you can also pass Dart strings, apart from range of types
  // allowed by Jni.jvalues
  // They will be converted automatically.
  test("Passing strings in arguments", () {
    final out = jni.retrieveObjectField(
        "java/lang/System", "out", "Ljava/io/PrintStream;");
    // uncomment next line to see output
    // (\n because test runner prints first char at end of the line)
    //out.callVoidMethodByName(
    //    "println", "(Ljava/lang/Object;)V", ["\nWorks (Apparently)"]);
    out.delete();
  });

  test("Passing strings in arguments 2", () {
    final twelve = jni.invokeByteMethod(
        "java/lang/Byte", "parseByte", "(Ljava/lang/String;)B", ["12"]);
    expect(twelve, equals(12));
  });

  // You can use() method on JniObject for using once and deleting
  test("use() method", () {
    final randomInt = jni.newInstance("java/util/Random", "()V", []).use(
        (random) => random.callIntMethodByName("nextInt", "(I)I", [15]));
    expect(randomInt, lessThan(15));
  });

  test("enums", () {
    // Don't forget to escape $ in nested type names
    final ordinal = jni
        .retrieveObjectField(
            "java/net/Proxy\$Type", "HTTP", "Ljava/net/Proxy\$Type;")
        .use((f) => f.callIntMethodByName("ordinal", "()I", []));
    expect(ordinal, equals(1));
  });

  test("Isolate", () {
    Isolate.spawn(doSomeWorkInIsolate, null);
  });

  // JniObject is valid only in thread it is obtained
  // so it can be safely shared with a function that can run in
  // different thread.
  //
  // Eg: Dart has a thread pool, which means async methods may get scheduled
  // in different thread.
  //
  // In that case, convert the JniObject into `JniGlobalObjectRef` using
  // getGlobalRef() and reconstruct the object in use site using fromJniObject
  // constructor.
  test("JniGlobalRef", () async {
    final uri = jni.invokeObjectMethod(
        "java/net/URI",
        "create",
        "(Ljava/lang/String;)Ljava/net/URI;",
        ["https://www.google.com/search"]);
    final rg = uri.getGlobalRef();
    await Future.delayed(const Duration(seconds: 1), () {
      final env = jni.getEnv();
      // Now comment this line & try to directly use uri local ref
      // in outer scope.
      //
      // You will likely get a segfault, because Future computation is running
      // in different thread.
      //
      // Therefore, don't share JniObjects across functions that can be
      // scheduled across threads, including async callbacks.
      final uri = JniObject.fromGlobalRef(env, rg);
      final scheme =
          uri.callStringMethodByName("getScheme", "()Ljava/lang/String;", []);
      expect(scheme, "https");
      uri.delete();
      rg.deleteIn(env);
    });
    uri.delete();
  });
}

void doSomeWorkInIsolate(Void? _) {
  // On standalone target, make sure to call load
  // when doing getInstance first time in a new isolate.
  //
  // otherwise getInstance will throw a "library not found" exception.
  Jni.load(helperDir: "build/jni_libs");
  final jni = Jni.getInstance();
  final random = jni.newInstance("java/util/Random", "()V", []);
  // final r = random.callIntMethodByName("nextInt", "(I)I", [256]);
  // expect(r, lessThan(256));
  // Expect throws an OutsideTestException
  // but you can uncomment below print and see it works
  // print("\n$r");
  random.delete();
}
