
// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "internal.h"

FFI_PLUGIN_EXPORT intptr_t InitDartApiDL(void* data) {
  return Dart_InitializeApiDL(data);
}

// com.github.dart_lang.jni.DartException
jclass _c_DartException = NULL;

jmethodID _m_DartException__ctor = NULL;
FFI_PLUGIN_EXPORT JniResult DartException__ctor(jstring message) {
  attach_thread();
  load_class_global_ref(&_c_DartException,
                        "com/github/dart_lang/jni/PortProxy$DartException");
  if (_c_DartException == NULL)
    return (JniResult){.value = {.j = 0}, .exception = check_exception()};
  load_method(_c_DartException, &_m_DartException__ctor, "<init>",
              "(Ljava/lang/String;)V");
  if (_m_DartException__ctor == NULL)
    return (JniResult){.value = {.j = 0}, .exception = check_exception()};
  jobject _result = (*jniEnv)->NewObject(jniEnv, _c_DartException,
                                         _m_DartException__ctor, message);
  jthrowable exception = check_exception();
  if (exception == NULL) {
    _result = to_global_ref(_result);
  }
  return (JniResult){.value = {.l = _result}, .exception = check_exception()};
}

JNIEXPORT void JNICALL
Java_com_github_dart_1lang_jni_PortContinuation__1resumeWith(JNIEnv* env,
                                                             jclass clazz,
                                                             jlong port,
                                                             jobject result) {
  attach_thread();
  Dart_CObject c_post;
  c_post.type = Dart_CObject_kInt64;
  c_post.value.as_int64 = (jlong)((*env)->NewGlobalRef(env, result));
  Dart_PostCObject_DL(port, &c_post);
}

// com.github.dart_lang.jni.PortContinuation
jclass _c_PortContinuation = NULL;

jmethodID _m_PortContinuation__ctor = NULL;
FFI_PLUGIN_EXPORT
JniResult PortContinuation__ctor(int64_t j) {
  attach_thread();
  load_class_global_ref(&_c_PortContinuation,
                        "com/github/dart_lang/jni/PortContinuation");
  if (_c_PortContinuation == NULL)
    return (JniResult){.value = {.j = 0}, .exception = check_exception()};
  load_method(_c_PortContinuation, &_m_PortContinuation__ctor, "<init>",
              "(J)V");
  if (_m_PortContinuation__ctor == NULL)
    return (JniResult){.value = {.j = 0}, .exception = check_exception()};
  jobject _result = (*jniEnv)->NewObject(jniEnv, _c_PortContinuation,
                                         _m_PortContinuation__ctor, j);
  jthrowable exception = check_exception();
  if (exception == NULL) {
    _result = to_global_ref(_result);
  }
  return (JniResult){.value = {.l = _result}, .exception = check_exception()};
}

// com.github.dart_lang.jni.PortProxy
jclass _c_PortProxy = NULL;

jmethodID _m_PortProxy__newInstance = NULL;
FFI_PLUGIN_EXPORT
JniResult PortProxy__newInstance(jobject binaryName,
                                 int64_t port,
                                 int64_t functionPtr) {
  attach_thread();
  load_class_global_ref(&_c_PortProxy, "com/github/dart_lang/jni/PortProxy");
  if (_c_PortProxy == NULL)
    return (JniResult){.value = {.j = 0}, .exception = check_exception()};
  load_static_method(_c_PortProxy, &_m_PortProxy__newInstance, "newInstance",
                     "(Ljava/lang/String;JJJ)Ljava/lang/Object;");
  if (_m_PortProxy__newInstance == NULL)
    return (JniResult){.value = {.j = 0}, .exception = check_exception()};
  jobject _result = (*jniEnv)->CallStaticObjectMethod(
      jniEnv, _c_PortProxy, _m_PortProxy__newInstance, binaryName, port,
      (jlong)Dart_CurrentIsolate_DL(), functionPtr);
  return to_global_ref_result(_result);
}

FFI_PLUGIN_EXPORT
void resultFor(CallbackResult* result, jobject object) {
  acquire_lock(&result->lock);
  result->ready = 1;
  result->object = object;
  signal_cond(&result->cond);
  release_lock(&result->lock);
}

void doNotFinalize(void* isolate_callback_data, void* peer) {}

void finalizeLocal(void* isolate_callback_data, void* peer) {
  attach_thread();
  (*jniEnv)->DeleteLocalRef(jniEnv, peer);
}

void finalizeGlobal(void* isolate_callback_data, void* peer) {
  attach_thread();
  (*jniEnv)->DeleteGlobalRef(jniEnv, peer);
}

void finalizeWeakGlobal(void* isolate_callback_data, void* peer) {
  attach_thread();
  (*jniEnv)->DeleteWeakGlobalRef(jniEnv, peer);
}

void freeBoolean(void* isolate_callback_data, void* peer) {
  // To match the platform implementation of Dart's calloc.
  free_mem(peer);
}

FFI_PLUGIN_EXPORT
Dart_FinalizableHandle newJObjectFinalizableHandle(Dart_Handle object,
                                                   jobject reference,
                                                   jobjectRefType refType) {
  switch (refType) {
    case JNIInvalidRefType:
      return Dart_NewFinalizableHandle_DL(object, reference, 0, doNotFinalize);
    case JNILocalRefType:
      return Dart_NewFinalizableHandle_DL(object, reference, 0, finalizeLocal);
    case JNIGlobalRefType:
      return Dart_NewFinalizableHandle_DL(object, reference, 0, finalizeGlobal);
    case JNIWeakGlobalRefType:
      return Dart_NewFinalizableHandle_DL(object, reference, 0,
                                          finalizeWeakGlobal);
  }
}

FFI_PLUGIN_EXPORT
Dart_FinalizableHandle newBooleanFinalizableHandle(Dart_Handle object,
                                                   bool* reference) {
  return Dart_NewFinalizableHandle_DL(object, reference, 1, freeBoolean);
}

FFI_PLUGIN_EXPORT
void deleteFinalizableHandle(Dart_FinalizableHandle finalizableHandle,
                             Dart_Handle object) {
  return Dart_DeleteFinalizableHandle_DL(finalizableHandle, object);
}

jclass _c_Object = NULL;
jclass _c_Long = NULL;

jmethodID _m_Long_init = NULL;

JNIEXPORT jobjectArray JNICALL
Java_com_github_dart_1lang_jni_PortProxy__1invoke(JNIEnv* env,
                                                  jclass clazz,
                                                  jlong port,
                                                  jlong isolateId,
                                                  jlong functionPtr,
                                                  jobject proxy,
                                                  jstring methodDescriptor,
                                                  jobjectArray args) {
  CallbackResult* result = (CallbackResult*)malloc(sizeof(CallbackResult));
  if (isolateId != (jlong)Dart_CurrentIsolate_DL()) {
    init_lock(&result->lock);
    init_cond(&result->cond);
    acquire_lock(&result->lock);
    result->ready = 0;
    result->object = NULL;

    Dart_CObject c_result;
    c_result.type = Dart_CObject_kInt64;
    c_result.value.as_int64 = (jlong)result;

    Dart_CObject c_method;
    c_method.type = Dart_CObject_kInt64;
    c_method.value.as_int64 =
        (jlong)((*env)->NewGlobalRef(env, methodDescriptor));

    Dart_CObject c_args;
    c_args.type = Dart_CObject_kInt64;
    c_args.value.as_int64 = (jlong)((*env)->NewGlobalRef(env, args));

    Dart_CObject* c_post_arr[] = {&c_result, &c_method, &c_args};
    Dart_CObject c_post;
    c_post.type = Dart_CObject_kArray;
    c_post.value.as_array.values = c_post_arr;
    c_post.value.as_array.length = sizeof(c_post_arr) / sizeof(c_post_arr[0]);

    Dart_PostCObject_DL(port, &c_post);

    while (!result->ready) {
      wait_for(&result->cond, &result->lock);
    }

    release_lock(&result->lock);
    destroy_lock(&result->lock);
    destroy_cond(&result->cond);
  } else {
    result->object = ((jobject(*)(uint64_t, jobject, jobject))functionPtr)(
        port, (*env)->NewGlobalRef(env, methodDescriptor),
        (*env)->NewGlobalRef(env, args));
  }
  // Returning an array of length 2.
  // [0]: The result pointer, used for cleaning up the global reference, and
  //      freeing the memory since we passed the ownership to Java.
  // [1]: The returned object.
  attach_thread();
  load_class_global_ref(&_c_Object, "java/lang/Object");
  load_class_global_ref(&_c_Long, "java/lang/Long");
  load_method(_c_Long, &_m_Long_init, "<init>", "(J)V");
  jobject first = (*env)->NewObject(env, _c_Long, _m_Long_init, (jlong)result);
  jobject second = result->object;
  jobjectArray arr = (*env)->NewObjectArray(env, 2, _c_Object, NULL);
  (*env)->SetObjectArrayElement(env, arr, 0, first);
  (*env)->SetObjectArrayElement(env, arr, 1, second);
  return arr;
}

JNIEXPORT void JNICALL
Java_com_github_dart_1lang_jni_PortProxy__1cleanUp(JNIEnv* env,
                                                   jclass clazz,
                                                   jlong resultPtr) {
  CallbackResult* result = (CallbackResult*)resultPtr;
  (*env)->DeleteGlobalRef(env, result->object);
  free(result);
}

JNIEXPORT void JNICALL
Java_com_github_dart_1lang_jni_PortCleaner_clean(JNIEnv* env,
                                                 jclass clazz,
                                                 jlong port) {
  Dart_CObject close_signal;
  close_signal.type = Dart_CObject_kNull;
  Dart_PostCObject_DL(port, &close_signal);
}

JNIEXPORT jobject JNICALL
Java_com_github_dart_1lang_jni_JniUtils_fromReferenceAddress(JNIEnv* env,
                                                             jclass clazz,
                                                             jlong id) {
  attach_thread();
  return (jobject)(id);
}
