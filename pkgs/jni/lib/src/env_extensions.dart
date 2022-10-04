// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'third_party/jni_bindings_generated.dart';

import 'jni_exceptions.dart';

extension AdditionalEnvMethods on Pointer<GlobalJniEnv> {
  /// Convenience method for converting a [JString]
  /// to dart string.
  /// if [deleteOriginal] is specified, jstring passed will be deleted using
  /// DeleteLocalRef.
  String asDartString(JString jstring, {bool deleteOriginal = false}) {
    final chars = GetStringUTFChars(jstring, nullptr);
    if (chars == nullptr) {
      checkException();
    }
    final result = chars.cast<Utf8>().toDartString();
    ReleaseStringUTFChars(jstring, chars);
    if (deleteOriginal) {
      DeleteGlobalRef(jstring);
    }
    return result;
  }

  /// Return a new [JString] from contents of [s].
  JString asJString(String s) => using((arena) {
        final utf = s.toNativeUtf8().cast<Char>();
        final result = NewStringUTF(utf);
        malloc.free(utf);
        return result;
      });

  /// Deletes all references in [refs].
  void deleteAllRefs(List<JObject> refs) {
    for (final ref in refs) {
      DeleteGlobalRef(ref);
    }
  }

  /// If any exception is pending in JNI, throw it in Dart.
  ///
  /// If [describe] is true, a description is printed to screen.
  /// To access actual exception object, use `ExceptionOccurred`.
  ///
  /// TODO(#64): Do not keep reference to exception, store stack trace & error.
  void checkException({bool describe = false}) {
    final exc = ExceptionOccurred();
    throwException(exc);
  }

  /// Throw [exception] from JNI in Dart as a [JniException].
  void throwException(JObject exception, {bool describe = false}) {
    if (exception == nullptr) {
      return;
    }
    final exceptionClass = GetObjectClass(exception);
    final toStringMethod = GetMethodID(exceptionClass, _toString, _toStringSig);
    final javaDescription = CallObjectMethod(exception, toStringMethod);
    final dartDescription = asDartString(javaDescription);
    DeleteGlobalRef(javaDescription);
    DeleteGlobalRef(exceptionClass);
    throw JniException(exception, dartDescription);
  }

  /// Calls the printStackTrace on exception object
  /// obtained by java
  void printStackTrace(JniException je) {
    final ecls = GetObjectClass(je.err);
    final printStackTrace =
        GetMethodID(ecls, _printStackTrace, _printStackTraceSig);
    CallVoidMethod(je.err, printStackTrace);
    DeleteGlobalRef(ecls);
  }
}

extension StringMethodsForJni on String {
  /// Returns a Utf-8 encoded Pointer<Char> with contents same as this string.
  Pointer<Char> toNativeChars([Allocator allocator = malloc]) {
    return toNativeUtf8(allocator: allocator).cast<Char>();
  }
}

extension CharPtrMethodsForJni on Pointer<Char> {
  /// Same as calling `cast<Utf8>` followed by `toDartString`.
  String toDartString() {
    return cast<Utf8>().toDartString();
  }
}

final _toString = "toString".toNativeChars();
final _toStringSig = "()Ljava/lang/String;".toNativeChars();
final _printStackTrace = "printStackTrace".toNativeChars();
final _printStackTraceSig = "()V".toNativeChars();
