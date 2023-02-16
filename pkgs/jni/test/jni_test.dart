// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:jni/jni.dart';
import 'package:test/test.dart';

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
    try {
      Jni.spawn(dylibDir: "build/jni_libs", jvmOptions: ["-Xmx128m"]);
    } on JvmExistsException catch (_) {
      // TODO(#51): Support destroying and reinstantiating JVM.
    }
  }

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

  test('initDLApi', () {
    Jni.initDLApi();
  });

  test('get JNI Version', () {
    expect(Jni.env.GetVersion(), isNot(equals(0)));
  });

  test(
      'Manually lookup & call Long.toHexString',
      () => using((arena) {
            // Method names on JniEnv* from C JNI API are capitalized
            // like in original, while other extension methods
            // follow Dart naming conventions.
            final longClass =
                env.FindClass("java/lang/Long".toNativeChars(arena));
            // Refer JNI spec on how to construct method signatures
            // Passing wrong signature leads to a segfault
            final hexMethod = env.GetStaticMethodID(
                longClass,
                "toHexString".toNativeChars(arena),
                "(J)Ljava/lang/String;".toNativeChars(arena));

            for (var i in [1, 80, 13, 76, 1134453224145]) {
              // if your argument is int, bool, or JObject (`Pointer<Void>`)
              // it can be directly placed in the list. To convert into different primitive
              // types, use JValue<Type> wrappers.
              final jres = env.CallStaticObjectMethodA(longClass, hexMethod,
                  Jni.jvalues([JValueLong(i)], allocator: arena));

              // use asDartString extension method on Pointer<JniEnv>
              // to convert a String jobject result to string
              final res = env.asDartString(jres);
              expect(res, equals(i.toRadixString(16)));

              // Any object or class result from java is a local reference
              // and needs to be deleted explicitly.
              // Note that method and field IDs aren't local references.
              // But they are valid only until a reference to corresponding
              // java class exists.
              env.DeleteGlobalRef(jres);
            }
            env.DeleteGlobalRef(longClass);
          }));

  test("asJString extension method", () {
    const str = "QWERTY QWERTY";
    // convenience method that wraps
    // converting dart string to native string,
    // instantiating java string, and freeing the native string
    final jstr = env.asJString(str);
    expect(str, equals(env.asDartString(jstr)));
    env.DeleteGlobalRef(jstr);
  });

  test(
      "Convert back & forth between Dart & Java strings",
      () => using((arena) {
            const str = "ABCD EFGH";
            // This is what asJString and asDartString do internally
            final jstr = env.NewStringUTF(str.toNativeChars(arena));
            final jchars = env.GetStringUTFChars(jstr, nullptr);
            final dstr = jchars.toDartString();
            env.ReleaseStringUTFChars(jstr, jchars);
            expect(str, equals(dstr));
            env.DeleteGlobalRef(jstr);
          }));

  test(
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
            final jstr = env.asJString(str);
            env.CallVoidMethodA(out, println, Jni.jvalues([jstr]));
            env.deleteAllRefs([system, printStream, jstr]);
          }));
}
