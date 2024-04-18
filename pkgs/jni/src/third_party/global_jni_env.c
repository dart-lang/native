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

#include "global_jni_env.h"

JniResult globalEnv_GetVersion() {
  attach_thread();
  jint _result = (*jniEnv)->GetVersion(jniEnv);
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniClassLookupResult globalEnv_DefineClass(char* name,
                                           jobject loader,
                                           jbyte* buf,
                                           jsize bufLen) {
  attach_thread();
  jclass _result = (*jniEnv)->DefineClass(jniEnv, name, loader, buf, bufLen);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniClassLookupResult){.value = NULL, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniClassLookupResult){.value = _result, .exception = NULL};
}

JniClassLookupResult globalEnv_FindClass(char* name) {
  attach_thread();
  jclass _result = (*jniEnv)->FindClass(jniEnv, name);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniClassLookupResult){.value = NULL, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniClassLookupResult){.value = _result, .exception = NULL};
}

JniPointerResult globalEnv_FromReflectedMethod(jobject method) {
  attach_thread();
  jmethodID _result = (*jniEnv)->FromReflectedMethod(jniEnv, method);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniPointerResult globalEnv_FromReflectedField(jobject field) {
  attach_thread();
  jfieldID _result = (*jniEnv)->FromReflectedField(jniEnv, field);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniResult globalEnv_ToReflectedMethod(jclass cls,
                                      jmethodID methodId,
                                      jboolean isStatic) {
  attach_thread();
  jobject _result =
      (*jniEnv)->ToReflectedMethod(jniEnv, cls, methodId, isStatic);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniClassLookupResult globalEnv_GetSuperclass(jclass clazz) {
  attach_thread();
  jclass _result = (*jniEnv)->GetSuperclass(jniEnv, clazz);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniClassLookupResult){.value = NULL, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniClassLookupResult){.value = _result, .exception = NULL};
}

JniResult globalEnv_IsAssignableFrom(jclass clazz1, jclass clazz2) {
  attach_thread();
  jboolean _result = (*jniEnv)->IsAssignableFrom(jniEnv, clazz1, clazz2);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

JniResult globalEnv_ToReflectedField(jclass cls,
                                     jfieldID fieldID,
                                     jboolean isStatic) {
  attach_thread();
  jobject _result = (*jniEnv)->ToReflectedField(jniEnv, cls, fieldID, isStatic);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_Throw(jthrowable obj) {
  attach_thread();
  jint _result = (*jniEnv)->Throw(jniEnv, obj);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_ThrowNew(jclass clazz, char* message) {
  attach_thread();
  jint _result = (*jniEnv)->ThrowNew(jniEnv, clazz, message);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_ExceptionOccurred() {
  attach_thread();
  jthrowable _result = (*jniEnv)->ExceptionOccurred(jniEnv);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

jthrowable globalEnv_ExceptionDescribe() {
  attach_thread();
  (*jniEnv)->ExceptionDescribe(jniEnv);
  return NULL;
}

jthrowable globalEnv_ExceptionClear() {
  attach_thread();
  (*jniEnv)->ExceptionClear(jniEnv);
  return NULL;
}

jthrowable globalEnv_FatalError(char* msg) {
  attach_thread();
  (*jniEnv)->FatalError(jniEnv, msg);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniResult globalEnv_PushLocalFrame(jint capacity) {
  attach_thread();
  jint _result = (*jniEnv)->PushLocalFrame(jniEnv, capacity);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_PopLocalFrame(jobject result) {
  attach_thread();
  jobject _result = (*jniEnv)->PopLocalFrame(jniEnv, result);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_NewGlobalRef(jobject obj) {
  attach_thread();
  jobject _result = (*jniEnv)->NewGlobalRef(jniEnv, obj);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

jthrowable globalEnv_DeleteGlobalRef(jobject globalRef) {
  attach_thread();
  (*jniEnv)->DeleteGlobalRef(jniEnv, globalRef);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_DeleteLocalRef(jobject localRef) {
  attach_thread();
  (*jniEnv)->DeleteLocalRef(jniEnv, localRef);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniResult globalEnv_IsSameObject(jobject ref1, jobject ref2) {
  attach_thread();
  jboolean _result = (*jniEnv)->IsSameObject(jniEnv, ref1, ref2);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

JniResult globalEnv_NewLocalRef(jobject obj) {
  attach_thread();
  jobject _result = (*jniEnv)->NewLocalRef(jniEnv, obj);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_EnsureLocalCapacity(jint capacity) {
  attach_thread();
  jint _result = (*jniEnv)->EnsureLocalCapacity(jniEnv, capacity);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_AllocObject(jclass clazz) {
  attach_thread();
  jobject _result = (*jniEnv)->AllocObject(jniEnv, clazz);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_NewObject(jclass clazz,
                                                jmethodID methodID,
                                                ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jobject _result = (*jniEnv)->NewObjectV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_NewObjectA(jclass clazz, jmethodID methodID, jvalue* args) {
  attach_thread();
  jobject _result = (*jniEnv)->NewObjectA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniClassLookupResult globalEnv_GetObjectClass(jobject obj) {
  attach_thread();
  jclass _result = (*jniEnv)->GetObjectClass(jniEnv, obj);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniClassLookupResult){.value = NULL, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniClassLookupResult){.value = _result, .exception = NULL};
}

JniResult globalEnv_IsInstanceOf(jobject obj, jclass clazz) {
  attach_thread();
  jboolean _result = (*jniEnv)->IsInstanceOf(jniEnv, obj, clazz);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

JniPointerResult globalEnv_GetMethodID(jclass clazz, char* name, char* sig) {
  attach_thread();
  jmethodID _result = (*jniEnv)->GetMethodID(jniEnv, clazz, name, sig);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallObjectMethod(jobject obj,
                                                       jmethodID methodID,
                                                       ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jobject _result = (*jniEnv)->CallObjectMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_CallObjectMethodA(jobject obj,
                                      jmethodID methodID,
                                      jvalue* args) {
  attach_thread();
  jobject _result = (*jniEnv)->CallObjectMethodA(jniEnv, obj, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallBooleanMethod(jobject obj,
                                                        jmethodID methodID,
                                                        ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jboolean _result = (*jniEnv)->CallBooleanMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

JniResult globalEnv_CallBooleanMethodA(jobject obj,
                                       jmethodID methodId,
                                       jvalue* args) {
  attach_thread();
  jboolean _result = (*jniEnv)->CallBooleanMethodA(jniEnv, obj, methodId, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallByteMethod(jobject obj,
                                                     jmethodID methodID,
                                                     ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jbyte _result = (*jniEnv)->CallByteMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.b = _result}, .exception = NULL};
}

JniResult globalEnv_CallByteMethodA(jobject obj,
                                    jmethodID methodID,
                                    jvalue* args) {
  attach_thread();
  jbyte _result = (*jniEnv)->CallByteMethodA(jniEnv, obj, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.b = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallCharMethod(jobject obj,
                                                     jmethodID methodID,
                                                     ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jchar _result = (*jniEnv)->CallCharMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.c = _result}, .exception = NULL};
}

JniResult globalEnv_CallCharMethodA(jobject obj,
                                    jmethodID methodID,
                                    jvalue* args) {
  attach_thread();
  jchar _result = (*jniEnv)->CallCharMethodA(jniEnv, obj, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.c = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallShortMethod(jobject obj,
                                                      jmethodID methodID,
                                                      ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jshort _result = (*jniEnv)->CallShortMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.s = _result}, .exception = NULL};
}

JniResult globalEnv_CallShortMethodA(jobject obj,
                                     jmethodID methodID,
                                     jvalue* args) {
  attach_thread();
  jshort _result = (*jniEnv)->CallShortMethodA(jniEnv, obj, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.s = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallIntMethod(jobject obj,
                                                    jmethodID methodID,
                                                    ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jint _result = (*jniEnv)->CallIntMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_CallIntMethodA(jobject obj,
                                   jmethodID methodID,
                                   jvalue* args) {
  attach_thread();
  jint _result = (*jniEnv)->CallIntMethodA(jniEnv, obj, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallLongMethod(jobject obj,
                                                     jmethodID methodID,
                                                     ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jlong _result = (*jniEnv)->CallLongMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.j = _result}, .exception = NULL};
}

JniResult globalEnv_CallLongMethodA(jobject obj,
                                    jmethodID methodID,
                                    jvalue* args) {
  attach_thread();
  jlong _result = (*jniEnv)->CallLongMethodA(jniEnv, obj, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.j = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallFloatMethod(jobject obj,
                                                      jmethodID methodID,
                                                      ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jfloat _result = (*jniEnv)->CallFloatMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.f = _result}, .exception = NULL};
}

JniResult globalEnv_CallFloatMethodA(jobject obj,
                                     jmethodID methodID,
                                     jvalue* args) {
  attach_thread();
  jfloat _result = (*jniEnv)->CallFloatMethodA(jniEnv, obj, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.f = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallDoubleMethod(jobject obj,
                                                       jmethodID methodID,
                                                       ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jdouble _result = (*jniEnv)->CallDoubleMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.d = _result}, .exception = NULL};
}

JniResult globalEnv_CallDoubleMethodA(jobject obj,
                                      jmethodID methodID,
                                      jvalue* args) {
  attach_thread();
  jdouble _result = (*jniEnv)->CallDoubleMethodA(jniEnv, obj, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.d = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT jthrowable globalEnv_CallVoidMethod(jobject obj,
                                                      jmethodID methodID,
                                                      ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  (*jniEnv)->CallVoidMethodV(jniEnv, obj, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_CallVoidMethodA(jobject obj,
                                     jmethodID methodID,
                                     jvalue* args) {
  attach_thread();
  (*jniEnv)->CallVoidMethodA(jniEnv, obj, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualObjectMethod(jobject obj,
                                     jclass clazz,
                                     jmethodID methodID,
                                     ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jobject _result = (*jniEnv)->CallNonvirtualObjectMethodV(jniEnv, obj, clazz,
                                                           methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_CallNonvirtualObjectMethodA(jobject obj,
                                                jclass clazz,
                                                jmethodID methodID,
                                                jvalue* args) {
  attach_thread();
  jobject _result = (*jniEnv)->CallNonvirtualObjectMethodA(jniEnv, obj, clazz,
                                                           methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualBooleanMethod(jobject obj,
                                      jclass clazz,
                                      jmethodID methodID,
                                      ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jboolean _result = (*jniEnv)->CallNonvirtualBooleanMethodV(jniEnv, obj, clazz,
                                                             methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

JniResult globalEnv_CallNonvirtualBooleanMethodA(jobject obj,
                                                 jclass clazz,
                                                 jmethodID methodID,
                                                 jvalue* args) {
  attach_thread();
  jboolean _result = (*jniEnv)->CallNonvirtualBooleanMethodA(jniEnv, obj, clazz,
                                                             methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualByteMethod(jobject obj,
                                   jclass clazz,
                                   jmethodID methodID,
                                   ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jbyte _result =
      (*jniEnv)->CallNonvirtualByteMethodV(jniEnv, obj, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.b = _result}, .exception = NULL};
}

JniResult globalEnv_CallNonvirtualByteMethodA(jobject obj,
                                              jclass clazz,
                                              jmethodID methodID,
                                              jvalue* args) {
  attach_thread();
  jbyte _result =
      (*jniEnv)->CallNonvirtualByteMethodA(jniEnv, obj, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.b = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualCharMethod(jobject obj,
                                   jclass clazz,
                                   jmethodID methodID,
                                   ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jchar _result =
      (*jniEnv)->CallNonvirtualCharMethodV(jniEnv, obj, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.c = _result}, .exception = NULL};
}

JniResult globalEnv_CallNonvirtualCharMethodA(jobject obj,
                                              jclass clazz,
                                              jmethodID methodID,
                                              jvalue* args) {
  attach_thread();
  jchar _result =
      (*jniEnv)->CallNonvirtualCharMethodA(jniEnv, obj, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.c = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualShortMethod(jobject obj,
                                    jclass clazz,
                                    jmethodID methodID,
                                    ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jshort _result =
      (*jniEnv)->CallNonvirtualShortMethodV(jniEnv, obj, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.s = _result}, .exception = NULL};
}

JniResult globalEnv_CallNonvirtualShortMethodA(jobject obj,
                                               jclass clazz,
                                               jmethodID methodID,
                                               jvalue* args) {
  attach_thread();
  jshort _result =
      (*jniEnv)->CallNonvirtualShortMethodA(jniEnv, obj, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.s = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualIntMethod(jobject obj,
                                  jclass clazz,
                                  jmethodID methodID,
                                  ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jint _result =
      (*jniEnv)->CallNonvirtualIntMethodV(jniEnv, obj, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_CallNonvirtualIntMethodA(jobject obj,
                                             jclass clazz,
                                             jmethodID methodID,
                                             jvalue* args) {
  attach_thread();
  jint _result =
      (*jniEnv)->CallNonvirtualIntMethodA(jniEnv, obj, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualLongMethod(jobject obj,
                                   jclass clazz,
                                   jmethodID methodID,
                                   ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jlong _result =
      (*jniEnv)->CallNonvirtualLongMethodV(jniEnv, obj, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.j = _result}, .exception = NULL};
}

JniResult globalEnv_CallNonvirtualLongMethodA(jobject obj,
                                              jclass clazz,
                                              jmethodID methodID,
                                              jvalue* args) {
  attach_thread();
  jlong _result =
      (*jniEnv)->CallNonvirtualLongMethodA(jniEnv, obj, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.j = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualFloatMethod(jobject obj,
                                    jclass clazz,
                                    jmethodID methodID,
                                    ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jfloat _result =
      (*jniEnv)->CallNonvirtualFloatMethodV(jniEnv, obj, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.f = _result}, .exception = NULL};
}

JniResult globalEnv_CallNonvirtualFloatMethodA(jobject obj,
                                               jclass clazz,
                                               jmethodID methodID,
                                               jvalue* args) {
  attach_thread();
  jfloat _result =
      (*jniEnv)->CallNonvirtualFloatMethodA(jniEnv, obj, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.f = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualDoubleMethod(jobject obj,
                                     jclass clazz,
                                     jmethodID methodID,
                                     ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jdouble _result = (*jniEnv)->CallNonvirtualDoubleMethodV(jniEnv, obj, clazz,
                                                           methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.d = _result}, .exception = NULL};
}

JniResult globalEnv_CallNonvirtualDoubleMethodA(jobject obj,
                                                jclass clazz,
                                                jmethodID methodID,
                                                jvalue* args) {
  attach_thread();
  jdouble _result = (*jniEnv)->CallNonvirtualDoubleMethodA(jniEnv, obj, clazz,
                                                           methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.d = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT jthrowable
globalEnv_CallNonvirtualVoidMethod(jobject obj,
                                   jclass clazz,
                                   jmethodID methodID,
                                   ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  (*jniEnv)->CallNonvirtualVoidMethodV(jniEnv, obj, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_CallNonvirtualVoidMethodA(jobject obj,
                                               jclass clazz,
                                               jmethodID methodID,
                                               jvalue* args) {
  attach_thread();
  (*jniEnv)->CallNonvirtualVoidMethodA(jniEnv, obj, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniPointerResult globalEnv_GetFieldID(jclass clazz, char* name, char* sig) {
  attach_thread();
  jfieldID _result = (*jniEnv)->GetFieldID(jniEnv, clazz, name, sig);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniResult globalEnv_GetObjectField(jobject obj, jfieldID fieldID) {
  attach_thread();
  jobject _result = (*jniEnv)->GetObjectField(jniEnv, obj, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_GetBooleanField(jobject obj, jfieldID fieldID) {
  attach_thread();
  jboolean _result = (*jniEnv)->GetBooleanField(jniEnv, obj, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

JniResult globalEnv_GetByteField(jobject obj, jfieldID fieldID) {
  attach_thread();
  jbyte _result = (*jniEnv)->GetByteField(jniEnv, obj, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.b = _result}, .exception = NULL};
}

JniResult globalEnv_GetCharField(jobject obj, jfieldID fieldID) {
  attach_thread();
  jchar _result = (*jniEnv)->GetCharField(jniEnv, obj, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.c = _result}, .exception = NULL};
}

JniResult globalEnv_GetShortField(jobject obj, jfieldID fieldID) {
  attach_thread();
  jshort _result = (*jniEnv)->GetShortField(jniEnv, obj, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.s = _result}, .exception = NULL};
}

JniResult globalEnv_GetIntField(jobject obj, jfieldID fieldID) {
  attach_thread();
  jint _result = (*jniEnv)->GetIntField(jniEnv, obj, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_GetLongField(jobject obj, jfieldID fieldID) {
  attach_thread();
  jlong _result = (*jniEnv)->GetLongField(jniEnv, obj, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.j = _result}, .exception = NULL};
}

JniResult globalEnv_GetFloatField(jobject obj, jfieldID fieldID) {
  attach_thread();
  jfloat _result = (*jniEnv)->GetFloatField(jniEnv, obj, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.f = _result}, .exception = NULL};
}

JniResult globalEnv_GetDoubleField(jobject obj, jfieldID fieldID) {
  attach_thread();
  jdouble _result = (*jniEnv)->GetDoubleField(jniEnv, obj, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.d = _result}, .exception = NULL};
}

jthrowable globalEnv_SetObjectField(jobject obj,
                                    jfieldID fieldID,
                                    jobject val) {
  attach_thread();
  (*jniEnv)->SetObjectField(jniEnv, obj, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetBooleanField(jobject obj,
                                     jfieldID fieldID,
                                     jboolean val) {
  attach_thread();
  (*jniEnv)->SetBooleanField(jniEnv, obj, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetByteField(jobject obj, jfieldID fieldID, jbyte val) {
  attach_thread();
  (*jniEnv)->SetByteField(jniEnv, obj, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetCharField(jobject obj, jfieldID fieldID, jchar val) {
  attach_thread();
  (*jniEnv)->SetCharField(jniEnv, obj, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetShortField(jobject obj, jfieldID fieldID, jshort val) {
  attach_thread();
  (*jniEnv)->SetShortField(jniEnv, obj, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetIntField(jobject obj, jfieldID fieldID, jint val) {
  attach_thread();
  (*jniEnv)->SetIntField(jniEnv, obj, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetLongField(jobject obj, jfieldID fieldID, jlong val) {
  attach_thread();
  (*jniEnv)->SetLongField(jniEnv, obj, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetFloatField(jobject obj, jfieldID fieldID, jfloat val) {
  attach_thread();
  (*jniEnv)->SetFloatField(jniEnv, obj, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetDoubleField(jobject obj,
                                    jfieldID fieldID,
                                    jdouble val) {
  attach_thread();
  (*jniEnv)->SetDoubleField(jniEnv, obj, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniPointerResult globalEnv_GetStaticMethodID(jclass clazz,
                                             char* name,
                                             char* sig) {
  attach_thread();
  jmethodID _result = (*jniEnv)->GetStaticMethodID(jniEnv, clazz, name, sig);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticObjectMethod(jclass clazz,
                                                             jmethodID methodID,
                                                             ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jobject _result =
      (*jniEnv)->CallStaticObjectMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_CallStaticObjectMethodA(jclass clazz,
                                            jmethodID methodID,
                                            jvalue* args) {
  attach_thread();
  jobject _result =
      (*jniEnv)->CallStaticObjectMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult
globalEnv_CallStaticBooleanMethod(jclass clazz, jmethodID methodID, ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jboolean _result =
      (*jniEnv)->CallStaticBooleanMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

JniResult globalEnv_CallStaticBooleanMethodA(jclass clazz,
                                             jmethodID methodID,
                                             jvalue* args) {
  attach_thread();
  jboolean _result =
      (*jniEnv)->CallStaticBooleanMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticByteMethod(jclass clazz,
                                                           jmethodID methodID,
                                                           ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jbyte _result =
      (*jniEnv)->CallStaticByteMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.b = _result}, .exception = NULL};
}

JniResult globalEnv_CallStaticByteMethodA(jclass clazz,
                                          jmethodID methodID,
                                          jvalue* args) {
  attach_thread();
  jbyte _result =
      (*jniEnv)->CallStaticByteMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.b = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticCharMethod(jclass clazz,
                                                           jmethodID methodID,
                                                           ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jchar _result =
      (*jniEnv)->CallStaticCharMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.c = _result}, .exception = NULL};
}

JniResult globalEnv_CallStaticCharMethodA(jclass clazz,
                                          jmethodID methodID,
                                          jvalue* args) {
  attach_thread();
  jchar _result =
      (*jniEnv)->CallStaticCharMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.c = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticShortMethod(jclass clazz,
                                                            jmethodID methodID,
                                                            ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jshort _result =
      (*jniEnv)->CallStaticShortMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.s = _result}, .exception = NULL};
}

JniResult globalEnv_CallStaticShortMethodA(jclass clazz,
                                           jmethodID methodID,
                                           jvalue* args) {
  attach_thread();
  jshort _result =
      (*jniEnv)->CallStaticShortMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.s = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticIntMethod(jclass clazz,
                                                          jmethodID methodID,
                                                          ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jint _result = (*jniEnv)->CallStaticIntMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_CallStaticIntMethodA(jclass clazz,
                                         jmethodID methodID,
                                         jvalue* args) {
  attach_thread();
  jint _result = (*jniEnv)->CallStaticIntMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticLongMethod(jclass clazz,
                                                           jmethodID methodID,
                                                           ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jlong _result =
      (*jniEnv)->CallStaticLongMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.j = _result}, .exception = NULL};
}

JniResult globalEnv_CallStaticLongMethodA(jclass clazz,
                                          jmethodID methodID,
                                          jvalue* args) {
  attach_thread();
  jlong _result =
      (*jniEnv)->CallStaticLongMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.j = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticFloatMethod(jclass clazz,
                                                            jmethodID methodID,
                                                            ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jfloat _result =
      (*jniEnv)->CallStaticFloatMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.f = _result}, .exception = NULL};
}

JniResult globalEnv_CallStaticFloatMethodA(jclass clazz,
                                           jmethodID methodID,
                                           jvalue* args) {
  attach_thread();
  jfloat _result =
      (*jniEnv)->CallStaticFloatMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.f = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticDoubleMethod(jclass clazz,
                                                             jmethodID methodID,
                                                             ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  jdouble _result =
      (*jniEnv)->CallStaticDoubleMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.d = _result}, .exception = NULL};
}

JniResult globalEnv_CallStaticDoubleMethodA(jclass clazz,
                                            jmethodID methodID,
                                            jvalue* args) {
  attach_thread();
  jdouble _result =
      (*jniEnv)->CallStaticDoubleMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.d = _result}, .exception = NULL};
}

FFI_PLUGIN_EXPORT jthrowable globalEnv_CallStaticVoidMethod(jclass clazz,
                                                            jmethodID methodID,
                                                            ...) {
  attach_thread();
  va_list args;
  va_start(args, methodID);
  (*jniEnv)->CallStaticVoidMethodV(jniEnv, clazz, methodID, args);
  va_end(args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_CallStaticVoidMethodA(jclass clazz,
                                           jmethodID methodID,
                                           jvalue* args) {
  attach_thread();
  (*jniEnv)->CallStaticVoidMethodA(jniEnv, clazz, methodID, args);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniPointerResult globalEnv_GetStaticFieldID(jclass clazz,
                                            char* name,
                                            char* sig) {
  attach_thread();
  jfieldID _result = (*jniEnv)->GetStaticFieldID(jniEnv, clazz, name, sig);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniResult globalEnv_GetStaticObjectField(jclass clazz, jfieldID fieldID) {
  attach_thread();
  jobject _result = (*jniEnv)->GetStaticObjectField(jniEnv, clazz, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_GetStaticBooleanField(jclass clazz, jfieldID fieldID) {
  attach_thread();
  jboolean _result = (*jniEnv)->GetStaticBooleanField(jniEnv, clazz, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

JniResult globalEnv_GetStaticByteField(jclass clazz, jfieldID fieldID) {
  attach_thread();
  jbyte _result = (*jniEnv)->GetStaticByteField(jniEnv, clazz, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.b = _result}, .exception = NULL};
}

JniResult globalEnv_GetStaticCharField(jclass clazz, jfieldID fieldID) {
  attach_thread();
  jchar _result = (*jniEnv)->GetStaticCharField(jniEnv, clazz, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.c = _result}, .exception = NULL};
}

JniResult globalEnv_GetStaticShortField(jclass clazz, jfieldID fieldID) {
  attach_thread();
  jshort _result = (*jniEnv)->GetStaticShortField(jniEnv, clazz, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.s = _result}, .exception = NULL};
}

JniResult globalEnv_GetStaticIntField(jclass clazz, jfieldID fieldID) {
  attach_thread();
  jint _result = (*jniEnv)->GetStaticIntField(jniEnv, clazz, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_GetStaticLongField(jclass clazz, jfieldID fieldID) {
  attach_thread();
  jlong _result = (*jniEnv)->GetStaticLongField(jniEnv, clazz, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.j = _result}, .exception = NULL};
}

JniResult globalEnv_GetStaticFloatField(jclass clazz, jfieldID fieldID) {
  attach_thread();
  jfloat _result = (*jniEnv)->GetStaticFloatField(jniEnv, clazz, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.f = _result}, .exception = NULL};
}

JniResult globalEnv_GetStaticDoubleField(jclass clazz, jfieldID fieldID) {
  attach_thread();
  jdouble _result = (*jniEnv)->GetStaticDoubleField(jniEnv, clazz, fieldID);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.d = _result}, .exception = NULL};
}

jthrowable globalEnv_SetStaticObjectField(jclass clazz,
                                          jfieldID fieldID,
                                          jobject val) {
  attach_thread();
  (*jniEnv)->SetStaticObjectField(jniEnv, clazz, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetStaticBooleanField(jclass clazz,
                                           jfieldID fieldID,
                                           jboolean val) {
  attach_thread();
  (*jniEnv)->SetStaticBooleanField(jniEnv, clazz, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetStaticByteField(jclass clazz,
                                        jfieldID fieldID,
                                        jbyte val) {
  attach_thread();
  (*jniEnv)->SetStaticByteField(jniEnv, clazz, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetStaticCharField(jclass clazz,
                                        jfieldID fieldID,
                                        jchar val) {
  attach_thread();
  (*jniEnv)->SetStaticCharField(jniEnv, clazz, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetStaticShortField(jclass clazz,
                                         jfieldID fieldID,
                                         jshort val) {
  attach_thread();
  (*jniEnv)->SetStaticShortField(jniEnv, clazz, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetStaticIntField(jclass clazz,
                                       jfieldID fieldID,
                                       jint val) {
  attach_thread();
  (*jniEnv)->SetStaticIntField(jniEnv, clazz, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetStaticLongField(jclass clazz,
                                        jfieldID fieldID,
                                        jlong val) {
  attach_thread();
  (*jniEnv)->SetStaticLongField(jniEnv, clazz, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetStaticFloatField(jclass clazz,
                                         jfieldID fieldID,
                                         jfloat val) {
  attach_thread();
  (*jniEnv)->SetStaticFloatField(jniEnv, clazz, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetStaticDoubleField(jclass clazz,
                                          jfieldID fieldID,
                                          jdouble val) {
  attach_thread();
  (*jniEnv)->SetStaticDoubleField(jniEnv, clazz, fieldID, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniResult globalEnv_NewString(jchar* unicodeChars, jsize len) {
  attach_thread();
  jstring _result = (*jniEnv)->NewString(jniEnv, unicodeChars, len);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_GetStringLength(jstring string) {
  attach_thread();
  jsize _result = (*jniEnv)->GetStringLength(jniEnv, string);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniPointerResult globalEnv_GetStringChars(jstring string, jboolean* isCopy) {
  attach_thread();
  const jchar* _result = (*jniEnv)->GetStringChars(jniEnv, string, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

jthrowable globalEnv_ReleaseStringChars(jstring string, jchar* isCopy) {
  attach_thread();
  (*jniEnv)->ReleaseStringChars(jniEnv, string, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniResult globalEnv_NewStringUTF(char* bytes) {
  attach_thread();
  jstring _result = (*jniEnv)->NewStringUTF(jniEnv, bytes);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_GetStringUTFLength(jstring string) {
  attach_thread();
  jsize _result = (*jniEnv)->GetStringUTFLength(jniEnv, string);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniPointerResult globalEnv_GetStringUTFChars(jstring string, jboolean* isCopy) {
  attach_thread();
  const char* _result = (*jniEnv)->GetStringUTFChars(jniEnv, string, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

jthrowable globalEnv_ReleaseStringUTFChars(jstring string, char* utf) {
  attach_thread();
  (*jniEnv)->ReleaseStringUTFChars(jniEnv, string, utf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniResult globalEnv_GetArrayLength(jarray array) {
  attach_thread();
  jsize _result = (*jniEnv)->GetArrayLength(jniEnv, array);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_NewObjectArray(jsize length,
                                   jclass elementClass,
                                   jobject initialElement) {
  attach_thread();
  jobjectArray _result =
      (*jniEnv)->NewObjectArray(jniEnv, length, elementClass, initialElement);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_GetObjectArrayElement(jobjectArray array, jsize index) {
  attach_thread();
  jobject _result = (*jniEnv)->GetObjectArrayElement(jniEnv, array, index);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

jthrowable globalEnv_SetObjectArrayElement(jobjectArray array,
                                           jsize index,
                                           jobject val) {
  attach_thread();
  (*jniEnv)->SetObjectArrayElement(jniEnv, array, index, val);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniResult globalEnv_NewBooleanArray(jsize length) {
  attach_thread();
  jbooleanArray _result = (*jniEnv)->NewBooleanArray(jniEnv, length);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_NewByteArray(jsize length) {
  attach_thread();
  jbyteArray _result = (*jniEnv)->NewByteArray(jniEnv, length);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_NewCharArray(jsize length) {
  attach_thread();
  jcharArray _result = (*jniEnv)->NewCharArray(jniEnv, length);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_NewShortArray(jsize length) {
  attach_thread();
  jshortArray _result = (*jniEnv)->NewShortArray(jniEnv, length);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_NewIntArray(jsize length) {
  attach_thread();
  jintArray _result = (*jniEnv)->NewIntArray(jniEnv, length);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_NewLongArray(jsize length) {
  attach_thread();
  jlongArray _result = (*jniEnv)->NewLongArray(jniEnv, length);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_NewFloatArray(jsize length) {
  attach_thread();
  jfloatArray _result = (*jniEnv)->NewFloatArray(jniEnv, length);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniResult globalEnv_NewDoubleArray(jsize length) {
  attach_thread();
  jdoubleArray _result = (*jniEnv)->NewDoubleArray(jniEnv, length);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniPointerResult globalEnv_GetBooleanArrayElements(jbooleanArray array,
                                                   jboolean* isCopy) {
  attach_thread();
  jboolean* _result = (*jniEnv)->GetBooleanArrayElements(jniEnv, array, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniPointerResult globalEnv_GetByteArrayElements(jbyteArray array,
                                                jboolean* isCopy) {
  attach_thread();
  jbyte* _result = (*jniEnv)->GetByteArrayElements(jniEnv, array, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniPointerResult globalEnv_GetCharArrayElements(jcharArray array,
                                                jboolean* isCopy) {
  attach_thread();
  jchar* _result = (*jniEnv)->GetCharArrayElements(jniEnv, array, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniPointerResult globalEnv_GetShortArrayElements(jshortArray array,
                                                 jboolean* isCopy) {
  attach_thread();
  jshort* _result = (*jniEnv)->GetShortArrayElements(jniEnv, array, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniPointerResult globalEnv_GetIntArrayElements(jintArray array,
                                               jboolean* isCopy) {
  attach_thread();
  jint* _result = (*jniEnv)->GetIntArrayElements(jniEnv, array, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniPointerResult globalEnv_GetLongArrayElements(jlongArray array,
                                                jboolean* isCopy) {
  attach_thread();
  jlong* _result = (*jniEnv)->GetLongArrayElements(jniEnv, array, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniPointerResult globalEnv_GetFloatArrayElements(jfloatArray array,
                                                 jboolean* isCopy) {
  attach_thread();
  jfloat* _result = (*jniEnv)->GetFloatArrayElements(jniEnv, array, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniPointerResult globalEnv_GetDoubleArrayElements(jdoubleArray array,
                                                  jboolean* isCopy) {
  attach_thread();
  jdouble* _result = (*jniEnv)->GetDoubleArrayElements(jniEnv, array, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

jthrowable globalEnv_ReleaseBooleanArrayElements(jbooleanArray array,
                                                 jboolean* elems,
                                                 jint mode) {
  attach_thread();
  (*jniEnv)->ReleaseBooleanArrayElements(jniEnv, array, elems, mode);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_ReleaseByteArrayElements(jbyteArray array,
                                              jbyte* elems,
                                              jint mode) {
  attach_thread();
  (*jniEnv)->ReleaseByteArrayElements(jniEnv, array, elems, mode);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_ReleaseCharArrayElements(jcharArray array,
                                              jchar* elems,
                                              jint mode) {
  attach_thread();
  (*jniEnv)->ReleaseCharArrayElements(jniEnv, array, elems, mode);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_ReleaseShortArrayElements(jshortArray array,
                                               jshort* elems,
                                               jint mode) {
  attach_thread();
  (*jniEnv)->ReleaseShortArrayElements(jniEnv, array, elems, mode);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_ReleaseIntArrayElements(jintArray array,
                                             jint* elems,
                                             jint mode) {
  attach_thread();
  (*jniEnv)->ReleaseIntArrayElements(jniEnv, array, elems, mode);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_ReleaseLongArrayElements(jlongArray array,
                                              jlong* elems,
                                              jint mode) {
  attach_thread();
  (*jniEnv)->ReleaseLongArrayElements(jniEnv, array, elems, mode);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_ReleaseFloatArrayElements(jfloatArray array,
                                               jfloat* elems,
                                               jint mode) {
  attach_thread();
  (*jniEnv)->ReleaseFloatArrayElements(jniEnv, array, elems, mode);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_ReleaseDoubleArrayElements(jdoubleArray array,
                                                jdouble* elems,
                                                jint mode) {
  attach_thread();
  (*jniEnv)->ReleaseDoubleArrayElements(jniEnv, array, elems, mode);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_GetBooleanArrayRegion(jbooleanArray array,
                                           jsize start,
                                           jsize len,
                                           jboolean* buf) {
  attach_thread();
  (*jniEnv)->GetBooleanArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_GetByteArrayRegion(jbyteArray array,
                                        jsize start,
                                        jsize len,
                                        jbyte* buf) {
  attach_thread();
  (*jniEnv)->GetByteArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_GetCharArrayRegion(jcharArray array,
                                        jsize start,
                                        jsize len,
                                        jchar* buf) {
  attach_thread();
  (*jniEnv)->GetCharArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_GetShortArrayRegion(jshortArray array,
                                         jsize start,
                                         jsize len,
                                         jshort* buf) {
  attach_thread();
  (*jniEnv)->GetShortArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_GetIntArrayRegion(jintArray array,
                                       jsize start,
                                       jsize len,
                                       jint* buf) {
  attach_thread();
  (*jniEnv)->GetIntArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_GetLongArrayRegion(jlongArray array,
                                        jsize start,
                                        jsize len,
                                        jlong* buf) {
  attach_thread();
  (*jniEnv)->GetLongArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_GetFloatArrayRegion(jfloatArray array,
                                         jsize start,
                                         jsize len,
                                         jfloat* buf) {
  attach_thread();
  (*jniEnv)->GetFloatArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_GetDoubleArrayRegion(jdoubleArray array,
                                          jsize start,
                                          jsize len,
                                          jdouble* buf) {
  attach_thread();
  (*jniEnv)->GetDoubleArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetBooleanArrayRegion(jbooleanArray array,
                                           jsize start,
                                           jsize len,
                                           jboolean* buf) {
  attach_thread();
  (*jniEnv)->SetBooleanArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetByteArrayRegion(jbyteArray array,
                                        jsize start,
                                        jsize len,
                                        jbyte* buf) {
  attach_thread();
  (*jniEnv)->SetByteArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetCharArrayRegion(jcharArray array,
                                        jsize start,
                                        jsize len,
                                        jchar* buf) {
  attach_thread();
  (*jniEnv)->SetCharArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetShortArrayRegion(jshortArray array,
                                         jsize start,
                                         jsize len,
                                         jshort* buf) {
  attach_thread();
  (*jniEnv)->SetShortArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetIntArrayRegion(jintArray array,
                                       jsize start,
                                       jsize len,
                                       jint* buf) {
  attach_thread();
  (*jniEnv)->SetIntArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetLongArrayRegion(jlongArray array,
                                        jsize start,
                                        jsize len,
                                        jlong* buf) {
  attach_thread();
  (*jniEnv)->SetLongArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetFloatArrayRegion(jfloatArray array,
                                         jsize start,
                                         jsize len,
                                         jfloat* buf) {
  attach_thread();
  (*jniEnv)->SetFloatArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_SetDoubleArrayRegion(jdoubleArray array,
                                          jsize start,
                                          jsize len,
                                          jdouble* buf) {
  attach_thread();
  (*jniEnv)->SetDoubleArrayRegion(jniEnv, array, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniResult globalEnv_RegisterNatives(jclass clazz,
                                    JNINativeMethod* methods,
                                    jint nMethods) {
  attach_thread();
  jint _result = (*jniEnv)->RegisterNatives(jniEnv, clazz, methods, nMethods);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_UnregisterNatives(jclass clazz) {
  attach_thread();
  jint _result = (*jniEnv)->UnregisterNatives(jniEnv, clazz);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_MonitorEnter(jobject obj) {
  attach_thread();
  jint _result = (*jniEnv)->MonitorEnter(jniEnv, obj);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_MonitorExit(jobject obj) {
  attach_thread();
  jint _result = (*jniEnv)->MonitorExit(jniEnv, obj);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

JniResult globalEnv_GetJavaVM(JavaVM** vm) {
  attach_thread();
  jint _result = (*jniEnv)->GetJavaVM(jniEnv, vm);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

jthrowable globalEnv_GetStringRegion(jstring str,
                                     jsize start,
                                     jsize len,
                                     jchar* buf) {
  attach_thread();
  (*jniEnv)->GetStringRegion(jniEnv, str, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

jthrowable globalEnv_GetStringUTFRegion(jstring str,
                                        jsize start,
                                        jsize len,
                                        char* buf) {
  attach_thread();
  (*jniEnv)->GetStringUTFRegion(jniEnv, str, start, len, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniPointerResult globalEnv_GetPrimitiveArrayCritical(jarray array,
                                                     jboolean* isCopy) {
  attach_thread();
  void* _result = (*jniEnv)->GetPrimitiveArrayCritical(jniEnv, array, isCopy);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

jthrowable globalEnv_ReleasePrimitiveArrayCritical(jarray array,
                                                   void* carray,
                                                   jint mode) {
  attach_thread();
  (*jniEnv)->ReleasePrimitiveArrayCritical(jniEnv, array, carray, mode);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniPointerResult globalEnv_GetStringCritical(jstring str, jboolean* isCopy) {
  attach_thread();
  const jchar* _result = (*jniEnv)->GetStringCritical(jniEnv, str, isCopy);
  return (JniPointerResult){.value = _result, .exception = NULL};
}

jthrowable globalEnv_ReleaseStringCritical(jstring str, jchar* carray) {
  attach_thread();
  (*jniEnv)->ReleaseStringCritical(jniEnv, str, carray);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniResult globalEnv_NewWeakGlobalRef(jobject obj) {
  attach_thread();
  jweak _result = (*jniEnv)->NewWeakGlobalRef(jniEnv, obj);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

jthrowable globalEnv_DeleteWeakGlobalRef(jweak obj) {
  attach_thread();
  (*jniEnv)->DeleteWeakGlobalRef(jniEnv, obj);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return _exception;
  }
  return NULL;
}

JniResult globalEnv_ExceptionCheck() {
  attach_thread();
  jboolean _result = (*jniEnv)->ExceptionCheck(jniEnv);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.z = _result}, .exception = NULL};
}

JniResult globalEnv_NewDirectByteBuffer(void* address, jlong capacity) {
  attach_thread();
  jobject _result = (*jniEnv)->NewDirectByteBuffer(jniEnv, address, capacity);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  _result = to_global_ref(_result);
  return (JniResult){.value = {.l = _result}, .exception = NULL};
}

JniPointerResult globalEnv_GetDirectBufferAddress(jobject buf) {
  attach_thread();
  void* _result = (*jniEnv)->GetDirectBufferAddress(jniEnv, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniPointerResult){.value = NULL, .exception = _exception};
  }
  return (JniPointerResult){.value = _result, .exception = NULL};
}

JniResult globalEnv_GetDirectBufferCapacity(jobject buf) {
  attach_thread();
  jlong _result = (*jniEnv)->GetDirectBufferCapacity(jniEnv, buf);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.j = _result}, .exception = NULL};
}

JniResult globalEnv_GetObjectRefType(jobject obj) {
  attach_thread();
  int32_t _result = (*jniEnv)->GetObjectRefType(jniEnv, obj);
  jthrowable _exception = check_exception();
  if (_exception != NULL) {
    return (JniResult){.value = {.j = 0}, .exception = _exception};
  }
  return (JniResult){.value = {.i = _result}, .exception = NULL};
}

GlobalJniEnvStruct globalJniEnv = {
    .reserved0 = NULL,
    .reserved1 = NULL,
    .reserved2 = NULL,
    .reserved3 = NULL,
    .GetVersion = globalEnv_GetVersion,
    .DefineClass = globalEnv_DefineClass,
    .FindClass = globalEnv_FindClass,
    .FromReflectedMethod = globalEnv_FromReflectedMethod,
    .FromReflectedField = globalEnv_FromReflectedField,
    .ToReflectedMethod = globalEnv_ToReflectedMethod,
    .GetSuperclass = globalEnv_GetSuperclass,
    .IsAssignableFrom = globalEnv_IsAssignableFrom,
    .ToReflectedField = globalEnv_ToReflectedField,
    .Throw = globalEnv_Throw,
    .ThrowNew = globalEnv_ThrowNew,
    .ExceptionOccurred = globalEnv_ExceptionOccurred,
    .ExceptionDescribe = globalEnv_ExceptionDescribe,
    .ExceptionClear = globalEnv_ExceptionClear,
    .FatalError = globalEnv_FatalError,
    .PushLocalFrame = globalEnv_PushLocalFrame,
    .PopLocalFrame = globalEnv_PopLocalFrame,
    .NewGlobalRef = globalEnv_NewGlobalRef,
    .DeleteGlobalRef = globalEnv_DeleteGlobalRef,
    .DeleteLocalRef = globalEnv_DeleteLocalRef,
    .IsSameObject = globalEnv_IsSameObject,
    .NewLocalRef = globalEnv_NewLocalRef,
    .EnsureLocalCapacity = globalEnv_EnsureLocalCapacity,
    .AllocObject = globalEnv_AllocObject,
    .NewObject = globalEnv_NewObject,
    .NewObjectV = NULL,
    .NewObjectA = globalEnv_NewObjectA,
    .GetObjectClass = globalEnv_GetObjectClass,
    .IsInstanceOf = globalEnv_IsInstanceOf,
    .GetMethodID = globalEnv_GetMethodID,
    .CallObjectMethod = globalEnv_CallObjectMethod,
    .CallObjectMethodV = NULL,
    .CallObjectMethodA = globalEnv_CallObjectMethodA,
    .CallBooleanMethod = globalEnv_CallBooleanMethod,
    .CallBooleanMethodV = NULL,
    .CallBooleanMethodA = globalEnv_CallBooleanMethodA,
    .CallByteMethod = globalEnv_CallByteMethod,
    .CallByteMethodV = NULL,
    .CallByteMethodA = globalEnv_CallByteMethodA,
    .CallCharMethod = globalEnv_CallCharMethod,
    .CallCharMethodV = NULL,
    .CallCharMethodA = globalEnv_CallCharMethodA,
    .CallShortMethod = globalEnv_CallShortMethod,
    .CallShortMethodV = NULL,
    .CallShortMethodA = globalEnv_CallShortMethodA,
    .CallIntMethod = globalEnv_CallIntMethod,
    .CallIntMethodV = NULL,
    .CallIntMethodA = globalEnv_CallIntMethodA,
    .CallLongMethod = globalEnv_CallLongMethod,
    .CallLongMethodV = NULL,
    .CallLongMethodA = globalEnv_CallLongMethodA,
    .CallFloatMethod = globalEnv_CallFloatMethod,
    .CallFloatMethodV = NULL,
    .CallFloatMethodA = globalEnv_CallFloatMethodA,
    .CallDoubleMethod = globalEnv_CallDoubleMethod,
    .CallDoubleMethodV = NULL,
    .CallDoubleMethodA = globalEnv_CallDoubleMethodA,
    .CallVoidMethod = globalEnv_CallVoidMethod,
    .CallVoidMethodV = NULL,
    .CallVoidMethodA = globalEnv_CallVoidMethodA,
    .CallNonvirtualObjectMethod = globalEnv_CallNonvirtualObjectMethod,
    .CallNonvirtualObjectMethodV = NULL,
    .CallNonvirtualObjectMethodA = globalEnv_CallNonvirtualObjectMethodA,
    .CallNonvirtualBooleanMethod = globalEnv_CallNonvirtualBooleanMethod,
    .CallNonvirtualBooleanMethodV = NULL,
    .CallNonvirtualBooleanMethodA = globalEnv_CallNonvirtualBooleanMethodA,
    .CallNonvirtualByteMethod = globalEnv_CallNonvirtualByteMethod,
    .CallNonvirtualByteMethodV = NULL,
    .CallNonvirtualByteMethodA = globalEnv_CallNonvirtualByteMethodA,
    .CallNonvirtualCharMethod = globalEnv_CallNonvirtualCharMethod,
    .CallNonvirtualCharMethodV = NULL,
    .CallNonvirtualCharMethodA = globalEnv_CallNonvirtualCharMethodA,
    .CallNonvirtualShortMethod = globalEnv_CallNonvirtualShortMethod,
    .CallNonvirtualShortMethodV = NULL,
    .CallNonvirtualShortMethodA = globalEnv_CallNonvirtualShortMethodA,
    .CallNonvirtualIntMethod = globalEnv_CallNonvirtualIntMethod,
    .CallNonvirtualIntMethodV = NULL,
    .CallNonvirtualIntMethodA = globalEnv_CallNonvirtualIntMethodA,
    .CallNonvirtualLongMethod = globalEnv_CallNonvirtualLongMethod,
    .CallNonvirtualLongMethodV = NULL,
    .CallNonvirtualLongMethodA = globalEnv_CallNonvirtualLongMethodA,
    .CallNonvirtualFloatMethod = globalEnv_CallNonvirtualFloatMethod,
    .CallNonvirtualFloatMethodV = NULL,
    .CallNonvirtualFloatMethodA = globalEnv_CallNonvirtualFloatMethodA,
    .CallNonvirtualDoubleMethod = globalEnv_CallNonvirtualDoubleMethod,
    .CallNonvirtualDoubleMethodV = NULL,
    .CallNonvirtualDoubleMethodA = globalEnv_CallNonvirtualDoubleMethodA,
    .CallNonvirtualVoidMethod = globalEnv_CallNonvirtualVoidMethod,
    .CallNonvirtualVoidMethodV = NULL,
    .CallNonvirtualVoidMethodA = globalEnv_CallNonvirtualVoidMethodA,
    .GetFieldID = globalEnv_GetFieldID,
    .GetObjectField = globalEnv_GetObjectField,
    .GetBooleanField = globalEnv_GetBooleanField,
    .GetByteField = globalEnv_GetByteField,
    .GetCharField = globalEnv_GetCharField,
    .GetShortField = globalEnv_GetShortField,
    .GetIntField = globalEnv_GetIntField,
    .GetLongField = globalEnv_GetLongField,
    .GetFloatField = globalEnv_GetFloatField,
    .GetDoubleField = globalEnv_GetDoubleField,
    .SetObjectField = globalEnv_SetObjectField,
    .SetBooleanField = globalEnv_SetBooleanField,
    .SetByteField = globalEnv_SetByteField,
    .SetCharField = globalEnv_SetCharField,
    .SetShortField = globalEnv_SetShortField,
    .SetIntField = globalEnv_SetIntField,
    .SetLongField = globalEnv_SetLongField,
    .SetFloatField = globalEnv_SetFloatField,
    .SetDoubleField = globalEnv_SetDoubleField,
    .GetStaticMethodID = globalEnv_GetStaticMethodID,
    .CallStaticObjectMethod = globalEnv_CallStaticObjectMethod,
    .CallStaticObjectMethodV = NULL,
    .CallStaticObjectMethodA = globalEnv_CallStaticObjectMethodA,
    .CallStaticBooleanMethod = globalEnv_CallStaticBooleanMethod,
    .CallStaticBooleanMethodV = NULL,
    .CallStaticBooleanMethodA = globalEnv_CallStaticBooleanMethodA,
    .CallStaticByteMethod = globalEnv_CallStaticByteMethod,
    .CallStaticByteMethodV = NULL,
    .CallStaticByteMethodA = globalEnv_CallStaticByteMethodA,
    .CallStaticCharMethod = globalEnv_CallStaticCharMethod,
    .CallStaticCharMethodV = NULL,
    .CallStaticCharMethodA = globalEnv_CallStaticCharMethodA,
    .CallStaticShortMethod = globalEnv_CallStaticShortMethod,
    .CallStaticShortMethodV = NULL,
    .CallStaticShortMethodA = globalEnv_CallStaticShortMethodA,
    .CallStaticIntMethod = globalEnv_CallStaticIntMethod,
    .CallStaticIntMethodV = NULL,
    .CallStaticIntMethodA = globalEnv_CallStaticIntMethodA,
    .CallStaticLongMethod = globalEnv_CallStaticLongMethod,
    .CallStaticLongMethodV = NULL,
    .CallStaticLongMethodA = globalEnv_CallStaticLongMethodA,
    .CallStaticFloatMethod = globalEnv_CallStaticFloatMethod,
    .CallStaticFloatMethodV = NULL,
    .CallStaticFloatMethodA = globalEnv_CallStaticFloatMethodA,
    .CallStaticDoubleMethod = globalEnv_CallStaticDoubleMethod,
    .CallStaticDoubleMethodV = NULL,
    .CallStaticDoubleMethodA = globalEnv_CallStaticDoubleMethodA,
    .CallStaticVoidMethod = globalEnv_CallStaticVoidMethod,
    .CallStaticVoidMethodV = NULL,
    .CallStaticVoidMethodA = globalEnv_CallStaticVoidMethodA,
    .GetStaticFieldID = globalEnv_GetStaticFieldID,
    .GetStaticObjectField = globalEnv_GetStaticObjectField,
    .GetStaticBooleanField = globalEnv_GetStaticBooleanField,
    .GetStaticByteField = globalEnv_GetStaticByteField,
    .GetStaticCharField = globalEnv_GetStaticCharField,
    .GetStaticShortField = globalEnv_GetStaticShortField,
    .GetStaticIntField = globalEnv_GetStaticIntField,
    .GetStaticLongField = globalEnv_GetStaticLongField,
    .GetStaticFloatField = globalEnv_GetStaticFloatField,
    .GetStaticDoubleField = globalEnv_GetStaticDoubleField,
    .SetStaticObjectField = globalEnv_SetStaticObjectField,
    .SetStaticBooleanField = globalEnv_SetStaticBooleanField,
    .SetStaticByteField = globalEnv_SetStaticByteField,
    .SetStaticCharField = globalEnv_SetStaticCharField,
    .SetStaticShortField = globalEnv_SetStaticShortField,
    .SetStaticIntField = globalEnv_SetStaticIntField,
    .SetStaticLongField = globalEnv_SetStaticLongField,
    .SetStaticFloatField = globalEnv_SetStaticFloatField,
    .SetStaticDoubleField = globalEnv_SetStaticDoubleField,
    .NewString = globalEnv_NewString,
    .GetStringLength = globalEnv_GetStringLength,
    .GetStringChars = globalEnv_GetStringChars,
    .ReleaseStringChars = globalEnv_ReleaseStringChars,
    .NewStringUTF = globalEnv_NewStringUTF,
    .GetStringUTFLength = globalEnv_GetStringUTFLength,
    .GetStringUTFChars = globalEnv_GetStringUTFChars,
    .ReleaseStringUTFChars = globalEnv_ReleaseStringUTFChars,
    .GetArrayLength = globalEnv_GetArrayLength,
    .NewObjectArray = globalEnv_NewObjectArray,
    .GetObjectArrayElement = globalEnv_GetObjectArrayElement,
    .SetObjectArrayElement = globalEnv_SetObjectArrayElement,
    .NewBooleanArray = globalEnv_NewBooleanArray,
    .NewByteArray = globalEnv_NewByteArray,
    .NewCharArray = globalEnv_NewCharArray,
    .NewShortArray = globalEnv_NewShortArray,
    .NewIntArray = globalEnv_NewIntArray,
    .NewLongArray = globalEnv_NewLongArray,
    .NewFloatArray = globalEnv_NewFloatArray,
    .NewDoubleArray = globalEnv_NewDoubleArray,
    .GetBooleanArrayElements = globalEnv_GetBooleanArrayElements,
    .GetByteArrayElements = globalEnv_GetByteArrayElements,
    .GetCharArrayElements = globalEnv_GetCharArrayElements,
    .GetShortArrayElements = globalEnv_GetShortArrayElements,
    .GetIntArrayElements = globalEnv_GetIntArrayElements,
    .GetLongArrayElements = globalEnv_GetLongArrayElements,
    .GetFloatArrayElements = globalEnv_GetFloatArrayElements,
    .GetDoubleArrayElements = globalEnv_GetDoubleArrayElements,
    .ReleaseBooleanArrayElements = globalEnv_ReleaseBooleanArrayElements,
    .ReleaseByteArrayElements = globalEnv_ReleaseByteArrayElements,
    .ReleaseCharArrayElements = globalEnv_ReleaseCharArrayElements,
    .ReleaseShortArrayElements = globalEnv_ReleaseShortArrayElements,
    .ReleaseIntArrayElements = globalEnv_ReleaseIntArrayElements,
    .ReleaseLongArrayElements = globalEnv_ReleaseLongArrayElements,
    .ReleaseFloatArrayElements = globalEnv_ReleaseFloatArrayElements,
    .ReleaseDoubleArrayElements = globalEnv_ReleaseDoubleArrayElements,
    .GetBooleanArrayRegion = globalEnv_GetBooleanArrayRegion,
    .GetByteArrayRegion = globalEnv_GetByteArrayRegion,
    .GetCharArrayRegion = globalEnv_GetCharArrayRegion,
    .GetShortArrayRegion = globalEnv_GetShortArrayRegion,
    .GetIntArrayRegion = globalEnv_GetIntArrayRegion,
    .GetLongArrayRegion = globalEnv_GetLongArrayRegion,
    .GetFloatArrayRegion = globalEnv_GetFloatArrayRegion,
    .GetDoubleArrayRegion = globalEnv_GetDoubleArrayRegion,
    .SetBooleanArrayRegion = globalEnv_SetBooleanArrayRegion,
    .SetByteArrayRegion = globalEnv_SetByteArrayRegion,
    .SetCharArrayRegion = globalEnv_SetCharArrayRegion,
    .SetShortArrayRegion = globalEnv_SetShortArrayRegion,
    .SetIntArrayRegion = globalEnv_SetIntArrayRegion,
    .SetLongArrayRegion = globalEnv_SetLongArrayRegion,
    .SetFloatArrayRegion = globalEnv_SetFloatArrayRegion,
    .SetDoubleArrayRegion = globalEnv_SetDoubleArrayRegion,
    .RegisterNatives = globalEnv_RegisterNatives,
    .UnregisterNatives = globalEnv_UnregisterNatives,
    .MonitorEnter = globalEnv_MonitorEnter,
    .MonitorExit = globalEnv_MonitorExit,
    .GetJavaVM = globalEnv_GetJavaVM,
    .GetStringRegion = globalEnv_GetStringRegion,
    .GetStringUTFRegion = globalEnv_GetStringUTFRegion,
    .GetPrimitiveArrayCritical = globalEnv_GetPrimitiveArrayCritical,
    .ReleasePrimitiveArrayCritical = globalEnv_ReleasePrimitiveArrayCritical,
    .GetStringCritical = globalEnv_GetStringCritical,
    .ReleaseStringCritical = globalEnv_ReleaseStringCritical,
    .NewWeakGlobalRef = globalEnv_NewWeakGlobalRef,
    .DeleteWeakGlobalRef = globalEnv_DeleteWeakGlobalRef,
    .ExceptionCheck = globalEnv_ExceptionCheck,
    .NewDirectByteBuffer = globalEnv_NewDirectByteBuffer,
    .GetDirectBufferAddress = globalEnv_GetDirectBufferAddress,
    .GetDirectBufferCapacity = globalEnv_GetDirectBufferCapacity,
    .GetObjectRefType = globalEnv_GetObjectRefType,
};
FFI_PLUGIN_EXPORT
GlobalJniEnvStruct* GetGlobalEnv() {
  if (jni->jvm == NULL) {
    return NULL;
  }
  return &globalJniEnv;
}
