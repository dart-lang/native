// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart' show internal;

import 'jni.dart';
import 'jobject.dart';
import 'jreference.dart';
import 'jvalues.dart';
import 'third_party/generated_bindings.dart';

part 'jclass.dart';
part 'jprimitives.dart';

@internal
sealed class JTypeBase<JavaT> {
  const JTypeBase();

  String get signature;
}

/// Able to be a return type of a method that can be called.
mixin JCallable<JavaT, DartT> on JTypeBase<JavaT> {
  DartT _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args);
  DartT _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args);
}

/// Able to be the type of a field that can be get and set.
mixin JAccessible<JavaT, DartT> on JTypeBase<JavaT> {
  DartT _staticGet(JClassPtr clazz, JFieldIDPtr fieldID);
  DartT _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID);
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, DartT val);
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, DartT val);
}

class JType<T extends JObject?> extends JTypeBase<T>
    with JCallable<T, T>, JAccessible<T, T> {
  @internal
  const JType();

  JClass get jClass {
    return JClass.forName(signature);
  }

  @override
  T _staticCall(JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    final result = Jni.env.CallStaticObjectMethodA(clazz, methodID, args);
    return JObject.fromReference(JGlobalReference(result)) as T;
  }

  @override
  T _instanceCall(JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return JObject.fromReference(
        JGlobalReference(Jni.env.CallObjectMethodA(obj, methodID, args))) as T;
  }

  @override
  T _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return JObject.fromReference(
        JGlobalReference(Jni.env.GetObjectField(obj, fieldID))) as T;
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, T? val) {
    final valRef = val?.reference ?? jNullReference;
    Jni.env.SetObjectField(obj, fieldID, valRef.pointer);
  }

  @override
  T _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return JObject.fromReference(
        JGlobalReference(Jni.env.GetStaticObjectField(clazz, fieldID))) as T;
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, T? val) {
    final valRef = val?.reference ?? jNullReference;
    Jni.env.SetStaticObjectField(clazz, fieldID, valRef.pointer);
  }
}

typedef $JObject$Type$ = JType<JObject>;
