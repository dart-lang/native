// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// The types here are mapped to primitive types in Java, so they're all in
// lowercase.
// ignore_for_file: camel_case_types

part of 'types.dart';

abstract final class JPrimitive {}

abstract final class jbyte extends JPrimitive {
  static const type = jbyteType();
}

final class jbyteType extends JType<jbyte>
    with JCallable<jbyte, int>, JAccessible<jbyte, int> {
  const jbyteType();

  @override
  final signature = 'B';

  @override
  int _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallStaticByteMethodA(clazz, methodID, args);
  }

  @override
  int _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallByteMethodA(obj, methodID, args);
  }

  @override
  int _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return Jni.env.GetByteField(obj, fieldID);
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, int val) {
    Jni.env.SetByteField(obj, fieldID, val);
  }

  @override
  int _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return Jni.env.GetStaticByteField(clazz, fieldID);
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, int val) {
    return Jni.env.SetStaticByteField(clazz, fieldID, val);
  }
}

abstract final class jboolean extends JPrimitive {
  static const type = jbooleanType();
}

final class jbooleanType extends JType<jboolean>
    with JCallable<jboolean, bool>, JAccessible<jboolean, bool> {
  const jbooleanType();

  @override
  final signature = 'Z';

  @override
  bool _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallStaticBooleanMethodA(clazz, methodID, args);
  }

  @override
  bool _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallBooleanMethodA(obj, methodID, args);
  }

  @override
  bool _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return Jni.env.GetBooleanField(obj, fieldID);
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, bool val) {
    Jni.env.SetBooleanField(obj, fieldID, val ? 1 : 0);
  }

  @override
  bool _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return Jni.env.GetStaticBooleanField(clazz, fieldID);
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, bool val) {
    return Jni.env.SetStaticBooleanField(clazz, fieldID, val ? 1 : 0);
  }
}

abstract final class jchar extends JPrimitive {
  static const type = jcharType();
}

final class jcharType extends JType<jchar>
    with JCallable<jchar, int>, JAccessible<jchar, int> {
  const jcharType();

  @override
  final signature = 'C';

  @override
  int _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallStaticCharMethodA(clazz, methodID, args);
  }

  @override
  int _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallCharMethodA(obj, methodID, args);
  }

  @override
  int _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return Jni.env.GetCharField(obj, fieldID);
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, int val) {
    Jni.env.SetCharField(obj, fieldID, val);
  }

  @override
  int _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return Jni.env.GetStaticCharField(clazz, fieldID);
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, int val) {
    return Jni.env.SetStaticCharField(clazz, fieldID, val);
  }
}

abstract final class jshort extends JPrimitive {
  static const type = jshortType();
}

final class jshortType extends JType<jshort>
    with JCallable<jshort, int>, JAccessible<jshort, int> {
  const jshortType();

  @override
  final signature = 'S';

  @override
  int _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallStaticShortMethodA(clazz, methodID, args);
  }

  @override
  int _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallShortMethodA(obj, methodID, args);
  }

  @override
  int _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return Jni.env.GetShortField(obj, fieldID);
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, int val) {
    Jni.env.SetShortField(obj, fieldID, val);
  }

  @override
  int _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return Jni.env.GetStaticShortField(clazz, fieldID);
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, int val) {
    return Jni.env.SetStaticShortField(clazz, fieldID, val);
  }
}

abstract final class jint extends JPrimitive {
  static const type = jintType();
}

final class jintType extends JType<jint>
    with JCallable<jint, int>, JAccessible<jint, int> {
  const jintType();

  @override
  final signature = 'I';

  @override
  int _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallStaticIntMethodA(clazz, methodID, args);
  }

  @override
  int _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallIntMethodA(obj, methodID, args);
  }

  @override
  int _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return Jni.env.GetIntField(obj, fieldID);
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, int val) {
    Jni.env.SetIntField(obj, fieldID, val);
  }

  @override
  int _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return Jni.env.GetStaticIntField(clazz, fieldID);
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, int val) {
    return Jni.env.SetStaticIntField(clazz, fieldID, val);
  }
}

abstract final class jlong extends JPrimitive {
  static const type = jlongType();
}

final class jlongType extends JType<jlong>
    with JCallable<jlong, int>, JAccessible<jlong, int> {
  const jlongType();

  @override
  final signature = 'J';

  @override
  int _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallStaticLongMethodA(clazz, methodID, args);
  }

  @override
  int _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallLongMethodA(obj, methodID, args);
  }

  @override
  int _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return Jni.env.GetLongField(obj, fieldID);
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, int val) {
    Jni.env.SetLongField(obj, fieldID, val);
  }

  @override
  int _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return Jni.env.GetStaticLongField(clazz, fieldID);
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, int val) {
    return Jni.env.SetStaticLongField(clazz, fieldID, val);
  }
}

abstract final class jfloat extends JPrimitive {
  static const type = jfloatType();
}

final class jfloatType extends JType<jfloat>
    with JCallable<jfloat, double>, JAccessible<jfloat, double> {
  const jfloatType();

  @override
  final signature = 'F';

  @override
  double _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallStaticFloatMethodA(clazz, methodID, args);
  }

  @override
  double _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallFloatMethodA(obj, methodID, args);
  }

  @override
  double _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return Jni.env.GetFloatField(obj, fieldID);
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, double val) {
    Jni.env.SetFloatField(obj, fieldID, val);
  }

  @override
  double _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return Jni.env.GetStaticFloatField(clazz, fieldID);
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, double val) {
    return Jni.env.SetStaticFloatField(clazz, fieldID, val);
  }
}

abstract final class jdouble extends JPrimitive {
  static const type = jdoubleType();
}

final class jdoubleType extends JType<jdouble>
    with JCallable<jdouble, double>, JAccessible<jdouble, double> {
  const jdoubleType();

  @override
  final signature = 'D';

  @override
  double _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallStaticDoubleMethodA(clazz, methodID, args);
  }

  @override
  double _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallDoubleMethodA(obj, methodID, args);
  }

  @override
  double _instanceGet(JObjectPtr obj, JFieldIDPtr fieldID) {
    return Jni.env.GetDoubleField(obj, fieldID);
  }

  @override
  void _instanceSet(JObjectPtr obj, JFieldIDPtr fieldID, double val) {
    Jni.env.SetDoubleField(obj, fieldID, val);
  }

  @override
  double _staticGet(JClassPtr clazz, JFieldIDPtr fieldID) {
    return Jni.env.GetStaticDoubleField(clazz, fieldID);
  }

  @override
  void _staticSet(JClassPtr clazz, JFieldIDPtr fieldID, double val) {
    return Jni.env.SetStaticDoubleField(clazz, fieldID, val);
  }
}

abstract final class jvoid extends JPrimitive {
  static const type = jdoubleType();
}

final class jvoidType extends JType<jvoid> with JCallable<jvoid, void> {
  const jvoidType();

  @override
  final signature = 'V';

  @override
  void _staticCall(
      JClassPtr clazz, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallStaticVoidMethodA(clazz, methodID, args);
  }

  @override
  void _instanceCall(
      JObjectPtr obj, JMethodIDPtr methodID, Pointer<JValue> args) {
    return Jni.env.CallVoidMethodA(obj, methodID, args);
  }
}
