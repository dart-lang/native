// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:ffi';

import 'package:test/test.dart';
import 'package:ffi/ffi.dart';
import 'package:jni/jni.dart';

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
    Jni.spawn(helperDir: "build/jni_libs");
  }

  final jni = Jni.getInstance();

  test('get JNI Version', () {
    // get a dart binding of JNIEnv object
    // It's a thin wrapper over C's JNIEnv*, and provides
    // all methods of it (without need to pass the first self parameter),
    // plus few extension methods to make working in dart easier.
    final env = jni.getEnv();
    expect(env.GetVersion(), isNot(equals(0)));
  });

  test('Manually lookup & call Long.toHexString static method', () {
    // create an arena for allocating anything native
    // it's convenient way to release all natively allocated strings
    // and values at once.
    final arena = Arena();
    final env = jni.getEnv();

    // Method names on JniEnv* from C JNI API are capitalized
    // like in original, while other extension methods
    // follow Dart naming conventions.
    final longClass = env.FindClass("java/lang/Long".toNativeChars(arena));
    // Refer JNI spec on how to construct method signatures
    // Passing wrong signature leads to a segfault
    final hexMethod = env.GetStaticMethodID(
        longClass,
        "toHexString".toNativeChars(arena),
        "(J)Ljava/lang/String;".toNativeChars(arena));

    for (var i in [1, 80, 13, 76, 1134453224145]) {
      // Use Jni.jvalues method to easily construct native argument arrays
      // if your argument is int, bool, or JObject (`Pointer<Void>`)
      // it can be directly placed in the list. To convert into different primitive
      // types, use JValue<Type> wrappers.
      final jres = env.CallStaticObjectMethodA(
          longClass, hexMethod, Jni.jvalues([JValueLong(i)], allocator: arena));

      // use asDartString extension method on Pointer<JniEnv>
      // to convert a String jobject result to string
      final res = env.asDartString(jres);
      expect(res, equals(i.toRadixString(16)));

      // Any object or class result from java is a local reference
      // and needs to be deleted explicitly.
      // Note that method and field IDs aren't local references.
      // But they are valid only until a reference to corresponding
      // java class exists.
      env.DeleteLocalRef(jres);
    }
    env.DeleteLocalRef(longClass);
    arena.releaseAll();
  });

  test("asJString extension method", () {
    final env = jni.getEnv();
    const str = "QWERTY QWERTY";
    // convenience method that wraps
    // converting dart string to native string,
    // instantiating java string, and freeing the native string
    final jstr = env.asJString(str);
    expect(str, equals(env.asDartString(jstr)));
    env.DeleteLocalRef(jstr);
  });

  test("Convert back and forth between dart and java string", () {
    final arena = Arena();
    final env = jni.getEnv();
    const str = "ABCD EFGH";
    // This is what asJString and asDartString do internally
    final jstr = env.NewStringUTF(str.toNativeChars(arena));
    final jchars = env.GetStringUTFChars(jstr, nullptr);
    final dstr = jchars.toDartString();
    env.ReleaseStringUTFChars(jstr, jchars);
    expect(str, equals(dstr));

    // delete multiple local references using this method
    env.deleteAllLocalRefs([jstr]);
    arena.releaseAll();
  });

  test("Print something from Java", () {
    final arena = Arena();
    final env = jni.getEnv();
    final system = env.FindClass("java/lang/System".toNativeChars(arena));
    final field = env.GetStaticFieldID(system, "out".toNativeChars(arena),
        "Ljava/io/PrintStream;".toNativeChars(arena));
    final out = env.GetStaticObjectField(system, field);
    final printStream = env.GetObjectClass(out);
    /*
    final println = env.GetMethodID(printStream, "println".toNativeChars(arena),
        "(Ljava/lang/String;)V".toNativeChars(arena));
	*/
    const str = "\nHello JNI!";
    final jstr = env.asJString(str);
    // test runner can't compare what's printed by Java, leaving it
    // env.CallVoidMethodA(out, println, Jni.jvalues([jstr]));
    env.deleteAllLocalRefs([system, printStream, jstr]);
    arena.releaseAll();
  });
}
