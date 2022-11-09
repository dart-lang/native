// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:ffi/ffi.dart' show using;

import 'package:jni/src/jvalues.dart';

import 'third_party/jni_bindings_generated.dart';
import 'jni.dart';
import 'types.dart';

void _check(JThrowablePtr exception) {
  if (exception != nullptr) {
    Jni.accessors.throwException(exception);
  }
}

extension JniResultMethods on JniResult {
  void check() => _check(exception);

  int get byte {
    check();
    return result.b;
  }

  int get short {
    check();
    return result.s;
  }

  int get char {
    check();
    return result.c;
  }

  int get integer {
    check();
    return result.i;
  }

  int get long {
    check();
    return result.j;
  }

  double get float {
    check();
    return result.f;
  }

  double get doubleFloat {
    check();
    return result.d;
  }

  JObjectPtr get object {
    check();
    return result.l;
  }

  bool get boolean {
    check();
    return result.z != 0;
  }
}

extension JniIdLookupResultMethods on JniPointerResult {
  JMethodIDPtr get methodID {
    _check(exception);
    return id.cast<jmethodID_>();
  }

  JFieldIDPtr get fieldID {
    _check(exception);
    return id.cast<jfieldID_>();
  }

  Pointer<Void> get checkedRef {
    _check(exception);
    return id;
  }
}

extension JniClassLookupResultMethods on JniClassLookupResult {
  JClassPtr get checkedClassRef {
    _check(exception);
    return classRef;
  }
}

extension JniAccessorWrappers on Pointer<JniAccessors> {
  /// Rethrows Java exception in Dart as [JniException].
  ///
  /// The original exception object is deleted by this method. The message
  /// and Java stack trace are included in the exception.
  void throwException(JThrowablePtr exception) {
    final details = getExceptionDetails(exception);
    final env = Jni.env;
    final message = env.asDartString(details.message);
    final stacktrace = env.asDartString(details.stacktrace);
    env.DeleteGlobalRef(exception);
    env.DeleteGlobalRef(details.message);
    env.DeleteGlobalRef(details.stacktrace);
    throw JniException(message, stacktrace);
  }

  // TODO(PR): How to name these methods? These only wrap toNativeChars()
  // so that generated bindings are less verbose.
  JClassPtr getClassOf(String internalName) =>
      using((arena) => getClass(internalName.toNativeChars(arena)))
          .checkedClassRef;

  JMethodIDPtr getMethodIDOf(JClassPtr cls, String name, String signature) =>
      using((arena) => getMethodID(
              cls, name.toNativeChars(arena), signature.toNativeChars(arena)))
          .methodID;

  JMethodIDPtr getStaticMethodIDOf(
          JClassPtr cls, String name, String signature) =>
      using((arena) => getStaticMethodID(
              cls, name.toNativeChars(arena), signature.toNativeChars(arena)))
          .methodID;

  JFieldIDPtr getFieldIDOf(JClassPtr cls, String name, String signature) =>
      using((arena) => getFieldID(
              cls, name.toNativeChars(arena), signature.toNativeChars(arena)))
          .fieldID;

  JFieldIDPtr getStaticFieldIDOf(
          JClassPtr cls, String name, String signature) =>
      using((arena) => getStaticFieldID(
              cls, name.toNativeChars(arena), signature.toNativeChars(arena)))
          .fieldID;

  JniResult newObjectWithArgs(
          JClassPtr cls, JMethodIDPtr ctor, List<dynamic> args) =>
      using((arena) {
        return newObject(cls, ctor, toJValues(args, allocator: arena));
      });

  JniResult callMethodWithArgs(
          JObjectPtr obj, JMethodIDPtr id, int callType, List<dynamic> args) =>
      using((arena) =>
          callMethod(obj, id, callType, toJValues(args, allocator: arena)));

  JniResult callStaticMethodWithArgs(
          JClassPtr cls, JMethodIDPtr id, int callType, List<dynamic> args) =>
      using((arena) => callStaticMethod(
          cls, id, callType, toJValues(args, allocator: arena)));
}
