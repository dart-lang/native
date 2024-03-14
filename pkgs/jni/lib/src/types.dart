// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:jni/internal_helpers_for_jnigen.dart';

import 'jni.dart';
import 'jobject.dart';
import 'jvalues.dart';
import 'third_party/generated_bindings.dart';

part 'jclass.dart';
part 'jprimitives.dart';

sealed class JType<JavaT> {
  const JType();

  String get signature;
}

/// Able to be a return type of a method that can be called.
mixin JCallable<JavaT, DartT> on JType<JavaT> {
  DartT _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args);
  DartT _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args);
}

/// Able to be constructed.
mixin JConstructable<JavaT, DartT> on JType<JavaT> {
  DartT _newObject(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args);
}

/// Able to be the type of a field that can be get and set.s
mixin JAccessible<JavaT, DartT> on JType<JavaT> {
  DartT _staticGet(JClassPtr clazz, JFieldIDPtr fieldID);
  DartT _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID);
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, DartT val);
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, DartT val);
}

/// Only used for jnigen.
///
/// Makes constructing objects easier inside the generated bindings by allowing
/// a [JReference] to be created. This allows [JObject]s to use constructors
/// that call `super.fromReference` instead of factories.
const referenceType = _ReferenceType();

final class _ReferenceType extends JType<JReference>
    with JConstructable<JReference, JReference> {
  const _ReferenceType();

  @override
  JReference _newObject(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return JGlobalReference(Jni.env.NewObjectA(clazz, methodID, args));
  }

  @override
  String get signature => 'Ljava/lang/Object;';
}

abstract class JObjType<T extends JObject> extends JType<T>
    with JCallable<T, T>, JConstructable<T, T>, JAccessible<T, T> {
  /// Number of super types. Distance to the root type.
  int get superCount;

  JObjType get superType;

  const JObjType();

  /// Creates an object from this type using the reference.
  T fromReference(JReference reference);

  JClass get jClass {
    if (signature.startsWith('L') && signature.endsWith(';')) {
      return JClass.forName(signature.substring(1, signature.length - 1));
    }
    return JClass.forName(signature);
  }

  @override
  T _staticCall(JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return fromReference(JGlobalReference(
        Jni.env.CallStaticObjectMethodA(clazz, methodID, args)));
  }

  @override
  T _instanceCall(JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return fromReference(
        JGlobalReference(Jni.env.CallObjectMethodA(obj, methodID, args)));
  }

  @override
  T _newObject(JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return fromReference(
        JGlobalReference(Jni.env.NewObjectA(clazz, methodID, args)));
  }

  @override
  T _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return fromReference(
        JGlobalReference(Jni.env.GetObjectField(obj, fieldID)));
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, T val) {
    Jni.env.SetObjectField(obj, fieldID, val.reference.pointer);
  }

  @override
  T _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return fromReference(
        JGlobalReference(Jni.env.GetStaticObjectField(clazz, fieldID)));
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, T val) {
    Jni.env.SetStaticObjectField(clazz, fieldID, val.reference.pointer);
  }
}

/// Lowest common ancestor of two types in the inheritance tree.
JObjType _lowestCommonAncestor(JObjType a, JObjType b) {
  while (a.superCount > b.superCount) {
    a = a.superType;
  }
  while (b.superCount > a.superCount) {
    b = b.superType;
  }
  while (a != b) {
    a = a.superType;
    b = b.superType;
  }
  return a;
}

JObjType lowestCommonSuperType(List<JObjType> types) {
  return types.reduce(_lowestCommonAncestor);
}
