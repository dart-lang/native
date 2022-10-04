// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';
import 'package:ffi/ffi.dart' show using;

import 'package:jni/src/jvalues.dart';

import 'third_party/jni_bindings_generated.dart';
import 'jni.dart';
import 'env_extensions.dart';

Pointer<GlobalJniEnv> env = Jni.env;

void _check(JThrowable exception) {
  if (exception != nullptr) {
    env.throwException(exception);
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

  JObject get object {
    check();
    return result.l;
  }

  bool get boolean {
    check();
    return result.z != 0;
  }
}

extension JniIdLookupResultMethods on JniPointerResult {
  JMethodID get methodID {
    _check(exception);
    return id.cast<jmethodID_>();
  }

  JFieldID get fieldID {
    _check(exception);
    return id.cast<jfieldID_>();
  }
}

extension JniClassLookupResultMethods on JniClassLookupResult {
  JClass get checkedClassRef {
    _check(exception);
    return classRef;
  }
}

extension JniAccessorWrappers on Pointer<JniAccessors> {
  // TODO(PR): How to name these methods? These only wrap toNativeChars()
  // so that generated bindings are less verbose.
  JClass getClassOf(String internalName) =>
      using((arena) => getClass(internalName.toNativeChars(arena)))
          .checkedClassRef;

  JMethodID getMethodIDOf(JClass cls, String name, String signature) =>
      using((arena) => getMethodID(
              cls, name.toNativeChars(arena), signature.toNativeChars(arena)))
          .methodID;

  JMethodID getStaticMethodIDOf(JClass cls, String name, String signature) =>
      using((arena) => getStaticMethodID(
              cls, name.toNativeChars(arena), signature.toNativeChars(arena)))
          .methodID;

  JFieldID getFieldIDOf(JClass cls, String name, String signature) =>
      using((arena) => getFieldID(
              cls, name.toNativeChars(arena), signature.toNativeChars(arena)))
          .fieldID;

  JFieldID getStaticFieldIDOf(JClass cls, String name, String signature) =>
      using((arena) => getStaticFieldID(
              cls, name.toNativeChars(arena), signature.toNativeChars(arena)))
          .fieldID;

  JniResult newObjectWithArgs(JClass cls, JMethodID ctor, List<dynamic> args) =>
      using((arena) {
        return newObject(cls, ctor, toJValues(args, allocator: arena));
      });

  JniResult callMethodWithArgs(
          JObject obj, JMethodID id, int callType, List<dynamic> args) =>
      using((arena) =>
          callMethod(obj, id, callType, toJValues(args, allocator: arena)));

  JniResult callStaticMethodWithArgs(
          JClass cls, JMethodID id, int callType, List<dynamic> args) =>
      using((arena) => callStaticMethod(
          cls, id, callType, toJValues(args, allocator: arena)));
}
