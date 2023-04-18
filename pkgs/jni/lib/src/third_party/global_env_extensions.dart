// Auto generated file. Do not edit.

// This is generated from JNI header in Android NDK. License for the same is
// provided below.

/*
 * Copyright (C) 2006 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * JNI specification, as defined by Sun:
 * http://java.sun.com/javase/6/docs/technotes/guides/jni/spec/jniTOC.html
 *
 * Everything here is expected to be VM-neutral.
 */

// ignore_for_file: non_constant_identifier_names
// coverage:ignore-file

import "dart:ffi" as ffi;

import "jni_bindings_generated.dart";

import "../accessors.dart";

extension EnvExtension on ffi.Pointer<GlobalJniEnv> {
  int GetVersion() =>
      ref.GetVersion.asFunction<JniResult Function()>()().integer;

  JClassPtr DefineClass(ffi.Pointer<ffi.Char> name, JObjectPtr loader,
          ffi.Pointer<JByteMarker> buf, int bufLen) =>
      ref.DefineClass.asFunction<
              JniClassLookupResult Function(
                  ffi.Pointer<ffi.Char> name,
                  JObjectPtr loader,
                  ffi.Pointer<JByteMarker> buf,
                  int bufLen)>()(name, loader, buf, bufLen)
          .value;

  JClassPtr FindClass(ffi.Pointer<ffi.Char> name) => ref.FindClass.asFunction<
          JniClassLookupResult Function(ffi.Pointer<ffi.Char> name)>()(name)
      .value;

  JMethodIDPtr FromReflectedMethod(JObjectPtr method) => ref.FromReflectedMethod
          .asFunction<JniPointerResult Function(JObjectPtr method)>()(method)
      .methodID;

  JFieldIDPtr FromReflectedField(JObjectPtr field) => ref.FromReflectedField
          .asFunction<JniPointerResult Function(JObjectPtr field)>()(field)
      .fieldID;

  JObjectPtr ToReflectedMethod(
          JClassPtr cls, JMethodIDPtr methodId, int isStatic) =>
      ref.ToReflectedMethod.asFunction<
              JniResult Function(JClassPtr cls, JMethodIDPtr methodId,
                  int isStatic)>()(cls, methodId, isStatic)
          .object;

  JClassPtr GetSuperclass(JClassPtr clazz) => ref.GetSuperclass.asFunction<
          JniClassLookupResult Function(JClassPtr clazz)>()(clazz)
      .value;

  bool IsAssignableFrom(JClassPtr clazz1, JClassPtr clazz2) =>
      ref.IsAssignableFrom.asFunction<
              JniResult Function(
                  JClassPtr clazz1, JClassPtr clazz2)>()(clazz1, clazz2)
          .boolean;

  JObjectPtr ToReflectedField(
          JClassPtr cls, JFieldIDPtr fieldID, int isStatic) =>
      ref.ToReflectedField.asFunction<
              JniResult Function(JClassPtr cls, JFieldIDPtr fieldID,
                  int isStatic)>()(cls, fieldID, isStatic)
          .object;

  int Throw(JThrowablePtr obj) =>
      ref.Throw.asFunction<JniResult Function(JThrowablePtr obj)>()(obj)
          .integer;

  int ThrowNew(JClassPtr clazz, ffi.Pointer<ffi.Char> message) =>
      ref.ThrowNew.asFunction<
              JniResult Function(JClassPtr clazz,
                  ffi.Pointer<ffi.Char> message)>()(clazz, message)
          .integer;

  JThrowablePtr ExceptionOccurred() =>
      ref.ExceptionOccurred.asFunction<JniResult Function()>()().object;

  void ExceptionDescribe() =>
      ref.ExceptionDescribe.asFunction<JThrowablePtr Function()>()().check();

  void ExceptionClear() =>
      ref.ExceptionClear.asFunction<JThrowablePtr Function()>()().check();

  void FatalError(ffi.Pointer<ffi.Char> msg) => ref.FatalError.asFunction<
          JThrowablePtr Function(ffi.Pointer<ffi.Char> msg)>()(msg)
      .check();

  int PushLocalFrame(int capacity) =>
      ref.PushLocalFrame.asFunction<JniResult Function(int capacity)>()(
              capacity)
          .integer;

  JObjectPtr PopLocalFrame(JObjectPtr result) =>
      ref.PopLocalFrame.asFunction<JniResult Function(JObjectPtr result)>()(
              result)
          .object;

  JObjectPtr NewGlobalRef(JObjectPtr obj) =>
      ref.NewGlobalRef.asFunction<JniResult Function(JObjectPtr obj)>()(obj)
          .object;

  void DeleteGlobalRef(JObjectPtr globalRef) => ref.DeleteGlobalRef.asFunction<
          JThrowablePtr Function(JObjectPtr globalRef)>()(globalRef)
      .check();

  void DeleteLocalRef(JObjectPtr localRef) => ref.DeleteLocalRef.asFunction<
          JThrowablePtr Function(JObjectPtr localRef)>()(localRef)
      .check();

  bool IsSameObject(JObjectPtr ref1, JObjectPtr ref2) =>
      ref.IsSameObject.asFunction<
              JniResult Function(
                  JObjectPtr ref1, JObjectPtr ref2)>()(ref1, ref2)
          .boolean;

  JObjectPtr NewLocalRef(JObjectPtr obj) =>
      ref.NewLocalRef.asFunction<JniResult Function(JObjectPtr obj)>()(obj)
          .object;

  int EnsureLocalCapacity(int capacity) =>
      ref.EnsureLocalCapacity.asFunction<JniResult Function(int capacity)>()(
              capacity)
          .integer;

  JObjectPtr AllocObject(JClassPtr clazz) =>
      ref.AllocObject.asFunction<JniResult Function(JClassPtr clazz)>()(clazz)
          .object;

  JObjectPtr NewObject(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.NewObject.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .object;

  JObjectPtr NewObjectA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.NewObjectA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .object;

  JClassPtr GetObjectClass(JObjectPtr obj) => ref.GetObjectClass.asFunction<
          JniClassLookupResult Function(JObjectPtr obj)>()(obj)
      .value;

  bool IsInstanceOf(JObjectPtr obj, JClassPtr clazz) =>
      ref.IsInstanceOf.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz)>()(obj, clazz)
          .boolean;

  JMethodIDPtr GetMethodID(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig) =>
      ref.GetMethodID.asFunction<
              JniPointerResult Function(
                  JClassPtr clazz,
                  ffi.Pointer<ffi.Char> name,
                  ffi.Pointer<ffi.Char> sig)>()(clazz, name, sig)
          .methodID;

  JObjectPtr CallObjectMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallObjectMethod.asFunction<
              JniResult Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .object;

  JObjectPtr CallObjectMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallObjectMethodA.asFunction<
              JniResult Function(JObjectPtr obj, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, methodID, args)
          .object;

  bool CallBooleanMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallBooleanMethod.asFunction<
              JniResult Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .boolean;

  bool CallBooleanMethodA(
          JObjectPtr obj, JMethodIDPtr methodId, ffi.Pointer<JValue> args) =>
      ref.CallBooleanMethodA.asFunction<
              JniResult Function(JObjectPtr obj, JMethodIDPtr methodId,
                  ffi.Pointer<JValue> args)>()(obj, methodId, args)
          .boolean;

  int CallByteMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallByteMethod.asFunction<
              JniResult Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .byte;

  int CallByteMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallByteMethodA.asFunction<
              JniResult Function(JObjectPtr obj, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, methodID, args)
          .byte;

  int CallCharMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallCharMethod.asFunction<
              JniResult Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .char;

  int CallCharMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallCharMethodA.asFunction<
              JniResult Function(JObjectPtr obj, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, methodID, args)
          .char;

  int CallShortMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallShortMethod.asFunction<
              JniResult Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .short;

  int CallShortMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallShortMethodA.asFunction<
              JniResult Function(JObjectPtr obj, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, methodID, args)
          .short;

  int CallIntMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallIntMethod.asFunction<
              JniResult Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .integer;

  int CallIntMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallIntMethodA.asFunction<
              JniResult Function(JObjectPtr obj, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, methodID, args)
          .integer;

  int CallLongMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallLongMethod.asFunction<
              JniResult Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .long;

  int CallLongMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallLongMethodA.asFunction<
              JniResult Function(JObjectPtr obj, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, methodID, args)
          .long;

  double CallFloatMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallFloatMethod.asFunction<
              JniResult Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .float;

  double CallFloatMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallFloatMethodA.asFunction<
              JniResult Function(JObjectPtr obj, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, methodID, args)
          .float;

  double CallDoubleMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallDoubleMethod.asFunction<
              JniResult Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .doubleFloat;

  double CallDoubleMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallDoubleMethodA.asFunction<
              JniResult Function(JObjectPtr obj, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, methodID, args)
          .doubleFloat;

  void CallVoidMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      ref.CallVoidMethod.asFunction<
              JThrowablePtr Function(
                  JObjectPtr obj, JMethodIDPtr methodID)>()(obj, methodID)
          .check();

  void CallVoidMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallVoidMethodA.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, methodID, args)
          .check();

  JObjectPtr CallNonvirtualObjectMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualObjectMethod.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .object;

  JObjectPtr CallNonvirtualObjectMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualObjectMethodA.asFunction<
              JniResult Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .object;

  bool CallNonvirtualBooleanMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualBooleanMethod.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .boolean;

  bool CallNonvirtualBooleanMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualBooleanMethodA.asFunction<
              JniResult Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .boolean;

  int CallNonvirtualByteMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualByteMethod.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .byte;

  int CallNonvirtualByteMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualByteMethodA.asFunction<
              JniResult Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .byte;

  int CallNonvirtualCharMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualCharMethod.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .char;

  int CallNonvirtualCharMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualCharMethodA.asFunction<
              JniResult Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .char;

  int CallNonvirtualShortMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualShortMethod.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .short;

  int CallNonvirtualShortMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualShortMethodA.asFunction<
              JniResult Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .short;

  int CallNonvirtualIntMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualIntMethod.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .integer;

  int CallNonvirtualIntMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualIntMethodA.asFunction<
              JniResult Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .integer;

  int CallNonvirtualLongMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualLongMethod.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .long;

  int CallNonvirtualLongMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualLongMethodA.asFunction<
              JniResult Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .long;

  double CallNonvirtualFloatMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualFloatMethod.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .float;

  double CallNonvirtualFloatMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualFloatMethodA.asFunction<
              JniResult Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .float;

  double CallNonvirtualDoubleMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualDoubleMethod.asFunction<
              JniResult Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .doubleFloat;

  double CallNonvirtualDoubleMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualDoubleMethodA.asFunction<
              JniResult Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .doubleFloat;

  void CallNonvirtualVoidMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallNonvirtualVoidMethod.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JClassPtr clazz,
                  JMethodIDPtr methodID)>()(obj, clazz, methodID)
          .check();

  void CallNonvirtualVoidMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallNonvirtualVoidMethodA.asFunction<
              JThrowablePtr Function(
                  JObjectPtr obj,
                  JClassPtr clazz,
                  JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(obj, clazz, methodID, args)
          .check();

  JFieldIDPtr GetFieldID(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig) =>
      ref.GetFieldID.asFunction<
              JniPointerResult Function(
                  JClassPtr clazz,
                  ffi.Pointer<ffi.Char> name,
                  ffi.Pointer<ffi.Char> sig)>()(clazz, name, sig)
          .fieldID;

  JObjectPtr GetObjectField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      ref.GetObjectField.asFunction<
              JniResult Function(
                  JObjectPtr obj, JFieldIDPtr fieldID)>()(obj, fieldID)
          .object;

  bool GetBooleanField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      ref.GetBooleanField.asFunction<
              JniResult Function(
                  JObjectPtr obj, JFieldIDPtr fieldID)>()(obj, fieldID)
          .boolean;

  int GetByteField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      ref.GetByteField.asFunction<
              JniResult Function(
                  JObjectPtr obj, JFieldIDPtr fieldID)>()(obj, fieldID)
          .byte;

  int GetCharField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      ref.GetCharField.asFunction<
              JniResult Function(
                  JObjectPtr obj, JFieldIDPtr fieldID)>()(obj, fieldID)
          .char;

  int GetShortField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      ref.GetShortField.asFunction<
              JniResult Function(
                  JObjectPtr obj, JFieldIDPtr fieldID)>()(obj, fieldID)
          .short;

  int GetIntField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      ref.GetIntField.asFunction<
              JniResult Function(
                  JObjectPtr obj, JFieldIDPtr fieldID)>()(obj, fieldID)
          .integer;

  int GetLongField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      ref.GetLongField.asFunction<
              JniResult Function(
                  JObjectPtr obj, JFieldIDPtr fieldID)>()(obj, fieldID)
          .long;

  double GetFloatField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      ref.GetFloatField.asFunction<
              JniResult Function(
                  JObjectPtr obj, JFieldIDPtr fieldID)>()(obj, fieldID)
          .float;

  double GetDoubleField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      ref.GetDoubleField.asFunction<
              JniResult Function(
                  JObjectPtr obj, JFieldIDPtr fieldID)>()(obj, fieldID)
          .doubleFloat;

  void SetObjectField(JObjectPtr obj, JFieldIDPtr fieldID, JObjectPtr val) =>
      ref.SetObjectField.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
                  JObjectPtr val)>()(obj, fieldID, val)
          .check();

  void SetBooleanField(JObjectPtr obj, JFieldIDPtr fieldID, int val) =>
      ref.SetBooleanField.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
                  int val)>()(obj, fieldID, val)
          .check();

  void SetByteField(JObjectPtr obj, JFieldIDPtr fieldID, int val) =>
      ref.SetByteField.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
                  int val)>()(obj, fieldID, val)
          .check();

  void SetCharField(JObjectPtr obj, JFieldIDPtr fieldID, int val) =>
      ref.SetCharField.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
                  int val)>()(obj, fieldID, val)
          .check();

  void SetShortField(JObjectPtr obj, JFieldIDPtr fieldID, int val) =>
      ref.SetShortField.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
                  int val)>()(obj, fieldID, val)
          .check();

  void SetIntField(JObjectPtr obj, JFieldIDPtr fieldID, int val) =>
      ref.SetIntField.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
                  int val)>()(obj, fieldID, val)
          .check();

  void SetLongField(JObjectPtr obj, JFieldIDPtr fieldID, int val) =>
      ref.SetLongField.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
                  int val)>()(obj, fieldID, val)
          .check();

  void SetFloatField(JObjectPtr obj, JFieldIDPtr fieldID, double val) =>
      ref.SetFloatField.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
                  double val)>()(obj, fieldID, val)
          .check();

  void SetDoubleField(JObjectPtr obj, JFieldIDPtr fieldID, double val) =>
      ref.SetDoubleField.asFunction<
              JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
                  double val)>()(obj, fieldID, val)
          .check();

  JMethodIDPtr GetStaticMethodID(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig) =>
      ref.GetStaticMethodID.asFunction<
              JniPointerResult Function(
                  JClassPtr clazz,
                  ffi.Pointer<ffi.Char> name,
                  ffi.Pointer<ffi.Char> sig)>()(clazz, name, sig)
          .methodID;

  JObjectPtr CallStaticObjectMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticObjectMethod.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .object;

  JObjectPtr CallStaticObjectMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticObjectMethodA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .object;

  bool CallStaticBooleanMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticBooleanMethod.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .boolean;

  bool CallStaticBooleanMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticBooleanMethodA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .boolean;

  int CallStaticByteMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticByteMethod.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .byte;

  int CallStaticByteMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticByteMethodA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .byte;

  int CallStaticCharMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticCharMethod.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .char;

  int CallStaticCharMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticCharMethodA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .char;

  int CallStaticShortMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticShortMethod.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .short;

  int CallStaticShortMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticShortMethodA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .short;

  int CallStaticIntMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticIntMethod.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .integer;

  int CallStaticIntMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticIntMethodA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .integer;

  int CallStaticLongMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticLongMethod.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .long;

  int CallStaticLongMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticLongMethodA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .long;

  double CallStaticFloatMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticFloatMethod.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .float;

  double CallStaticFloatMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticFloatMethodA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .float;

  double CallStaticDoubleMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticDoubleMethod.asFunction<
              JniResult Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .doubleFloat;

  double CallStaticDoubleMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticDoubleMethodA.asFunction<
              JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .doubleFloat;

  void CallStaticVoidMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      ref.CallStaticVoidMethod.asFunction<
              JThrowablePtr Function(
                  JClassPtr clazz, JMethodIDPtr methodID)>()(clazz, methodID)
          .check();

  void CallStaticVoidMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      ref.CallStaticVoidMethodA.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JMethodIDPtr methodID,
                  ffi.Pointer<JValue> args)>()(clazz, methodID, args)
          .check();

  JFieldIDPtr GetStaticFieldID(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig) =>
      ref.GetStaticFieldID.asFunction<
              JniPointerResult Function(
                  JClassPtr clazz,
                  ffi.Pointer<ffi.Char> name,
                  ffi.Pointer<ffi.Char> sig)>()(clazz, name, sig)
          .fieldID;

  JObjectPtr GetStaticObjectField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      ref.GetStaticObjectField.asFunction<
              JniResult Function(
                  JClassPtr clazz, JFieldIDPtr fieldID)>()(clazz, fieldID)
          .object;

  bool GetStaticBooleanField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      ref.GetStaticBooleanField.asFunction<
              JniResult Function(
                  JClassPtr clazz, JFieldIDPtr fieldID)>()(clazz, fieldID)
          .boolean;

  int GetStaticByteField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      ref.GetStaticByteField.asFunction<
              JniResult Function(
                  JClassPtr clazz, JFieldIDPtr fieldID)>()(clazz, fieldID)
          .byte;

  int GetStaticCharField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      ref.GetStaticCharField.asFunction<
              JniResult Function(
                  JClassPtr clazz, JFieldIDPtr fieldID)>()(clazz, fieldID)
          .char;

  int GetStaticShortField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      ref.GetStaticShortField.asFunction<
              JniResult Function(
                  JClassPtr clazz, JFieldIDPtr fieldID)>()(clazz, fieldID)
          .short;

  int GetStaticIntField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      ref.GetStaticIntField.asFunction<
              JniResult Function(
                  JClassPtr clazz, JFieldIDPtr fieldID)>()(clazz, fieldID)
          .integer;

  int GetStaticLongField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      ref.GetStaticLongField.asFunction<
              JniResult Function(
                  JClassPtr clazz, JFieldIDPtr fieldID)>()(clazz, fieldID)
          .long;

  double GetStaticFloatField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      ref.GetStaticFloatField.asFunction<
              JniResult Function(
                  JClassPtr clazz, JFieldIDPtr fieldID)>()(clazz, fieldID)
          .float;

  double GetStaticDoubleField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      ref.GetStaticDoubleField.asFunction<
              JniResult Function(
                  JClassPtr clazz, JFieldIDPtr fieldID)>()(clazz, fieldID)
          .doubleFloat;

  void SetStaticObjectField(
          JClassPtr clazz, JFieldIDPtr fieldID, JObjectPtr val) =>
      ref.SetStaticObjectField.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
                  JObjectPtr val)>()(clazz, fieldID, val)
          .check();

  void SetStaticBooleanField(JClassPtr clazz, JFieldIDPtr fieldID, int val) =>
      ref.SetStaticBooleanField.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
                  int val)>()(clazz, fieldID, val)
          .check();

  void SetStaticByteField(JClassPtr clazz, JFieldIDPtr fieldID, int val) =>
      ref.SetStaticByteField.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
                  int val)>()(clazz, fieldID, val)
          .check();

  void SetStaticCharField(JClassPtr clazz, JFieldIDPtr fieldID, int val) =>
      ref.SetStaticCharField.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
                  int val)>()(clazz, fieldID, val)
          .check();

  void SetStaticShortField(JClassPtr clazz, JFieldIDPtr fieldID, int val) =>
      ref.SetStaticShortField.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
                  int val)>()(clazz, fieldID, val)
          .check();

  void SetStaticIntField(JClassPtr clazz, JFieldIDPtr fieldID, int val) =>
      ref.SetStaticIntField.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
                  int val)>()(clazz, fieldID, val)
          .check();

  void SetStaticLongField(JClassPtr clazz, JFieldIDPtr fieldID, int val) =>
      ref.SetStaticLongField.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
                  int val)>()(clazz, fieldID, val)
          .check();

  void SetStaticFloatField(JClassPtr clazz, JFieldIDPtr fieldID, double val) =>
      ref.SetStaticFloatField.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
                  double val)>()(clazz, fieldID, val)
          .check();

  void SetStaticDoubleField(JClassPtr clazz, JFieldIDPtr fieldID, double val) =>
      ref.SetStaticDoubleField.asFunction<
              JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
                  double val)>()(clazz, fieldID, val)
          .check();

  JStringPtr NewString(ffi.Pointer<JCharMarker> unicodeChars, int len) =>
      ref.NewString.asFunction<
              JniResult Function(ffi.Pointer<JCharMarker> unicodeChars,
                  int len)>()(unicodeChars, len)
          .object;

  int GetStringLength(JStringPtr string) =>
      ref.GetStringLength.asFunction<JniResult Function(JStringPtr string)>()(
              string)
          .integer;

  ffi.Pointer<JCharMarker> GetStringChars(
          JStringPtr string, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetStringChars.asFunction<
              JniPointerResult Function(JStringPtr string,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(string, isCopy)
          .getPointer<JCharMarker>();

  void ReleaseStringChars(JStringPtr string, ffi.Pointer<JCharMarker> isCopy) =>
      ref.ReleaseStringChars.asFunction<
              JThrowablePtr Function(JStringPtr string,
                  ffi.Pointer<JCharMarker> isCopy)>()(string, isCopy)
          .check();

  JStringPtr NewStringUTF(ffi.Pointer<ffi.Char> bytes) => ref.NewStringUTF
          .asFunction<JniResult Function(ffi.Pointer<ffi.Char> bytes)>()(bytes)
      .object;

  int GetStringUTFLength(JStringPtr string) => ref.GetStringUTFLength
          .asFunction<JniResult Function(JStringPtr string)>()(string)
      .integer;

  ffi.Pointer<ffi.Char> GetStringUTFChars(
          JStringPtr string, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetStringUTFChars.asFunction<
              JniPointerResult Function(JStringPtr string,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(string, isCopy)
          .getPointer<ffi.Char>();

  void ReleaseStringUTFChars(JStringPtr string, ffi.Pointer<ffi.Char> utf) =>
      ref.ReleaseStringUTFChars.asFunction<
              JThrowablePtr Function(
                  JStringPtr string, ffi.Pointer<ffi.Char> utf)>()(string, utf)
          .check();

  int GetArrayLength(JArrayPtr array) =>
      ref.GetArrayLength.asFunction<JniResult Function(JArrayPtr array)>()(
              array)
          .integer;

  JObjectArrayPtr NewObjectArray(
          int length, JClassPtr elementClass, JObjectPtr initialElement) =>
      ref.NewObjectArray.asFunction<
                  JniResult Function(int length, JClassPtr elementClass,
                      JObjectPtr initialElement)>()(
              length, elementClass, initialElement)
          .object;

  JObjectPtr GetObjectArrayElement(JObjectArrayPtr array, int index) =>
      ref.GetObjectArrayElement.asFunction<
              JniResult Function(
                  JObjectArrayPtr array, int index)>()(array, index)
          .object;

  void SetObjectArrayElement(
          JObjectArrayPtr array, int index, JObjectPtr val) =>
      ref.SetObjectArrayElement.asFunction<
              JThrowablePtr Function(JObjectArrayPtr array, int index,
                  JObjectPtr val)>()(array, index, val)
          .check();

  JBooleanArrayPtr NewBooleanArray(int length) =>
      ref.NewBooleanArray.asFunction<JniResult Function(int length)>()(length)
          .object;

  JByteArrayPtr NewByteArray(int length) =>
      ref.NewByteArray.asFunction<JniResult Function(int length)>()(length)
          .object;

  JCharArrayPtr NewCharArray(int length) =>
      ref.NewCharArray.asFunction<JniResult Function(int length)>()(length)
          .object;

  JShortArrayPtr NewShortArray(int length) =>
      ref.NewShortArray.asFunction<JniResult Function(int length)>()(length)
          .object;

  JIntArrayPtr NewIntArray(int length) =>
      ref.NewIntArray.asFunction<JniResult Function(int length)>()(length)
          .object;

  JLongArrayPtr NewLongArray(int length) =>
      ref.NewLongArray.asFunction<JniResult Function(int length)>()(length)
          .object;

  JFloatArrayPtr NewFloatArray(int length) =>
      ref.NewFloatArray.asFunction<JniResult Function(int length)>()(length)
          .object;

  JDoubleArrayPtr NewDoubleArray(int length) =>
      ref.NewDoubleArray.asFunction<JniResult Function(int length)>()(length)
          .object;

  ffi.Pointer<JBooleanMarker> GetBooleanArrayElements(
          JBooleanArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetBooleanArrayElements.asFunction<
              JniPointerResult Function(JBooleanArrayPtr array,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(array, isCopy)
          .getPointer<JBooleanMarker>();

  ffi.Pointer<JByteMarker> GetByteArrayElements(
          JByteArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetByteArrayElements.asFunction<
              JniPointerResult Function(JByteArrayPtr array,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(array, isCopy)
          .getPointer<JByteMarker>();

  ffi.Pointer<JCharMarker> GetCharArrayElements(
          JCharArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetCharArrayElements.asFunction<
              JniPointerResult Function(JCharArrayPtr array,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(array, isCopy)
          .getPointer<JCharMarker>();

  ffi.Pointer<JShortMarker> GetShortArrayElements(
          JShortArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetShortArrayElements.asFunction<
              JniPointerResult Function(JShortArrayPtr array,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(array, isCopy)
          .getPointer<JShortMarker>();

  ffi.Pointer<JIntMarker> GetIntArrayElements(
          JIntArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetIntArrayElements.asFunction<
              JniPointerResult Function(JIntArrayPtr array,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(array, isCopy)
          .getPointer<JIntMarker>();

  ffi.Pointer<JLongMarker> GetLongArrayElements(
          JLongArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetLongArrayElements.asFunction<
              JniPointerResult Function(JLongArrayPtr array,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(array, isCopy)
          .getPointer<JLongMarker>();

  ffi.Pointer<JFloatMarker> GetFloatArrayElements(
          JFloatArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetFloatArrayElements.asFunction<
              JniPointerResult Function(JFloatArrayPtr array,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(array, isCopy)
          .getPointer<JFloatMarker>();

  ffi.Pointer<JDoubleMarker> GetDoubleArrayElements(
          JDoubleArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetDoubleArrayElements.asFunction<
              JniPointerResult Function(JDoubleArrayPtr array,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(array, isCopy)
          .getPointer<JDoubleMarker>();

  void ReleaseBooleanArrayElements(JBooleanArrayPtr array,
          ffi.Pointer<JBooleanMarker> elems, int mode) =>
      ref.ReleaseBooleanArrayElements.asFunction<
              JThrowablePtr Function(
                  JBooleanArrayPtr array,
                  ffi.Pointer<JBooleanMarker> elems,
                  int mode)>()(array, elems, mode)
          .check();

  void ReleaseByteArrayElements(
          JByteArrayPtr array, ffi.Pointer<JByteMarker> elems, int mode) =>
      ref.ReleaseByteArrayElements.asFunction<
              JThrowablePtr Function(
                  JByteArrayPtr array,
                  ffi.Pointer<JByteMarker> elems,
                  int mode)>()(array, elems, mode)
          .check();

  void ReleaseCharArrayElements(
          JCharArrayPtr array, ffi.Pointer<JCharMarker> elems, int mode) =>
      ref.ReleaseCharArrayElements.asFunction<
              JThrowablePtr Function(
                  JCharArrayPtr array,
                  ffi.Pointer<JCharMarker> elems,
                  int mode)>()(array, elems, mode)
          .check();

  void ReleaseShortArrayElements(
          JShortArrayPtr array, ffi.Pointer<JShortMarker> elems, int mode) =>
      ref.ReleaseShortArrayElements.asFunction<
              JThrowablePtr Function(
                  JShortArrayPtr array,
                  ffi.Pointer<JShortMarker> elems,
                  int mode)>()(array, elems, mode)
          .check();

  void ReleaseIntArrayElements(
          JIntArrayPtr array, ffi.Pointer<JIntMarker> elems, int mode) =>
      ref.ReleaseIntArrayElements.asFunction<
              JThrowablePtr Function(
                  JIntArrayPtr array,
                  ffi.Pointer<JIntMarker> elems,
                  int mode)>()(array, elems, mode)
          .check();

  void ReleaseLongArrayElements(
          JLongArrayPtr array, ffi.Pointer<JLongMarker> elems, int mode) =>
      ref.ReleaseLongArrayElements.asFunction<
              JThrowablePtr Function(
                  JLongArrayPtr array,
                  ffi.Pointer<JLongMarker> elems,
                  int mode)>()(array, elems, mode)
          .check();

  void ReleaseFloatArrayElements(
          JFloatArrayPtr array, ffi.Pointer<JFloatMarker> elems, int mode) =>
      ref.ReleaseFloatArrayElements.asFunction<
              JThrowablePtr Function(
                  JFloatArrayPtr array,
                  ffi.Pointer<JFloatMarker> elems,
                  int mode)>()(array, elems, mode)
          .check();

  void ReleaseDoubleArrayElements(
          JDoubleArrayPtr array, ffi.Pointer<JDoubleMarker> elems, int mode) =>
      ref.ReleaseDoubleArrayElements.asFunction<
              JThrowablePtr Function(
                  JDoubleArrayPtr array,
                  ffi.Pointer<JDoubleMarker> elems,
                  int mode)>()(array, elems, mode)
          .check();

  void GetBooleanArrayRegion(JBooleanArrayPtr array, int start, int len,
          ffi.Pointer<JBooleanMarker> buf) =>
      ref.GetBooleanArrayRegion.asFunction<
              JThrowablePtr Function(JBooleanArrayPtr array, int start, int len,
                  ffi.Pointer<JBooleanMarker> buf)>()(array, start, len, buf)
          .check();

  void GetByteArrayRegion(JByteArrayPtr array, int start, int len,
          ffi.Pointer<JByteMarker> buf) =>
      ref.GetByteArrayRegion.asFunction<
              JThrowablePtr Function(JByteArrayPtr array, int start, int len,
                  ffi.Pointer<JByteMarker> buf)>()(array, start, len, buf)
          .check();

  void GetCharArrayRegion(JCharArrayPtr array, int start, int len,
          ffi.Pointer<JCharMarker> buf) =>
      ref.GetCharArrayRegion.asFunction<
              JThrowablePtr Function(JCharArrayPtr array, int start, int len,
                  ffi.Pointer<JCharMarker> buf)>()(array, start, len, buf)
          .check();

  void GetShortArrayRegion(JShortArrayPtr array, int start, int len,
          ffi.Pointer<JShortMarker> buf) =>
      ref.GetShortArrayRegion.asFunction<
              JThrowablePtr Function(JShortArrayPtr array, int start, int len,
                  ffi.Pointer<JShortMarker> buf)>()(array, start, len, buf)
          .check();

  void GetIntArrayRegion(JIntArrayPtr array, int start, int len,
          ffi.Pointer<JIntMarker> buf) =>
      ref.GetIntArrayRegion.asFunction<
              JThrowablePtr Function(JIntArrayPtr array, int start, int len,
                  ffi.Pointer<JIntMarker> buf)>()(array, start, len, buf)
          .check();

  void GetLongArrayRegion(JLongArrayPtr array, int start, int len,
          ffi.Pointer<JLongMarker> buf) =>
      ref.GetLongArrayRegion.asFunction<
              JThrowablePtr Function(JLongArrayPtr array, int start, int len,
                  ffi.Pointer<JLongMarker> buf)>()(array, start, len, buf)
          .check();

  void GetFloatArrayRegion(JFloatArrayPtr array, int start, int len,
          ffi.Pointer<JFloatMarker> buf) =>
      ref.GetFloatArrayRegion.asFunction<
              JThrowablePtr Function(JFloatArrayPtr array, int start, int len,
                  ffi.Pointer<JFloatMarker> buf)>()(array, start, len, buf)
          .check();

  void GetDoubleArrayRegion(JDoubleArrayPtr array, int start, int len,
          ffi.Pointer<JDoubleMarker> buf) =>
      ref.GetDoubleArrayRegion.asFunction<
              JThrowablePtr Function(JDoubleArrayPtr array, int start, int len,
                  ffi.Pointer<JDoubleMarker> buf)>()(array, start, len, buf)
          .check();

  void SetBooleanArrayRegion(JBooleanArrayPtr array, int start, int len,
          ffi.Pointer<JBooleanMarker> buf) =>
      ref.SetBooleanArrayRegion.asFunction<
              JThrowablePtr Function(JBooleanArrayPtr array, int start, int len,
                  ffi.Pointer<JBooleanMarker> buf)>()(array, start, len, buf)
          .check();

  void SetByteArrayRegion(JByteArrayPtr array, int start, int len,
          ffi.Pointer<JByteMarker> buf) =>
      ref.SetByteArrayRegion.asFunction<
              JThrowablePtr Function(JByteArrayPtr array, int start, int len,
                  ffi.Pointer<JByteMarker> buf)>()(array, start, len, buf)
          .check();

  void SetCharArrayRegion(JCharArrayPtr array, int start, int len,
          ffi.Pointer<JCharMarker> buf) =>
      ref.SetCharArrayRegion.asFunction<
              JThrowablePtr Function(JCharArrayPtr array, int start, int len,
                  ffi.Pointer<JCharMarker> buf)>()(array, start, len, buf)
          .check();

  void SetShortArrayRegion(JShortArrayPtr array, int start, int len,
          ffi.Pointer<JShortMarker> buf) =>
      ref.SetShortArrayRegion.asFunction<
              JThrowablePtr Function(JShortArrayPtr array, int start, int len,
                  ffi.Pointer<JShortMarker> buf)>()(array, start, len, buf)
          .check();

  void SetIntArrayRegion(JIntArrayPtr array, int start, int len,
          ffi.Pointer<JIntMarker> buf) =>
      ref.SetIntArrayRegion.asFunction<
              JThrowablePtr Function(JIntArrayPtr array, int start, int len,
                  ffi.Pointer<JIntMarker> buf)>()(array, start, len, buf)
          .check();

  void SetLongArrayRegion(JLongArrayPtr array, int start, int len,
          ffi.Pointer<JLongMarker> buf) =>
      ref.SetLongArrayRegion.asFunction<
              JThrowablePtr Function(JLongArrayPtr array, int start, int len,
                  ffi.Pointer<JLongMarker> buf)>()(array, start, len, buf)
          .check();

  void SetFloatArrayRegion(JFloatArrayPtr array, int start, int len,
          ffi.Pointer<JFloatMarker> buf) =>
      ref.SetFloatArrayRegion.asFunction<
              JThrowablePtr Function(JFloatArrayPtr array, int start, int len,
                  ffi.Pointer<JFloatMarker> buf)>()(array, start, len, buf)
          .check();

  void SetDoubleArrayRegion(JDoubleArrayPtr array, int start, int len,
          ffi.Pointer<JDoubleMarker> buf) =>
      ref.SetDoubleArrayRegion.asFunction<
              JThrowablePtr Function(JDoubleArrayPtr array, int start, int len,
                  ffi.Pointer<JDoubleMarker> buf)>()(array, start, len, buf)
          .check();

  int RegisterNatives(JClassPtr clazz, ffi.Pointer<JNINativeMethod> methods,
          int nMethods) =>
      ref.RegisterNatives.asFunction<
              JniResult Function(
                  JClassPtr clazz,
                  ffi.Pointer<JNINativeMethod> methods,
                  int nMethods)>()(clazz, methods, nMethods)
          .integer;

  int UnregisterNatives(JClassPtr clazz) =>
      ref.UnregisterNatives.asFunction<JniResult Function(JClassPtr clazz)>()(
              clazz)
          .integer;

  int MonitorEnter(JObjectPtr obj) =>
      ref.MonitorEnter.asFunction<JniResult Function(JObjectPtr obj)>()(obj)
          .integer;

  int MonitorExit(JObjectPtr obj) =>
      ref.MonitorExit.asFunction<JniResult Function(JObjectPtr obj)>()(obj)
          .integer;

  int GetJavaVM(ffi.Pointer<ffi.Pointer<JavaVM1>> vm) =>
      ref.GetJavaVM.asFunction<
              JniResult Function(ffi.Pointer<ffi.Pointer<JavaVM1>> vm)>()(vm)
          .integer;

  void GetStringRegion(
          JStringPtr str, int start, int len, ffi.Pointer<JCharMarker> buf) =>
      ref.GetStringRegion.asFunction<
              JThrowablePtr Function(JStringPtr str, int start, int len,
                  ffi.Pointer<JCharMarker> buf)>()(str, start, len, buf)
          .check();

  void GetStringUTFRegion(
          JStringPtr str, int start, int len, ffi.Pointer<ffi.Char> buf) =>
      ref.GetStringUTFRegion.asFunction<
              JThrowablePtr Function(JStringPtr str, int start, int len,
                  ffi.Pointer<ffi.Char> buf)>()(str, start, len, buf)
          .check();

  ffi.Pointer<ffi.Void> GetPrimitiveArrayCritical(
          JArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetPrimitiveArrayCritical.asFunction<
              JniPointerResult Function(JArrayPtr array,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(array, isCopy)
          .getPointer<ffi.Void>();

  void ReleasePrimitiveArrayCritical(
          JArrayPtr array, ffi.Pointer<ffi.Void> carray, int mode) =>
      ref.ReleasePrimitiveArrayCritical.asFunction<
              JThrowablePtr Function(
                  JArrayPtr array,
                  ffi.Pointer<ffi.Void> carray,
                  int mode)>()(array, carray, mode)
          .check();

  ffi.Pointer<JCharMarker> GetStringCritical(
          JStringPtr str, ffi.Pointer<JBooleanMarker> isCopy) =>
      ref.GetStringCritical.asFunction<
              JniPointerResult Function(JStringPtr str,
                  ffi.Pointer<JBooleanMarker> isCopy)>()(str, isCopy)
          .getPointer<JCharMarker>();

  void ReleaseStringCritical(JStringPtr str, ffi.Pointer<JCharMarker> carray) =>
      ref.ReleaseStringCritical.asFunction<
              JThrowablePtr Function(JStringPtr str,
                  ffi.Pointer<JCharMarker> carray)>()(str, carray)
          .check();

  JWeakPtr NewWeakGlobalRef(JObjectPtr obj) =>
      ref.NewWeakGlobalRef.asFunction<JniResult Function(JObjectPtr obj)>()(obj)
          .object;

  void DeleteWeakGlobalRef(JWeakPtr obj) => ref.DeleteWeakGlobalRef.asFunction<
          JThrowablePtr Function(JWeakPtr obj)>()(obj)
      .check();

  bool ExceptionCheck() =>
      ref.ExceptionCheck.asFunction<JniResult Function()>()().boolean;

  JObjectPtr NewDirectByteBuffer(ffi.Pointer<ffi.Void> address, int capacity) =>
      ref.NewDirectByteBuffer.asFunction<
              JniResult Function(ffi.Pointer<ffi.Void> address,
                  int capacity)>()(address, capacity)
          .object;

  ffi.Pointer<ffi.Void> GetDirectBufferAddress(JObjectPtr buf) =>
      ref.GetDirectBufferAddress.asFunction<
              JniPointerResult Function(JObjectPtr buf)>()(buf)
          .getPointer<ffi.Void>();

  int GetDirectBufferCapacity(JObjectPtr buf) => ref.GetDirectBufferCapacity
          .asFunction<JniResult Function(JObjectPtr buf)>()(buf)
      .long;

  int GetObjectRefType(JObjectPtr obj) =>
      ref.GetObjectRefType.asFunction<JniResult Function(JObjectPtr obj)>()(obj)
          .integer;
}

extension JniAccessorsExtension on ffi.Pointer<JniAccessors> {
  JniClassLookupResult getClass(ffi.Pointer<ffi.Char> internalName) =>
      ref.getClass.asFunction<
          JniClassLookupResult Function(
              ffi.Pointer<ffi.Char> internalName)>()(internalName);

  JniPointerResult getFieldID(JClassPtr cls, ffi.Pointer<ffi.Char> fieldName,
          ffi.Pointer<ffi.Char> signature) =>
      ref.getFieldID.asFunction<
          JniPointerResult Function(
              JClassPtr cls,
              ffi.Pointer<ffi.Char> fieldName,
              ffi.Pointer<ffi.Char> signature)>()(cls, fieldName, signature);

  JniPointerResult getStaticFieldID(JClassPtr cls,
          ffi.Pointer<ffi.Char> fieldName, ffi.Pointer<ffi.Char> signature) =>
      ref.getStaticFieldID.asFunction<
          JniPointerResult Function(
              JClassPtr cls,
              ffi.Pointer<ffi.Char> fieldName,
              ffi.Pointer<ffi.Char> signature)>()(cls, fieldName, signature);

  JniPointerResult getMethodID(JClassPtr cls, ffi.Pointer<ffi.Char> methodName,
          ffi.Pointer<ffi.Char> signature) =>
      ref.getMethodID.asFunction<
          JniPointerResult Function(
              JClassPtr cls,
              ffi.Pointer<ffi.Char> methodName,
              ffi.Pointer<ffi.Char> signature)>()(cls, methodName, signature);

  JniPointerResult getStaticMethodID(JClassPtr cls,
          ffi.Pointer<ffi.Char> methodName, ffi.Pointer<ffi.Char> signature) =>
      ref.getStaticMethodID.asFunction<
          JniPointerResult Function(
              JClassPtr cls,
              ffi.Pointer<ffi.Char> methodName,
              ffi.Pointer<ffi.Char> signature)>()(cls, methodName, signature);

  JniResult newObject(
          JClassPtr cls, JMethodIDPtr ctor, ffi.Pointer<JValue> args) =>
      ref.newObject.asFunction<
          JniResult Function(JClassPtr cls, JMethodIDPtr ctor,
              ffi.Pointer<JValue> args)>()(cls, ctor, args);

  JniPointerResult newPrimitiveArray(int length, int type) =>
      ref.newPrimitiveArray
              .asFunction<JniPointerResult Function(int length, int type)>()(
          length, type);

  JniPointerResult newObjectArray(
          int length, JClassPtr elementClass, JObjectPtr initialElement) =>
      ref.newObjectArray.asFunction<
              JniPointerResult Function(int length, JClassPtr elementClass,
                  JObjectPtr initialElement)>()(
          length, elementClass, initialElement);

  JniResult getArrayElement(JArrayPtr array, int index, int type) =>
      ref.getArrayElement.asFunction<
          JniResult Function(
              JArrayPtr array, int index, int type)>()(array, index, type);

  JniResult callMethod(JObjectPtr obj, JMethodIDPtr methodID, int callType,
          ffi.Pointer<JValue> args) =>
      ref.callMethod.asFunction<
          JniResult Function(
              JObjectPtr obj,
              JMethodIDPtr methodID,
              int callType,
              ffi.Pointer<JValue> args)>()(obj, methodID, callType, args);

  JniResult callStaticMethod(JClassPtr cls, JMethodIDPtr methodID, int callType,
          ffi.Pointer<JValue> args) =>
      ref.callStaticMethod.asFunction<
          JniResult Function(JClassPtr cls, JMethodIDPtr methodID, int callType,
              ffi.Pointer<JValue> args)>()(cls, methodID, callType, args);

  JniResult getField(JObjectPtr obj, JFieldIDPtr fieldID, int callType) =>
      ref.getField.asFunction<
          JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID,
              int callType)>()(obj, fieldID, callType);

  JniResult getStaticField(JClassPtr cls, JFieldIDPtr fieldID, int callType) =>
      ref.getStaticField.asFunction<
          JniResult Function(JClassPtr cls, JFieldIDPtr fieldID,
              int callType)>()(cls, fieldID, callType);

  JniExceptionDetails getExceptionDetails(JThrowablePtr exception) => ref
          .getExceptionDetails
          .asFunction<JniExceptionDetails Function(JThrowablePtr exception)>()(
      exception);
}
