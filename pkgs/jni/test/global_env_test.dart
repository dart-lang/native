// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:jni/jni.dart';
import 'package:test/test.dart';

import 'test_util/test_util.dart';

const maxLongInJava = 9223372036854775807;

void main() {
  // Running on Android through flutter, this plugin
  // will bind to Android runtime's JVM.
  // On other platforms eg Flutter desktop or Dart standalone
  // You need to manually create a JVM at beginning.
  //
  // On flutter desktop, the C wrappers are bundled, and helperPath param
  // is not required.
  //
  // On dart standalone, however, there's no way to bundle the wrappers.
  // You have to manually pass the path to the `dartjni` dynamic library.

  if (!Platform.isAndroid) {
    checkDylibIsUpToDate();
    spawnJvm();
  }
  run(testRunner: test);
}

// We are factoring these tests into a run method which allows us to run same
// tests with different environments. Eg: standalone and integration tests.
void run({required TestRunnerCallback testRunner}) {
  // Tests in this file demonstrate how to use `GlobalJniEnv`, a thin
  // abstraction over JNIEnv in JNI C API. This can be used from multiple
  // threads, and converts all returned object references to global references,
  // so that you don't need to worry about whether your Dart code will be
  // scheduled on another thread.
  //
  // GlobalJniEnv wraps all methods of JNIEnv (UpperCamelCase, reflecting the
  // original name of the method) and provides few more extension methods
  // (lowerCamelCase).
  //
  // For examples of a higher level API, see `jni_object_tests.dart`.
  final env = Jni.env;

  testRunner('get JNI Version', () {
    expect(Jni.env.GetVersion(), isNot(equals(0)));
  });

  testRunner(
      'Manually lookup & call Integer.toHexString',
      () => using((arena) {
            // Method names on JniEnv* from C JNI API are capitalized
            // like in original, while other extension methods
            // follow Dart naming conventions.
            final integerClass =
                env.FindClass("java/lang/Integer".toNativeChars(arena));
            // Refer JNI spec on how to construct method signatures
            // Passing wrong signature leads to a segfault
            final hexMethod = env.GetStaticMethodID(
                integerClass,
                "toHexString".toNativeChars(arena),
                "(I)Ljava/lang/String;".toNativeChars(arena));

            for (var i in [1, 80, 13, 76, 11344]) {
              // if your argument is int, bool, or JObject (`Pointer<Void>`)
              // it can be directly placed in the list. To convert into different primitive
              // types, use JValue<Type> wrappers.
              final jres = env.CallStaticObjectMethodA(integerClass, hexMethod,
                  toJValues([JValueInt(i)], allocator: arena));

              // use asDartString extension method on Pointer<JniEnv>
              // to convert a String jobject result to string
              final res = env.toDartString(jres);
              expect(res, equals(i.toRadixString(16)));

              // Any object or class result from java is a local reference
              // and needs to be deleted explicitly.
              // Note that method and field IDs aren't local references.
              // But they are valid only until a reference to corresponding
              // java class exists.
              env.DeleteGlobalRef(jres);
            }
            env.DeleteGlobalRef(integerClass);
          }));

  testRunner("asJString extension method", () {
    const str = "QWERTY QWERTY";
    // convenience method that wraps
    // converting dart string to native string,
    // instantiating java string, and freeing the native string
    final jstr = env.toJStringPtr(str);
    expect(str, equals(env.toDartString(jstr)));
    env.DeleteGlobalRef(jstr);
  });

  testRunner(
      'GlobalJniEnv should catch exceptions',
      () => using((arena) {
            final integerClass =
                env.FindClass("java/lang/Integer".toNativeChars(arena));
            final parseIntMethod = env.GetStaticMethodID(
                integerClass,
                "parseInt".toNativeChars(arena),
                "(Ljava/lang/String;)I".toNativeChars(arena));
            final args = toJValues(["hello".toJString()..releasedBy(arena)],
                allocator: arena);
            expect(
                () => env.CallStaticIntMethodA(
                    integerClass, parseIntMethod, args),
                throwsA(isA<JniException>()));
          }));

  testRunner(
      "Convert back & forth between Dart & Java strings (UTF-8)",
      () => using((arena) {
            const str = "ABCD EFGH";
            final jstr = env.NewStringUTF(str.toNativeChars(arena));
            final jchars = env.GetStringUTFChars(jstr, nullptr);
            final jlen = env.GetStringUTFLength(jstr);
            final dstr = jchars.toDartString(length: jlen);
            env.ReleaseStringUTFChars(jstr, jchars);
            expect(str, equals(dstr));
            env.DeleteGlobalRef(jstr);
          }));

  testRunner(
      "Convert back & forth between Dart & Java strings (UTF-16)",
      () => using((arena) {
            const str = "ABCD EFGH";
            final jstr = env.NewString(str.toNativeUtf16().cast(), str.length);
            final jchars = env.GetStringChars(jstr, nullptr);
            final jlen = env.GetStringLength(jstr);
            final dstr = jchars.cast<Utf16>().toDartString(length: jlen);
            env.ReleaseStringChars(jstr, jchars);
            expect(str, equals(dstr));
            env.DeleteGlobalRef(jstr);
          }));

  testRunner(
      "Print something from Java",
      () => using((arena) {
            final system =
                env.FindClass("java/lang/System".toNativeChars(arena));
            final field = env.GetStaticFieldID(
                system,
                "out".toNativeChars(arena),
                "Ljava/io/PrintStream;".toNativeChars(arena));
            final out = env.GetStaticObjectField(system, field);
            final printStream = env.GetObjectClass(out);
            final println = env.GetMethodID(
                printStream,
                "println".toNativeChars(arena),
                "(Ljava/lang/String;)V".toNativeChars(arena));
            const str = "\nHello World from JNI!";
            final jstr = env.toJStringPtr(str);
            env.CallVoidMethodA(
                out, println, toJValues([jstr], allocator: arena));
            env.DeleteGlobalRef(system);
            env.DeleteGlobalRef(printStream);
            env.DeleteGlobalRef(jstr);
          }));
  testRunner(
      'Env create reference methods should retain their default behavior', () {
    final systemClass = using((arena) {
      return env.FindClass("java/lang/System".toNativeChars(arena));
    });
    final systemOut = using((arena) {
      final outField = env.GetStaticFieldID(
          systemClass,
          "out".toNativeChars(arena),
          "Ljava/io/PrintStream;".toNativeChars(arena));
      return env.GetStaticObjectField(systemClass, outField);
    });
    var refType = env.GetObjectRefType(systemOut);
    expect(refType, JObjectRefType.JNIGlobalRefType);
    final localRef = env.NewLocalRef(systemOut);
    refType = env.GetObjectRefType(localRef);
    expect(refType, JObjectRefType.JNILocalRefType);
    final weakRef = env.NewWeakGlobalRef(systemOut);
    refType = env.GetObjectRefType(weakRef);
    expect(refType, JObjectRefType.JNIWeakGlobalRefType);
    final globalRef = env.NewGlobalRef(localRef);
    refType = env.GetObjectRefType(globalRef);
    expect(refType, JObjectRefType.JNIGlobalRefType);
    env.DeleteGlobalRef(globalRef);
    env.DeleteWeakGlobalRef(weakRef);
    env.DeleteLocalRef(localRef);
    env.DeleteGlobalRef(systemOut);
    env.DeleteGlobalRef(systemClass);
  });
  testRunner('long methods return long int without loss of precision', () {
    using((arena) {
      final longClass = env.FindClass("java/lang/Long".toNativeChars(arena));
      final maxField = env.GetStaticFieldID(
        longClass,
        'MAX_VALUE'.toNativeChars(arena),
        'J'.toNativeChars(arena),
      );
      final maxValue = env.GetStaticLongField(longClass, maxField);
      expect(maxValue, equals(maxLongInJava));
      env.DeleteGlobalRef(longClass);
    });
  });

  testRunner('class <-> object methods', () {
    using((arena) {
      final systemClass =
          env.FindClass("java/lang/System".toNativeChars(arena));
      final outField = env.GetStaticFieldID(
          systemClass,
          "out".toNativeChars(arena),
          "Ljava/io/PrintStream;".toNativeChars(arena));
      final errField = env.GetStaticFieldID(
          systemClass,
          "err".toNativeChars(arena),
          "Ljava/io/PrintStream;".toNativeChars(arena));
      final systemOut = env.GetStaticObjectField(systemClass, outField);
      final systemErr = env.GetStaticObjectField(systemClass, errField);
      final outClass = env.GetObjectClass(systemOut);
      expect(env.IsInstanceOf(systemOut, outClass), isTrue);
      expect(env.IsInstanceOf(systemErr, outClass), isTrue);
      final errClass = env.GetObjectClass(systemErr);
      expect(env.IsSameObject(outClass, errClass), isTrue);
      env.DeleteGlobalRef(systemClass);
      env.DeleteGlobalRef(systemOut);
      env.DeleteGlobalRef(systemErr);
      env.DeleteGlobalRef(outClass);
      env.DeleteGlobalRef(errClass);
    });
  });
}
