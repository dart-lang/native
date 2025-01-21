// Auto generated file. Do not edit.

// This is generated from JNI header in Android NDK. License for the same is
// provided below.

// Generation logic resides in `tool/wrapper_generators`.
// To regenerate, run `dart run tool/generate_ffi_bindings.dart`.

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

import 'dart:ffi' as ffi;

import '../accessors.dart';
import 'jni_bindings_generated.dart';

/// Wraps over `Pointer<GlobalJniEnvStruct>` and exposes function pointer fields
/// as methods.
class GlobalJniEnv {
  final ffi.Pointer<GlobalJniEnvStruct> ptr;
  GlobalJniEnv(this.ptr);
  late final _GetVersion =
      ptr.ref.GetVersion.asFunction<JniResult Function()>(isLeaf: true);

  DartJIntMarker GetVersion() => _GetVersion().integer;

  late final _DefineClass = ptr.ref.DefineClass.asFunction<
      JniClassLookupResult Function(
          ffi.Pointer<ffi.Char> name,
          JObjectPtr loader,
          ffi.Pointer<JByteMarker> buf,
          DartJIntMarker bufLen)>();

  JClassPtr DefineClass(ffi.Pointer<ffi.Char> name, JObjectPtr loader,
          ffi.Pointer<JByteMarker> buf, DartJIntMarker bufLen) =>
      _DefineClass(name, loader, buf, bufLen).value;

  late final _FindClass = ptr.ref.FindClass
      .asFunction<JniClassLookupResult Function(ffi.Pointer<ffi.Char> name)>(
          isLeaf: true);

  JClassPtr FindClass(ffi.Pointer<ffi.Char> name) => _FindClass(name).value;

  late final _FromReflectedMethod = ptr.ref.FromReflectedMethod
      .asFunction<JniPointerResult Function(JObjectPtr method)>();

  JMethodIDPtr FromReflectedMethod(JObjectPtr method) =>
      _FromReflectedMethod(method).methodID;

  late final _FromReflectedField = ptr.ref.FromReflectedField
      .asFunction<JniPointerResult Function(JObjectPtr field)>();

  JFieldIDPtr FromReflectedField(JObjectPtr field) =>
      _FromReflectedField(field).fieldID;

  late final _ToReflectedMethod = ptr.ref.ToReflectedMethod.asFunction<
      JniResult Function(
          JClassPtr cls, JMethodIDPtr methodId, DartJBooleanMarker isStatic)>();

  JObjectPtr ToReflectedMethod(
          JClassPtr cls, JMethodIDPtr methodId, DartJBooleanMarker isStatic) =>
      _ToReflectedMethod(cls, methodId, isStatic).objectPointer;

  late final _GetSuperclass = ptr.ref.GetSuperclass
      .asFunction<JniClassLookupResult Function(JClassPtr clazz)>(isLeaf: true);

  JClassPtr GetSuperclass(JClassPtr clazz) => _GetSuperclass(clazz).value;

  late final _IsAssignableFrom = ptr.ref.IsAssignableFrom
      .asFunction<JniResult Function(JClassPtr clazz1, JClassPtr clazz2)>(
          isLeaf: true);

  bool IsAssignableFrom(JClassPtr clazz1, JClassPtr clazz2) =>
      _IsAssignableFrom(clazz1, clazz2).boolean;

  late final _ToReflectedField = ptr.ref.ToReflectedField.asFunction<
      JniResult Function(
          JClassPtr cls, JFieldIDPtr fieldID, DartJBooleanMarker isStatic)>();

  JObjectPtr ToReflectedField(
          JClassPtr cls, JFieldIDPtr fieldID, DartJBooleanMarker isStatic) =>
      _ToReflectedField(cls, fieldID, isStatic).objectPointer;

  late final _Throw =
      ptr.ref.Throw.asFunction<JniResult Function(JThrowablePtr obj)>();

  DartJIntMarker Throw(JThrowablePtr obj) => _Throw(obj).integer;

  late final _ThrowNew = ptr.ref.ThrowNew.asFunction<
      JniResult Function(JClassPtr clazz, ffi.Pointer<ffi.Char> message)>();

  DartJIntMarker ThrowNew(JClassPtr clazz, ffi.Pointer<ffi.Char> message) =>
      _ThrowNew(clazz, message).integer;

  late final _ExceptionOccurred =
      ptr.ref.ExceptionOccurred.asFunction<JniResult Function()>();

  JThrowablePtr ExceptionOccurred() => _ExceptionOccurred().objectPointer;

  late final _ExceptionDescribe =
      ptr.ref.ExceptionDescribe.asFunction<JThrowablePtr Function()>();

  void ExceptionDescribe() => _ExceptionDescribe().check();

  late final _ExceptionClear =
      ptr.ref.ExceptionClear.asFunction<JThrowablePtr Function()>();

  void ExceptionClear() => _ExceptionClear().check();

  late final _FatalError = ptr.ref.FatalError
      .asFunction<JThrowablePtr Function(ffi.Pointer<ffi.Char> msg)>();

  void FatalError(ffi.Pointer<ffi.Char> msg) => _FatalError(msg).check();

  late final _PushLocalFrame = ptr.ref.PushLocalFrame
      .asFunction<JniResult Function(DartJIntMarker capacity)>();

  DartJIntMarker PushLocalFrame(DartJIntMarker capacity) =>
      _PushLocalFrame(capacity).integer;

  late final _PopLocalFrame =
      ptr.ref.PopLocalFrame.asFunction<JniResult Function(JObjectPtr result)>();

  JObjectPtr PopLocalFrame(JObjectPtr result) =>
      _PopLocalFrame(result).objectPointer;

  late final _NewGlobalRef = ptr.ref.NewGlobalRef
      .asFunction<JniResult Function(JObjectPtr obj)>(isLeaf: true);

  JObjectPtr NewGlobalRef(JObjectPtr obj) => _NewGlobalRef(obj).objectPointer;

  late final _DeleteGlobalRef = ptr.ref.DeleteGlobalRef
      .asFunction<JThrowablePtr Function(JObjectPtr globalRef)>(isLeaf: true);

  void DeleteGlobalRef(JObjectPtr globalRef) =>
      _DeleteGlobalRef(globalRef).check();

  late final _DeleteLocalRef = ptr.ref.DeleteLocalRef
      .asFunction<JThrowablePtr Function(JObjectPtr localRef)>(isLeaf: true);

  void DeleteLocalRef(JObjectPtr localRef) => _DeleteLocalRef(localRef).check();

  late final _IsSameObject = ptr.ref.IsSameObject
      .asFunction<JniResult Function(JObjectPtr ref1, JObjectPtr ref2)>(
          isLeaf: true);

  bool IsSameObject(JObjectPtr ref1, JObjectPtr ref2) =>
      _IsSameObject(ref1, ref2).boolean;

  late final _NewLocalRef = ptr.ref.NewLocalRef
      .asFunction<JniResult Function(JObjectPtr obj)>(isLeaf: true);

  JObjectPtr NewLocalRef(JObjectPtr obj) => _NewLocalRef(obj).objectPointer;

  late final _EnsureLocalCapacity = ptr.ref.EnsureLocalCapacity
      .asFunction<JniResult Function(DartJIntMarker capacity)>();

  DartJIntMarker EnsureLocalCapacity(DartJIntMarker capacity) =>
      _EnsureLocalCapacity(capacity).integer;

  late final _AllocObject =
      ptr.ref.AllocObject.asFunction<JniResult Function(JClassPtr clazz)>();

  JObjectPtr AllocObject(JClassPtr clazz) => _AllocObject(clazz).objectPointer;

  late final _NewObject = ptr.ref.NewObject
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  JObjectPtr NewObject(JClassPtr clazz, JMethodIDPtr methodID) =>
      _NewObject(clazz, methodID).objectPointer;

  late final _NewObjectA = ptr.ref.NewObjectA.asFunction<
      JniResult Function(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  JObjectPtr NewObjectA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _NewObjectA(clazz, methodID, args).objectPointer;

  late final _GetObjectClass = ptr.ref.GetObjectClass
      .asFunction<JniClassLookupResult Function(JObjectPtr obj)>(isLeaf: true);

  JClassPtr GetObjectClass(JObjectPtr obj) => _GetObjectClass(obj).value;

  late final _IsInstanceOf = ptr.ref.IsInstanceOf
      .asFunction<JniResult Function(JObjectPtr obj, JClassPtr clazz)>();

  bool IsInstanceOf(JObjectPtr obj, JClassPtr clazz) =>
      _IsInstanceOf(obj, clazz).boolean;

  late final _GetMethodID = ptr.ref.GetMethodID.asFunction<
      JniPointerResult Function(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig)>(isLeaf: true);

  JMethodIDPtr GetMethodID(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig) =>
      _GetMethodID(clazz, name, sig).methodID;

  late final _CallObjectMethod = ptr.ref.CallObjectMethod
      .asFunction<JniResult Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  JObjectPtr CallObjectMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallObjectMethod(obj, methodID).objectPointer;

  late final _CallObjectMethodA = ptr.ref.CallObjectMethodA.asFunction<
      JniResult Function(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  JObjectPtr CallObjectMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallObjectMethodA(obj, methodID, args).objectPointer;

  late final _CallBooleanMethod = ptr.ref.CallBooleanMethod
      .asFunction<JniResult Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  bool CallBooleanMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallBooleanMethod(obj, methodID).boolean;

  late final _CallBooleanMethodA = ptr.ref.CallBooleanMethodA.asFunction<
      JniResult Function(
          JObjectPtr obj, JMethodIDPtr methodId, ffi.Pointer<JValue> args)>();

  bool CallBooleanMethodA(
          JObjectPtr obj, JMethodIDPtr methodId, ffi.Pointer<JValue> args) =>
      _CallBooleanMethodA(obj, methodId, args).boolean;

  late final _CallByteMethod = ptr.ref.CallByteMethod
      .asFunction<JniResult Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  DartJByteMarker CallByteMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallByteMethod(obj, methodID).byte;

  late final _CallByteMethodA = ptr.ref.CallByteMethodA.asFunction<
      JniResult Function(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJByteMarker CallByteMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallByteMethodA(obj, methodID, args).byte;

  late final _CallCharMethod = ptr.ref.CallCharMethod
      .asFunction<JniResult Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  DartJCharMarker CallCharMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallCharMethod(obj, methodID).char;

  late final _CallCharMethodA = ptr.ref.CallCharMethodA.asFunction<
      JniResult Function(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJCharMarker CallCharMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallCharMethodA(obj, methodID, args).char;

  late final _CallShortMethod = ptr.ref.CallShortMethod
      .asFunction<JniResult Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  DartJShortMarker CallShortMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallShortMethod(obj, methodID).short;

  late final _CallShortMethodA = ptr.ref.CallShortMethodA.asFunction<
      JniResult Function(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJShortMarker CallShortMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallShortMethodA(obj, methodID, args).short;

  late final _CallIntMethod = ptr.ref.CallIntMethod
      .asFunction<JniResult Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  DartJIntMarker CallIntMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallIntMethod(obj, methodID).integer;

  late final _CallIntMethodA = ptr.ref.CallIntMethodA.asFunction<
      JniResult Function(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJIntMarker CallIntMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallIntMethodA(obj, methodID, args).integer;

  late final _CallLongMethod = ptr.ref.CallLongMethod
      .asFunction<JniResult Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  DartJLongMarker CallLongMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallLongMethod(obj, methodID).long;

  late final _CallLongMethodA = ptr.ref.CallLongMethodA.asFunction<
      JniResult Function(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJLongMarker CallLongMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallLongMethodA(obj, methodID, args).long;

  late final _CallFloatMethod = ptr.ref.CallFloatMethod
      .asFunction<JniResult Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  DartJFloatMarker CallFloatMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallFloatMethod(obj, methodID).float;

  late final _CallFloatMethodA = ptr.ref.CallFloatMethodA.asFunction<
      JniResult Function(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJFloatMarker CallFloatMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallFloatMethodA(obj, methodID, args).float;

  late final _CallDoubleMethod = ptr.ref.CallDoubleMethod
      .asFunction<JniResult Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  DartJDoubleMarker CallDoubleMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallDoubleMethod(obj, methodID).doubleFloat;

  late final _CallDoubleMethodA = ptr.ref.CallDoubleMethodA.asFunction<
      JniResult Function(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJDoubleMarker CallDoubleMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallDoubleMethodA(obj, methodID, args).doubleFloat;

  late final _CallVoidMethod = ptr.ref.CallVoidMethod.asFunction<
      JThrowablePtr Function(JObjectPtr obj, JMethodIDPtr methodID)>();

  void CallVoidMethod(JObjectPtr obj, JMethodIDPtr methodID) =>
      _CallVoidMethod(obj, methodID).check();

  late final _CallVoidMethodA = ptr.ref.CallVoidMethodA.asFunction<
      JThrowablePtr Function(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  void CallVoidMethodA(
          JObjectPtr obj, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallVoidMethodA(obj, methodID, args).check();

  late final _CallNonvirtualObjectMethod = ptr.ref.CallNonvirtualObjectMethod
      .asFunction<
          JniResult Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  JObjectPtr CallNonvirtualObjectMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualObjectMethod(obj, clazz, methodID).objectPointer;

  late final _CallNonvirtualObjectMethodA = ptr.ref.CallNonvirtualObjectMethodA
      .asFunction<
          JniResult Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  JObjectPtr CallNonvirtualObjectMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualObjectMethodA(obj, clazz, methodID, args).objectPointer;

  late final _CallNonvirtualBooleanMethod = ptr.ref.CallNonvirtualBooleanMethod
      .asFunction<
          JniResult Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  bool CallNonvirtualBooleanMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualBooleanMethod(obj, clazz, methodID).boolean;

  late final _CallNonvirtualBooleanMethodA =
      ptr.ref.CallNonvirtualBooleanMethodA.asFunction<
          JniResult Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  bool CallNonvirtualBooleanMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualBooleanMethodA(obj, clazz, methodID, args).boolean;

  late final _CallNonvirtualByteMethod = ptr.ref.CallNonvirtualByteMethod
      .asFunction<
          JniResult Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJByteMarker CallNonvirtualByteMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualByteMethod(obj, clazz, methodID).byte;

  late final _CallNonvirtualByteMethodA = ptr.ref.CallNonvirtualByteMethodA
      .asFunction<
          JniResult Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJByteMarker CallNonvirtualByteMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualByteMethodA(obj, clazz, methodID, args).byte;

  late final _CallNonvirtualCharMethod = ptr.ref.CallNonvirtualCharMethod
      .asFunction<
          JniResult Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJCharMarker CallNonvirtualCharMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualCharMethod(obj, clazz, methodID).char;

  late final _CallNonvirtualCharMethodA = ptr.ref.CallNonvirtualCharMethodA
      .asFunction<
          JniResult Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJCharMarker CallNonvirtualCharMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualCharMethodA(obj, clazz, methodID, args).char;

  late final _CallNonvirtualShortMethod = ptr.ref.CallNonvirtualShortMethod
      .asFunction<
          JniResult Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJShortMarker CallNonvirtualShortMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualShortMethod(obj, clazz, methodID).short;

  late final _CallNonvirtualShortMethodA = ptr.ref.CallNonvirtualShortMethodA
      .asFunction<
          JniResult Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJShortMarker CallNonvirtualShortMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualShortMethodA(obj, clazz, methodID, args).short;

  late final _CallNonvirtualIntMethod = ptr.ref.CallNonvirtualIntMethod
      .asFunction<
          JniResult Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJIntMarker CallNonvirtualIntMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualIntMethod(obj, clazz, methodID).integer;

  late final _CallNonvirtualIntMethodA = ptr.ref.CallNonvirtualIntMethodA
      .asFunction<
          JniResult Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJIntMarker CallNonvirtualIntMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualIntMethodA(obj, clazz, methodID, args).integer;

  late final _CallNonvirtualLongMethod = ptr.ref.CallNonvirtualLongMethod
      .asFunction<
          JniResult Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJLongMarker CallNonvirtualLongMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualLongMethod(obj, clazz, methodID).long;

  late final _CallNonvirtualLongMethodA = ptr.ref.CallNonvirtualLongMethodA
      .asFunction<
          JniResult Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJLongMarker CallNonvirtualLongMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualLongMethodA(obj, clazz, methodID, args).long;

  late final _CallNonvirtualFloatMethod = ptr.ref.CallNonvirtualFloatMethod
      .asFunction<
          JniResult Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJFloatMarker CallNonvirtualFloatMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualFloatMethod(obj, clazz, methodID).float;

  late final _CallNonvirtualFloatMethodA = ptr.ref.CallNonvirtualFloatMethodA
      .asFunction<
          JniResult Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJFloatMarker CallNonvirtualFloatMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualFloatMethodA(obj, clazz, methodID, args).float;

  late final _CallNonvirtualDoubleMethod = ptr.ref.CallNonvirtualDoubleMethod
      .asFunction<
          JniResult Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJDoubleMarker CallNonvirtualDoubleMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualDoubleMethod(obj, clazz, methodID).doubleFloat;

  late final _CallNonvirtualDoubleMethodA = ptr.ref.CallNonvirtualDoubleMethodA
      .asFunction<
          JniResult Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJDoubleMarker CallNonvirtualDoubleMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualDoubleMethodA(obj, clazz, methodID, args).doubleFloat;

  late final _CallNonvirtualVoidMethod = ptr.ref.CallNonvirtualVoidMethod
      .asFunction<
          JThrowablePtr Function(
              JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID)>();

  void CallNonvirtualVoidMethod(
          JObjectPtr obj, JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallNonvirtualVoidMethod(obj, clazz, methodID).check();

  late final _CallNonvirtualVoidMethodA = ptr.ref.CallNonvirtualVoidMethodA
      .asFunction<
          JThrowablePtr Function(JObjectPtr obj, JClassPtr clazz,
              JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  void CallNonvirtualVoidMethodA(JObjectPtr obj, JClassPtr clazz,
          JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallNonvirtualVoidMethodA(obj, clazz, methodID, args).check();

  late final _GetFieldID = ptr.ref.GetFieldID.asFunction<
      JniPointerResult Function(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig)>(isLeaf: true);

  JFieldIDPtr GetFieldID(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig) =>
      _GetFieldID(clazz, name, sig).fieldID;

  late final _GetObjectField = ptr.ref.GetObjectField
      .asFunction<JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID)>(
          isLeaf: true);

  JObjectPtr GetObjectField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      _GetObjectField(obj, fieldID).objectPointer;

  late final _GetBooleanField = ptr.ref.GetBooleanField
      .asFunction<JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID)>(
          isLeaf: true);

  bool GetBooleanField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      _GetBooleanField(obj, fieldID).boolean;

  late final _GetByteField = ptr.ref.GetByteField
      .asFunction<JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJByteMarker GetByteField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      _GetByteField(obj, fieldID).byte;

  late final _GetCharField = ptr.ref.GetCharField
      .asFunction<JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJCharMarker GetCharField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      _GetCharField(obj, fieldID).char;

  late final _GetShortField = ptr.ref.GetShortField
      .asFunction<JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJShortMarker GetShortField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      _GetShortField(obj, fieldID).short;

  late final _GetIntField = ptr.ref.GetIntField
      .asFunction<JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJIntMarker GetIntField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      _GetIntField(obj, fieldID).integer;

  late final _GetLongField = ptr.ref.GetLongField
      .asFunction<JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJLongMarker GetLongField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      _GetLongField(obj, fieldID).long;

  late final _GetFloatField = ptr.ref.GetFloatField
      .asFunction<JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJFloatMarker GetFloatField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      _GetFloatField(obj, fieldID).float;

  late final _GetDoubleField = ptr.ref.GetDoubleField
      .asFunction<JniResult Function(JObjectPtr obj, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJDoubleMarker GetDoubleField(JObjectPtr obj, JFieldIDPtr fieldID) =>
      _GetDoubleField(obj, fieldID).doubleFloat;

  late final _SetObjectField = ptr.ref.SetObjectField.asFunction<
      JThrowablePtr Function(
          JObjectPtr obj, JFieldIDPtr fieldID, JObjectPtr val)>(isLeaf: true);

  void SetObjectField(JObjectPtr obj, JFieldIDPtr fieldID, JObjectPtr val) =>
      _SetObjectField(obj, fieldID, val).check();

  late final _SetBooleanField = ptr.ref.SetBooleanField.asFunction<
      JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
          DartJBooleanMarker val)>(isLeaf: true);

  void SetBooleanField(
          JObjectPtr obj, JFieldIDPtr fieldID, DartJBooleanMarker val) =>
      _SetBooleanField(obj, fieldID, val).check();

  late final _SetByteField = ptr.ref.SetByteField.asFunction<
      JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
          DartJByteMarker val)>(isLeaf: true);

  void SetByteField(JObjectPtr obj, JFieldIDPtr fieldID, DartJByteMarker val) =>
      _SetByteField(obj, fieldID, val).check();

  late final _SetCharField = ptr.ref.SetCharField.asFunction<
      JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
          DartJCharMarker val)>(isLeaf: true);

  void SetCharField(JObjectPtr obj, JFieldIDPtr fieldID, DartJCharMarker val) =>
      _SetCharField(obj, fieldID, val).check();

  late final _SetShortField = ptr.ref.SetShortField.asFunction<
      JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
          DartJShortMarker val)>(isLeaf: true);

  void SetShortField(
          JObjectPtr obj, JFieldIDPtr fieldID, DartJShortMarker val) =>
      _SetShortField(obj, fieldID, val).check();

  late final _SetIntField = ptr.ref.SetIntField.asFunction<
      JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
          DartJIntMarker val)>(isLeaf: true);

  void SetIntField(JObjectPtr obj, JFieldIDPtr fieldID, DartJIntMarker val) =>
      _SetIntField(obj, fieldID, val).check();

  late final _SetLongField = ptr.ref.SetLongField.asFunction<
      JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
          DartJLongMarker val)>(isLeaf: true);

  void SetLongField(JObjectPtr obj, JFieldIDPtr fieldID, DartJLongMarker val) =>
      _SetLongField(obj, fieldID, val).check();

  late final _SetFloatField = ptr.ref.SetFloatField.asFunction<
      JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
          DartJFloatMarker val)>(isLeaf: true);

  void SetFloatField(
          JObjectPtr obj, JFieldIDPtr fieldID, DartJFloatMarker val) =>
      _SetFloatField(obj, fieldID, val).check();

  late final _SetDoubleField = ptr.ref.SetDoubleField.asFunction<
      JThrowablePtr Function(JObjectPtr obj, JFieldIDPtr fieldID,
          DartJDoubleMarker val)>(isLeaf: true);

  void SetDoubleField(
          JObjectPtr obj, JFieldIDPtr fieldID, DartJDoubleMarker val) =>
      _SetDoubleField(obj, fieldID, val).check();

  late final _GetStaticMethodID = ptr.ref.GetStaticMethodID.asFunction<
      JniPointerResult Function(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig)>(isLeaf: true);

  JMethodIDPtr GetStaticMethodID(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig) =>
      _GetStaticMethodID(clazz, name, sig).methodID;

  late final _CallStaticObjectMethod = ptr.ref.CallStaticObjectMethod
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  JObjectPtr CallStaticObjectMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticObjectMethod(clazz, methodID).objectPointer;

  late final _CallStaticObjectMethodA = ptr.ref.CallStaticObjectMethodA
      .asFunction<
          JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
              ffi.Pointer<JValue> args)>();

  JObjectPtr CallStaticObjectMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticObjectMethodA(clazz, methodID, args).objectPointer;

  late final _CallStaticBooleanMethod = ptr.ref.CallStaticBooleanMethod
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  bool CallStaticBooleanMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticBooleanMethod(clazz, methodID).boolean;

  late final _CallStaticBooleanMethodA = ptr.ref.CallStaticBooleanMethodA
      .asFunction<
          JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
              ffi.Pointer<JValue> args)>();

  bool CallStaticBooleanMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticBooleanMethodA(clazz, methodID, args).boolean;

  late final _CallStaticByteMethod = ptr.ref.CallStaticByteMethod
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJByteMarker CallStaticByteMethod(
          JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticByteMethod(clazz, methodID).byte;

  late final _CallStaticByteMethodA = ptr.ref.CallStaticByteMethodA.asFunction<
      JniResult Function(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJByteMarker CallStaticByteMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticByteMethodA(clazz, methodID, args).byte;

  late final _CallStaticCharMethod = ptr.ref.CallStaticCharMethod
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJCharMarker CallStaticCharMethod(
          JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticCharMethod(clazz, methodID).char;

  late final _CallStaticCharMethodA = ptr.ref.CallStaticCharMethodA.asFunction<
      JniResult Function(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJCharMarker CallStaticCharMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticCharMethodA(clazz, methodID, args).char;

  late final _CallStaticShortMethod = ptr.ref.CallStaticShortMethod
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJShortMarker CallStaticShortMethod(
          JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticShortMethod(clazz, methodID).short;

  late final _CallStaticShortMethodA = ptr.ref.CallStaticShortMethodA
      .asFunction<
          JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
              ffi.Pointer<JValue> args)>();

  DartJShortMarker CallStaticShortMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticShortMethodA(clazz, methodID, args).short;

  late final _CallStaticIntMethod = ptr.ref.CallStaticIntMethod
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJIntMarker CallStaticIntMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticIntMethod(clazz, methodID).integer;

  late final _CallStaticIntMethodA = ptr.ref.CallStaticIntMethodA.asFunction<
      JniResult Function(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJIntMarker CallStaticIntMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticIntMethodA(clazz, methodID, args).integer;

  late final _CallStaticLongMethod = ptr.ref.CallStaticLongMethod
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJLongMarker CallStaticLongMethod(
          JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticLongMethod(clazz, methodID).long;

  late final _CallStaticLongMethodA = ptr.ref.CallStaticLongMethodA.asFunction<
      JniResult Function(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  DartJLongMarker CallStaticLongMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticLongMethodA(clazz, methodID, args).long;

  late final _CallStaticFloatMethod = ptr.ref.CallStaticFloatMethod
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJFloatMarker CallStaticFloatMethod(
          JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticFloatMethod(clazz, methodID).float;

  late final _CallStaticFloatMethodA = ptr.ref.CallStaticFloatMethodA
      .asFunction<
          JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
              ffi.Pointer<JValue> args)>();

  DartJFloatMarker CallStaticFloatMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticFloatMethodA(clazz, methodID, args).float;

  late final _CallStaticDoubleMethod = ptr.ref.CallStaticDoubleMethod
      .asFunction<JniResult Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  DartJDoubleMarker CallStaticDoubleMethod(
          JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticDoubleMethod(clazz, methodID).doubleFloat;

  late final _CallStaticDoubleMethodA = ptr.ref.CallStaticDoubleMethodA
      .asFunction<
          JniResult Function(JClassPtr clazz, JMethodIDPtr methodID,
              ffi.Pointer<JValue> args)>();

  DartJDoubleMarker CallStaticDoubleMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticDoubleMethodA(clazz, methodID, args).doubleFloat;

  late final _CallStaticVoidMethod = ptr.ref.CallStaticVoidMethod.asFunction<
      JThrowablePtr Function(JClassPtr clazz, JMethodIDPtr methodID)>();

  void CallStaticVoidMethod(JClassPtr clazz, JMethodIDPtr methodID) =>
      _CallStaticVoidMethod(clazz, methodID).check();

  late final _CallStaticVoidMethodA = ptr.ref.CallStaticVoidMethodA.asFunction<
      JThrowablePtr Function(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args)>();

  void CallStaticVoidMethodA(
          JClassPtr clazz, JMethodIDPtr methodID, ffi.Pointer<JValue> args) =>
      _CallStaticVoidMethodA(clazz, methodID, args).check();

  late final _GetStaticFieldID = ptr.ref.GetStaticFieldID.asFunction<
      JniPointerResult Function(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig)>(isLeaf: true);

  JFieldIDPtr GetStaticFieldID(JClassPtr clazz, ffi.Pointer<ffi.Char> name,
          ffi.Pointer<ffi.Char> sig) =>
      _GetStaticFieldID(clazz, name, sig).fieldID;

  late final _GetStaticObjectField = ptr.ref.GetStaticObjectField
      .asFunction<JniResult Function(JClassPtr clazz, JFieldIDPtr fieldID)>(
          isLeaf: true);

  JObjectPtr GetStaticObjectField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      _GetStaticObjectField(clazz, fieldID).objectPointer;

  late final _GetStaticBooleanField = ptr.ref.GetStaticBooleanField
      .asFunction<JniResult Function(JClassPtr clazz, JFieldIDPtr fieldID)>(
          isLeaf: true);

  bool GetStaticBooleanField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      _GetStaticBooleanField(clazz, fieldID).boolean;

  late final _GetStaticByteField = ptr.ref.GetStaticByteField
      .asFunction<JniResult Function(JClassPtr clazz, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJByteMarker GetStaticByteField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      _GetStaticByteField(clazz, fieldID).byte;

  late final _GetStaticCharField = ptr.ref.GetStaticCharField
      .asFunction<JniResult Function(JClassPtr clazz, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJCharMarker GetStaticCharField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      _GetStaticCharField(clazz, fieldID).char;

  late final _GetStaticShortField = ptr.ref.GetStaticShortField
      .asFunction<JniResult Function(JClassPtr clazz, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJShortMarker GetStaticShortField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      _GetStaticShortField(clazz, fieldID).short;

  late final _GetStaticIntField = ptr.ref.GetStaticIntField
      .asFunction<JniResult Function(JClassPtr clazz, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJIntMarker GetStaticIntField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      _GetStaticIntField(clazz, fieldID).integer;

  late final _GetStaticLongField = ptr.ref.GetStaticLongField
      .asFunction<JniResult Function(JClassPtr clazz, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJLongMarker GetStaticLongField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      _GetStaticLongField(clazz, fieldID).long;

  late final _GetStaticFloatField = ptr.ref.GetStaticFloatField
      .asFunction<JniResult Function(JClassPtr clazz, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJFloatMarker GetStaticFloatField(JClassPtr clazz, JFieldIDPtr fieldID) =>
      _GetStaticFloatField(clazz, fieldID).float;

  late final _GetStaticDoubleField = ptr.ref.GetStaticDoubleField
      .asFunction<JniResult Function(JClassPtr clazz, JFieldIDPtr fieldID)>(
          isLeaf: true);

  DartJDoubleMarker GetStaticDoubleField(
          JClassPtr clazz, JFieldIDPtr fieldID) =>
      _GetStaticDoubleField(clazz, fieldID).doubleFloat;

  late final _SetStaticObjectField = ptr.ref.SetStaticObjectField.asFunction<
      JThrowablePtr Function(
          JClassPtr clazz, JFieldIDPtr fieldID, JObjectPtr val)>(isLeaf: true);

  void SetStaticObjectField(
          JClassPtr clazz, JFieldIDPtr fieldID, JObjectPtr val) =>
      _SetStaticObjectField(clazz, fieldID, val).check();

  late final _SetStaticBooleanField = ptr.ref.SetStaticBooleanField.asFunction<
      JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
          DartJBooleanMarker val)>(isLeaf: true);

  void SetStaticBooleanField(
          JClassPtr clazz, JFieldIDPtr fieldID, DartJBooleanMarker val) =>
      _SetStaticBooleanField(clazz, fieldID, val).check();

  late final _SetStaticByteField = ptr.ref.SetStaticByteField.asFunction<
      JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
          DartJByteMarker val)>(isLeaf: true);

  void SetStaticByteField(
          JClassPtr clazz, JFieldIDPtr fieldID, DartJByteMarker val) =>
      _SetStaticByteField(clazz, fieldID, val).check();

  late final _SetStaticCharField = ptr.ref.SetStaticCharField.asFunction<
      JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
          DartJCharMarker val)>(isLeaf: true);

  void SetStaticCharField(
          JClassPtr clazz, JFieldIDPtr fieldID, DartJCharMarker val) =>
      _SetStaticCharField(clazz, fieldID, val).check();

  late final _SetStaticShortField = ptr.ref.SetStaticShortField.asFunction<
      JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
          DartJShortMarker val)>(isLeaf: true);

  void SetStaticShortField(
          JClassPtr clazz, JFieldIDPtr fieldID, DartJShortMarker val) =>
      _SetStaticShortField(clazz, fieldID, val).check();

  late final _SetStaticIntField = ptr.ref.SetStaticIntField.asFunction<
      JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
          DartJIntMarker val)>(isLeaf: true);

  void SetStaticIntField(
          JClassPtr clazz, JFieldIDPtr fieldID, DartJIntMarker val) =>
      _SetStaticIntField(clazz, fieldID, val).check();

  late final _SetStaticLongField = ptr.ref.SetStaticLongField.asFunction<
      JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
          DartJLongMarker val)>(isLeaf: true);

  void SetStaticLongField(
          JClassPtr clazz, JFieldIDPtr fieldID, DartJLongMarker val) =>
      _SetStaticLongField(clazz, fieldID, val).check();

  late final _SetStaticFloatField = ptr.ref.SetStaticFloatField.asFunction<
      JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
          DartJFloatMarker val)>(isLeaf: true);

  void SetStaticFloatField(
          JClassPtr clazz, JFieldIDPtr fieldID, DartJFloatMarker val) =>
      _SetStaticFloatField(clazz, fieldID, val).check();

  late final _SetStaticDoubleField = ptr.ref.SetStaticDoubleField.asFunction<
      JThrowablePtr Function(JClassPtr clazz, JFieldIDPtr fieldID,
          DartJDoubleMarker val)>(isLeaf: true);

  void SetStaticDoubleField(
          JClassPtr clazz, JFieldIDPtr fieldID, DartJDoubleMarker val) =>
      _SetStaticDoubleField(clazz, fieldID, val).check();

  late final _NewString = ptr.ref.NewString.asFunction<
      JniResult Function(
          ffi.Pointer<JCharMarker> unicodeChars, DartJIntMarker len)>();

  JStringPtr NewString(
          ffi.Pointer<JCharMarker> unicodeChars, DartJIntMarker len) =>
      _NewString(unicodeChars, len).objectPointer;

  late final _GetStringLength = ptr.ref.GetStringLength
      .asFunction<JniResult Function(JStringPtr string)>(isLeaf: true);

  DartJIntMarker GetStringLength(JStringPtr string) =>
      _GetStringLength(string).integer;

  late final _GetStringChars = ptr.ref.GetStringChars.asFunction<
      JniPointerResult Function(
          JStringPtr string, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JCharMarker> GetStringChars(
          JStringPtr string, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetStringChars(string, isCopy).getPointer<JCharMarker>();

  late final _ReleaseStringChars = ptr.ref.ReleaseStringChars.asFunction<
      JThrowablePtr Function(
          JStringPtr string, ffi.Pointer<JCharMarker> isCopy)>();

  void ReleaseStringChars(JStringPtr string, ffi.Pointer<JCharMarker> isCopy) =>
      _ReleaseStringChars(string, isCopy).check();

  late final _NewStringUTF = ptr.ref.NewStringUTF
      .asFunction<JniResult Function(ffi.Pointer<ffi.Char> bytes)>();

  JStringPtr NewStringUTF(ffi.Pointer<ffi.Char> bytes) =>
      _NewStringUTF(bytes).objectPointer;

  late final _GetStringUTFLength = ptr.ref.GetStringUTFLength
      .asFunction<JniResult Function(JStringPtr string)>(isLeaf: true);

  DartJIntMarker GetStringUTFLength(JStringPtr string) =>
      _GetStringUTFLength(string).integer;

  late final _GetStringUTFChars = ptr.ref.GetStringUTFChars.asFunction<
      JniPointerResult Function(
          JStringPtr string, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<ffi.Char> GetStringUTFChars(
          JStringPtr string, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetStringUTFChars(string, isCopy).getPointer<ffi.Char>();

  late final _ReleaseStringUTFChars = ptr.ref.ReleaseStringUTFChars.asFunction<
      JThrowablePtr Function(JStringPtr string, ffi.Pointer<ffi.Char> utf)>();

  void ReleaseStringUTFChars(JStringPtr string, ffi.Pointer<ffi.Char> utf) =>
      _ReleaseStringUTFChars(string, utf).check();

  late final _GetArrayLength = ptr.ref.GetArrayLength
      .asFunction<JniResult Function(JArrayPtr array)>(isLeaf: true);

  DartJIntMarker GetArrayLength(JArrayPtr array) =>
      _GetArrayLength(array).integer;

  late final _NewObjectArray = ptr.ref.NewObjectArray.asFunction<
      JniResult Function(DartJIntMarker length, JClassPtr elementClass,
          JObjectPtr initialElement)>();

  JObjectArrayPtr NewObjectArray(DartJIntMarker length, JClassPtr elementClass,
          JObjectPtr initialElement) =>
      _NewObjectArray(length, elementClass, initialElement).objectPointer;

  late final _GetObjectArrayElement = ptr.ref.GetObjectArrayElement.asFunction<
      JniResult Function(
          JObjectArrayPtr array, DartJIntMarker index)>(isLeaf: true);

  JObjectPtr GetObjectArrayElement(
          JObjectArrayPtr array, DartJIntMarker index) =>
      _GetObjectArrayElement(array, index).objectPointer;

  late final _SetObjectArrayElement = ptr.ref.SetObjectArrayElement.asFunction<
      JThrowablePtr Function(JObjectArrayPtr array, DartJIntMarker index,
          JObjectPtr val)>(isLeaf: true);

  void SetObjectArrayElement(
          JObjectArrayPtr array, DartJIntMarker index, JObjectPtr val) =>
      _SetObjectArrayElement(array, index, val).check();

  late final _NewBooleanArray = ptr.ref.NewBooleanArray
      .asFunction<JniResult Function(DartJIntMarker length)>();

  JBooleanArrayPtr NewBooleanArray(DartJIntMarker length) =>
      _NewBooleanArray(length).objectPointer;

  late final _NewByteArray = ptr.ref.NewByteArray
      .asFunction<JniResult Function(DartJIntMarker length)>();

  JByteArrayPtr NewByteArray(DartJIntMarker length) =>
      _NewByteArray(length).objectPointer;

  late final _NewCharArray = ptr.ref.NewCharArray
      .asFunction<JniResult Function(DartJIntMarker length)>();

  JCharArrayPtr NewCharArray(DartJIntMarker length) =>
      _NewCharArray(length).objectPointer;

  late final _NewShortArray = ptr.ref.NewShortArray
      .asFunction<JniResult Function(DartJIntMarker length)>();

  JShortArrayPtr NewShortArray(DartJIntMarker length) =>
      _NewShortArray(length).objectPointer;

  late final _NewIntArray = ptr.ref.NewIntArray
      .asFunction<JniResult Function(DartJIntMarker length)>();

  JIntArrayPtr NewIntArray(DartJIntMarker length) =>
      _NewIntArray(length).objectPointer;

  late final _NewLongArray = ptr.ref.NewLongArray
      .asFunction<JniResult Function(DartJIntMarker length)>();

  JLongArrayPtr NewLongArray(DartJIntMarker length) =>
      _NewLongArray(length).objectPointer;

  late final _NewFloatArray = ptr.ref.NewFloatArray
      .asFunction<JniResult Function(DartJIntMarker length)>();

  JFloatArrayPtr NewFloatArray(DartJIntMarker length) =>
      _NewFloatArray(length).objectPointer;

  late final _NewDoubleArray = ptr.ref.NewDoubleArray
      .asFunction<JniResult Function(DartJIntMarker length)>();

  JDoubleArrayPtr NewDoubleArray(DartJIntMarker length) =>
      _NewDoubleArray(length).objectPointer;

  late final _GetBooleanArrayElements = ptr.ref.GetBooleanArrayElements
      .asFunction<
          JniPointerResult Function(
              JBooleanArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JBooleanMarker> GetBooleanArrayElements(
          JBooleanArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetBooleanArrayElements(array, isCopy).getPointer<JBooleanMarker>();

  late final _GetByteArrayElements = ptr.ref.GetByteArrayElements.asFunction<
      JniPointerResult Function(
          JByteArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JByteMarker> GetByteArrayElements(
          JByteArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetByteArrayElements(array, isCopy).getPointer<JByteMarker>();

  late final _GetCharArrayElements = ptr.ref.GetCharArrayElements.asFunction<
      JniPointerResult Function(
          JCharArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JCharMarker> GetCharArrayElements(
          JCharArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetCharArrayElements(array, isCopy).getPointer<JCharMarker>();

  late final _GetShortArrayElements = ptr.ref.GetShortArrayElements.asFunction<
      JniPointerResult Function(
          JShortArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JShortMarker> GetShortArrayElements(
          JShortArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetShortArrayElements(array, isCopy).getPointer<JShortMarker>();

  late final _GetIntArrayElements = ptr.ref.GetIntArrayElements.asFunction<
      JniPointerResult Function(
          JIntArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JIntMarker> GetIntArrayElements(
          JIntArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetIntArrayElements(array, isCopy).getPointer<JIntMarker>();

  late final _GetLongArrayElements = ptr.ref.GetLongArrayElements.asFunction<
      JniPointerResult Function(
          JLongArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JLongMarker> GetLongArrayElements(
          JLongArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetLongArrayElements(array, isCopy).getPointer<JLongMarker>();

  late final _GetFloatArrayElements = ptr.ref.GetFloatArrayElements.asFunction<
      JniPointerResult Function(
          JFloatArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JFloatMarker> GetFloatArrayElements(
          JFloatArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetFloatArrayElements(array, isCopy).getPointer<JFloatMarker>();

  late final _GetDoubleArrayElements = ptr.ref.GetDoubleArrayElements
      .asFunction<
          JniPointerResult Function(
              JDoubleArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JDoubleMarker> GetDoubleArrayElements(
          JDoubleArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetDoubleArrayElements(array, isCopy).getPointer<JDoubleMarker>();

  late final _ReleaseBooleanArrayElements = ptr.ref.ReleaseBooleanArrayElements
      .asFunction<
          JThrowablePtr Function(JBooleanArrayPtr array,
              ffi.Pointer<JBooleanMarker> elems, DartJIntMarker mode)>();

  void ReleaseBooleanArrayElements(JBooleanArrayPtr array,
          ffi.Pointer<JBooleanMarker> elems, DartJIntMarker mode) =>
      _ReleaseBooleanArrayElements(array, elems, mode).check();

  late final _ReleaseByteArrayElements = ptr.ref.ReleaseByteArrayElements
      .asFunction<
          JThrowablePtr Function(JByteArrayPtr array,
              ffi.Pointer<JByteMarker> elems, DartJIntMarker mode)>();

  void ReleaseByteArrayElements(JByteArrayPtr array,
          ffi.Pointer<JByteMarker> elems, DartJIntMarker mode) =>
      _ReleaseByteArrayElements(array, elems, mode).check();

  late final _ReleaseCharArrayElements = ptr.ref.ReleaseCharArrayElements
      .asFunction<
          JThrowablePtr Function(JCharArrayPtr array,
              ffi.Pointer<JCharMarker> elems, DartJIntMarker mode)>();

  void ReleaseCharArrayElements(JCharArrayPtr array,
          ffi.Pointer<JCharMarker> elems, DartJIntMarker mode) =>
      _ReleaseCharArrayElements(array, elems, mode).check();

  late final _ReleaseShortArrayElements = ptr.ref.ReleaseShortArrayElements
      .asFunction<
          JThrowablePtr Function(JShortArrayPtr array,
              ffi.Pointer<JShortMarker> elems, DartJIntMarker mode)>();

  void ReleaseShortArrayElements(JShortArrayPtr array,
          ffi.Pointer<JShortMarker> elems, DartJIntMarker mode) =>
      _ReleaseShortArrayElements(array, elems, mode).check();

  late final _ReleaseIntArrayElements = ptr.ref.ReleaseIntArrayElements
      .asFunction<
          JThrowablePtr Function(JIntArrayPtr array,
              ffi.Pointer<JIntMarker> elems, DartJIntMarker mode)>();

  void ReleaseIntArrayElements(JIntArrayPtr array,
          ffi.Pointer<JIntMarker> elems, DartJIntMarker mode) =>
      _ReleaseIntArrayElements(array, elems, mode).check();

  late final _ReleaseLongArrayElements = ptr.ref.ReleaseLongArrayElements
      .asFunction<
          JThrowablePtr Function(JLongArrayPtr array,
              ffi.Pointer<JLongMarker> elems, DartJIntMarker mode)>();

  void ReleaseLongArrayElements(JLongArrayPtr array,
          ffi.Pointer<JLongMarker> elems, DartJIntMarker mode) =>
      _ReleaseLongArrayElements(array, elems, mode).check();

  late final _ReleaseFloatArrayElements = ptr.ref.ReleaseFloatArrayElements
      .asFunction<
          JThrowablePtr Function(JFloatArrayPtr array,
              ffi.Pointer<JFloatMarker> elems, DartJIntMarker mode)>();

  void ReleaseFloatArrayElements(JFloatArrayPtr array,
          ffi.Pointer<JFloatMarker> elems, DartJIntMarker mode) =>
      _ReleaseFloatArrayElements(array, elems, mode).check();

  late final _ReleaseDoubleArrayElements = ptr.ref.ReleaseDoubleArrayElements
      .asFunction<
          JThrowablePtr Function(JDoubleArrayPtr array,
              ffi.Pointer<JDoubleMarker> elems, DartJIntMarker mode)>();

  void ReleaseDoubleArrayElements(JDoubleArrayPtr array,
          ffi.Pointer<JDoubleMarker> elems, DartJIntMarker mode) =>
      _ReleaseDoubleArrayElements(array, elems, mode).check();

  late final _GetBooleanArrayRegion = ptr.ref.GetBooleanArrayRegion.asFunction<
      JThrowablePtr Function(JBooleanArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JBooleanMarker> buf)>();

  void GetBooleanArrayRegion(JBooleanArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JBooleanMarker> buf) =>
      _GetBooleanArrayRegion(array, start, len, buf).check();

  late final _GetByteArrayRegion = ptr.ref.GetByteArrayRegion.asFunction<
      JThrowablePtr Function(JByteArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JByteMarker> buf)>();

  void GetByteArrayRegion(JByteArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JByteMarker> buf) =>
      _GetByteArrayRegion(array, start, len, buf).check();

  late final _GetCharArrayRegion = ptr.ref.GetCharArrayRegion.asFunction<
      JThrowablePtr Function(JCharArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JCharMarker> buf)>();

  void GetCharArrayRegion(JCharArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JCharMarker> buf) =>
      _GetCharArrayRegion(array, start, len, buf).check();

  late final _GetShortArrayRegion = ptr.ref.GetShortArrayRegion.asFunction<
      JThrowablePtr Function(JShortArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JShortMarker> buf)>();

  void GetShortArrayRegion(JShortArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JShortMarker> buf) =>
      _GetShortArrayRegion(array, start, len, buf).check();

  late final _GetIntArrayRegion = ptr.ref.GetIntArrayRegion.asFunction<
      JThrowablePtr Function(JIntArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JIntMarker> buf)>();

  void GetIntArrayRegion(JIntArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JIntMarker> buf) =>
      _GetIntArrayRegion(array, start, len, buf).check();

  late final _GetLongArrayRegion = ptr.ref.GetLongArrayRegion.asFunction<
      JThrowablePtr Function(JLongArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JLongMarker> buf)>();

  void GetLongArrayRegion(JLongArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JLongMarker> buf) =>
      _GetLongArrayRegion(array, start, len, buf).check();

  late final _GetFloatArrayRegion = ptr.ref.GetFloatArrayRegion.asFunction<
      JThrowablePtr Function(JFloatArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JFloatMarker> buf)>();

  void GetFloatArrayRegion(JFloatArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JFloatMarker> buf) =>
      _GetFloatArrayRegion(array, start, len, buf).check();

  late final _GetDoubleArrayRegion = ptr.ref.GetDoubleArrayRegion.asFunction<
      JThrowablePtr Function(JDoubleArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JDoubleMarker> buf)>();

  void GetDoubleArrayRegion(JDoubleArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JDoubleMarker> buf) =>
      _GetDoubleArrayRegion(array, start, len, buf).check();

  late final _SetBooleanArrayRegion = ptr.ref.SetBooleanArrayRegion.asFunction<
      JThrowablePtr Function(JBooleanArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JBooleanMarker> buf)>();

  void SetBooleanArrayRegion(JBooleanArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JBooleanMarker> buf) =>
      _SetBooleanArrayRegion(array, start, len, buf).check();

  late final _SetByteArrayRegion = ptr.ref.SetByteArrayRegion.asFunction<
      JThrowablePtr Function(JByteArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JByteMarker> buf)>();

  void SetByteArrayRegion(JByteArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JByteMarker> buf) =>
      _SetByteArrayRegion(array, start, len, buf).check();

  late final _SetCharArrayRegion = ptr.ref.SetCharArrayRegion.asFunction<
      JThrowablePtr Function(JCharArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JCharMarker> buf)>();

  void SetCharArrayRegion(JCharArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JCharMarker> buf) =>
      _SetCharArrayRegion(array, start, len, buf).check();

  late final _SetShortArrayRegion = ptr.ref.SetShortArrayRegion.asFunction<
      JThrowablePtr Function(JShortArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JShortMarker> buf)>();

  void SetShortArrayRegion(JShortArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JShortMarker> buf) =>
      _SetShortArrayRegion(array, start, len, buf).check();

  late final _SetIntArrayRegion = ptr.ref.SetIntArrayRegion.asFunction<
      JThrowablePtr Function(JIntArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JIntMarker> buf)>();

  void SetIntArrayRegion(JIntArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JIntMarker> buf) =>
      _SetIntArrayRegion(array, start, len, buf).check();

  late final _SetLongArrayRegion = ptr.ref.SetLongArrayRegion.asFunction<
      JThrowablePtr Function(JLongArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JLongMarker> buf)>();

  void SetLongArrayRegion(JLongArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JLongMarker> buf) =>
      _SetLongArrayRegion(array, start, len, buf).check();

  late final _SetFloatArrayRegion = ptr.ref.SetFloatArrayRegion.asFunction<
      JThrowablePtr Function(JFloatArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JFloatMarker> buf)>();

  void SetFloatArrayRegion(JFloatArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JFloatMarker> buf) =>
      _SetFloatArrayRegion(array, start, len, buf).check();

  late final _SetDoubleArrayRegion = ptr.ref.SetDoubleArrayRegion.asFunction<
      JThrowablePtr Function(JDoubleArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JDoubleMarker> buf)>();

  void SetDoubleArrayRegion(JDoubleArrayPtr array, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JDoubleMarker> buf) =>
      _SetDoubleArrayRegion(array, start, len, buf).check();

  late final _RegisterNatives = ptr.ref.RegisterNatives.asFunction<
      JniResult Function(JClassPtr clazz, ffi.Pointer<JNINativeMethod> methods,
          DartJIntMarker nMethods)>();

  DartJIntMarker RegisterNatives(JClassPtr clazz,
          ffi.Pointer<JNINativeMethod> methods, DartJIntMarker nMethods) =>
      _RegisterNatives(clazz, methods, nMethods).integer;

  late final _UnregisterNatives = ptr.ref.UnregisterNatives
      .asFunction<JniResult Function(JClassPtr clazz)>();

  DartJIntMarker UnregisterNatives(JClassPtr clazz) =>
      _UnregisterNatives(clazz).integer;

  late final _MonitorEnter =
      ptr.ref.MonitorEnter.asFunction<JniResult Function(JObjectPtr obj)>();

  DartJIntMarker MonitorEnter(JObjectPtr obj) => _MonitorEnter(obj).integer;

  late final _MonitorExit =
      ptr.ref.MonitorExit.asFunction<JniResult Function(JObjectPtr obj)>();

  DartJIntMarker MonitorExit(JObjectPtr obj) => _MonitorExit(obj).integer;

  late final _GetJavaVM = ptr.ref.GetJavaVM
      .asFunction<JniResult Function(ffi.Pointer<ffi.Pointer<JavaVM>> vm)>(
          isLeaf: true);

  DartJIntMarker GetJavaVM(ffi.Pointer<ffi.Pointer<JavaVM>> vm) =>
      _GetJavaVM(vm).integer;

  late final _GetStringRegion = ptr.ref.GetStringRegion.asFunction<
      JThrowablePtr Function(JStringPtr str, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<JCharMarker> buf)>();

  void GetStringRegion(JStringPtr str, DartJIntMarker start, DartJIntMarker len,
          ffi.Pointer<JCharMarker> buf) =>
      _GetStringRegion(str, start, len, buf).check();

  late final _GetStringUTFRegion = ptr.ref.GetStringUTFRegion.asFunction<
      JThrowablePtr Function(JStringPtr str, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<ffi.Char> buf)>();

  void GetStringUTFRegion(JStringPtr str, DartJIntMarker start,
          DartJIntMarker len, ffi.Pointer<ffi.Char> buf) =>
      _GetStringUTFRegion(str, start, len, buf).check();

  late final _GetPrimitiveArrayCritical = ptr.ref.GetPrimitiveArrayCritical
      .asFunction<
          JniPointerResult Function(
              JArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<ffi.Void> GetPrimitiveArrayCritical(
          JArrayPtr array, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetPrimitiveArrayCritical(array, isCopy).getPointer<ffi.Void>();

  late final _ReleasePrimitiveArrayCritical =
      ptr.ref.ReleasePrimitiveArrayCritical.asFunction<
          JThrowablePtr Function(JArrayPtr array, ffi.Pointer<ffi.Void> carray,
              DartJIntMarker mode)>();

  void ReleasePrimitiveArrayCritical(
          JArrayPtr array, ffi.Pointer<ffi.Void> carray, DartJIntMarker mode) =>
      _ReleasePrimitiveArrayCritical(array, carray, mode).check();

  late final _GetStringCritical = ptr.ref.GetStringCritical.asFunction<
      JniPointerResult Function(
          JStringPtr str, ffi.Pointer<JBooleanMarker> isCopy)>();

  ffi.Pointer<JCharMarker> GetStringCritical(
          JStringPtr str, ffi.Pointer<JBooleanMarker> isCopy) =>
      _GetStringCritical(str, isCopy).getPointer<JCharMarker>();

  late final _ReleaseStringCritical = ptr.ref.ReleaseStringCritical.asFunction<
      JThrowablePtr Function(
          JStringPtr str, ffi.Pointer<JCharMarker> carray)>();

  void ReleaseStringCritical(JStringPtr str, ffi.Pointer<JCharMarker> carray) =>
      _ReleaseStringCritical(str, carray).check();

  late final _NewWeakGlobalRef = ptr.ref.NewWeakGlobalRef
      .asFunction<JniResult Function(JObjectPtr obj)>(isLeaf: true);

  JWeakPtr NewWeakGlobalRef(JObjectPtr obj) =>
      _NewWeakGlobalRef(obj).objectPointer;

  late final _DeleteWeakGlobalRef = ptr.ref.DeleteWeakGlobalRef
      .asFunction<JThrowablePtr Function(JWeakPtr obj)>(isLeaf: true);

  void DeleteWeakGlobalRef(JWeakPtr obj) => _DeleteWeakGlobalRef(obj).check();

  late final _ExceptionCheck =
      ptr.ref.ExceptionCheck.asFunction<JniResult Function()>(isLeaf: true);

  bool ExceptionCheck() => _ExceptionCheck().boolean;

  late final _NewDirectByteBuffer = ptr.ref.NewDirectByteBuffer.asFunction<
      JniResult Function(
          ffi.Pointer<ffi.Void> address, DartJLongMarker capacity)>();

  JObjectPtr NewDirectByteBuffer(
          ffi.Pointer<ffi.Void> address, DartJLongMarker capacity) =>
      _NewDirectByteBuffer(address, capacity).objectPointer;

  late final _GetDirectBufferAddress = ptr.ref.GetDirectBufferAddress
      .asFunction<JniPointerResult Function(JObjectPtr buf)>(isLeaf: true);

  ffi.Pointer<ffi.Void> GetDirectBufferAddress(JObjectPtr buf) =>
      _GetDirectBufferAddress(buf).getPointer<ffi.Void>();

  late final _GetDirectBufferCapacity = ptr.ref.GetDirectBufferCapacity
      .asFunction<JniResult Function(JObjectPtr buf)>(isLeaf: true);

  DartJLongMarker GetDirectBufferCapacity(JObjectPtr buf) =>
      _GetDirectBufferCapacity(buf).long;

  late final _GetObjectRefType = ptr.ref.GetObjectRefType
      .asFunction<JniResult Function(JObjectPtr obj)>(isLeaf: true);

  JObjectRefType GetObjectRefType(JObjectPtr obj) =>
      _GetObjectRefType(obj).referenceType;

  late final _GetBooleanArrayElement = ptr.ref.GetBooleanArrayElement
      .asFunction<JniResult Function(JBooleanArrayPtr array, int index)>(
          isLeaf: true);

  bool GetBooleanArrayElement(JBooleanArrayPtr array, int index) =>
      _GetBooleanArrayElement(array, index).boolean;

  late final _SetBooleanArrayElement = ptr.ref.SetBooleanArrayElement
      .asFunction<
          JThrowablePtr Function(
              JBooleanArrayPtr array, int index, int val)>(isLeaf: true);

  void SetBooleanArrayElement(JBooleanArrayPtr array, int index, bool value) =>
      _SetBooleanArrayElement(array, index, value ? 1 : 0).check();

  late final _GetByteArrayElement = ptr.ref.GetByteArrayElement
      .asFunction<JniResult Function(JByteArrayPtr array, int index)>(
          isLeaf: true);

  int GetByteArrayElement(JByteArrayPtr array, int index) =>
      _GetByteArrayElement(array, index).byte;

  late final _SetByteArrayElement = ptr.ref.SetByteArrayElement.asFunction<
      JThrowablePtr Function(
          JByteArrayPtr array, int index, int val)>(isLeaf: true);

  void SetByteArrayElement(JByteArrayPtr array, int index, int value) =>
      _SetByteArrayElement(array, index, value).check();

  late final _GetCharArrayElement = ptr.ref.GetCharArrayElement
      .asFunction<JniResult Function(JCharArrayPtr array, int index)>(
          isLeaf: true);

  int GetCharArrayElement(JCharArrayPtr array, int index) =>
      _GetCharArrayElement(array, index).char;

  late final _SetCharArrayElement = ptr.ref.SetCharArrayElement.asFunction<
      JThrowablePtr Function(
          JCharArrayPtr array, int index, int val)>(isLeaf: true);

  void SetCharArrayElement(JCharArrayPtr array, int index, int value) =>
      _SetCharArrayElement(array, index, value).check();

  late final _GetShortArrayElement = ptr.ref.GetShortArrayElement
      .asFunction<JniResult Function(JShortArrayPtr array, int index)>(
          isLeaf: true);

  int GetShortArrayElement(JShortArrayPtr array, int index) =>
      _GetShortArrayElement(array, index).short;

  late final _SetShortArrayElement = ptr.ref.SetShortArrayElement.asFunction<
      JThrowablePtr Function(
          JShortArrayPtr array, int index, int val)>(isLeaf: true);

  void SetShortArrayElement(JShortArrayPtr array, int index, int value) =>
      _SetShortArrayElement(array, index, value).check();

  late final _GetIntArrayElement = ptr.ref.GetIntArrayElement
      .asFunction<JniResult Function(JIntArrayPtr array, int index)>(
          isLeaf: true);

  int GetIntArrayElement(JIntArrayPtr array, int index) =>
      _GetIntArrayElement(array, index).integer;

  late final _SetIntArrayElement = ptr.ref.SetIntArrayElement.asFunction<
      JThrowablePtr Function(
          JIntArrayPtr array, int index, int val)>(isLeaf: true);

  void SetIntArrayElement(JIntArrayPtr array, int index, int value) =>
      _SetIntArrayElement(array, index, value).check();

  late final _GetLongArrayElement = ptr.ref.GetLongArrayElement
      .asFunction<JniResult Function(JLongArrayPtr array, int index)>(
          isLeaf: true);

  int GetLongArrayElement(JLongArrayPtr array, int index) =>
      _GetLongArrayElement(array, index).long;

  late final _SetLongArrayElement = ptr.ref.SetLongArrayElement.asFunction<
      JThrowablePtr Function(
          JLongArrayPtr array, int index, int val)>(isLeaf: true);

  void SetLongArrayElement(JLongArrayPtr array, int index, int value) =>
      _SetLongArrayElement(array, index, value).check();

  late final _GetFloatArrayElement = ptr.ref.GetFloatArrayElement
      .asFunction<JniResult Function(JFloatArrayPtr array, int index)>(
          isLeaf: true);

  double GetFloatArrayElement(JFloatArrayPtr array, int index) =>
      _GetFloatArrayElement(array, index).float;

  late final _SetFloatArrayElement = ptr.ref.SetFloatArrayElement.asFunction<
      JThrowablePtr Function(
          JFloatArrayPtr array, int index, double val)>(isLeaf: true);

  void SetFloatArrayElement(JFloatArrayPtr array, int index, double value) =>
      _SetFloatArrayElement(array, index, value).check();

  late final _GetDoubleArrayElement = ptr.ref.GetDoubleArrayElement
      .asFunction<JniResult Function(JDoubleArrayPtr array, int index)>(
          isLeaf: true);

  double GetDoubleArrayElement(JDoubleArrayPtr array, int index) =>
      _GetDoubleArrayElement(array, index).doubleFloat;

  late final _SetDoubleArrayElement = ptr.ref.SetDoubleArrayElement.asFunction<
      JThrowablePtr Function(
          JDoubleArrayPtr array, int index, double val)>(isLeaf: true);

  void SetDoubleArrayElement(JDoubleArrayPtr array, int index, double value) =>
      _SetDoubleArrayElement(array, index, value).check();
}
