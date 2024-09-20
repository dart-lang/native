// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <jni.h>
#include <stdarg.h>
#include <stdint.h>

#include "dartjni.h"

#ifndef _WIN32
pthread_key_t tlsKey;
#endif

jclass FindClassUnchecked(const char* name) {
  attach_thread();
  jclass cls;
  load_class_platform(&cls, name);
  if (!(*jniEnv)->ExceptionCheck(jniEnv)) {
    cls = to_global_ref(cls);
  }
  return cls;
};

/// Load class through platform-specific mechanism.
///
/// Currently uses application classloader on android,
/// and JNIEnv->FindClass on other platforms.
FFI_PLUGIN_EXPORT
JniClassLookupResult FindClass(const char* name) {
  JniClassLookupResult result = {NULL, NULL};
  result.value = FindClassUnchecked(name);
  result.exception = check_exception();
  return result;
}

/// Stores class and method references for obtaining exception details
typedef struct JniExceptionMethods {
  jclass objectClass, exceptionClass, printStreamClass;
  jclass byteArrayOutputStreamClass;
  jmethodID toStringMethod, printStackTraceMethod;
  jmethodID byteArrayOutputStreamCtor, printStreamCtor;
} JniExceptionMethods;

// Context and shared global state. Initialized once or if thread-local, initialized once in a thread.
JniContext jni_context = {
    .jvm = NULL,
    .classLoader = NULL,
    .loadClassMethod = NULL,
    .appContext = NULL,
    .currentActivity = NULL,
};

JniContext* jni = &jni_context;
THREAD_LOCAL JNIEnv* jniEnv = NULL;
JniExceptionMethods exceptionMethods;

void init() {
#ifndef _WIN32
  // Init TLS keys.
  pthread_key_create(&tlsKey, detach_thread);
#endif

  // Init locks.
  init_lock(&jni_context.locks.classLoadingLock);

  // Init exception handling classes and methods.
  exceptionMethods.objectClass = FindClassUnchecked("java/lang/Object");
  exceptionMethods.exceptionClass = FindClassUnchecked("java/lang/Exception");
  exceptionMethods.printStreamClass = FindClassUnchecked("java/io/PrintStream");
  exceptionMethods.byteArrayOutputStreamClass =
      FindClassUnchecked("java/io/ByteArrayOutputStream");
  load_method(exceptionMethods.objectClass, &exceptionMethods.toStringMethod,
              "toString", "()Ljava/lang/String;");
  load_method(exceptionMethods.exceptionClass,
              &exceptionMethods.printStackTraceMethod, "printStackTrace",
              "(Ljava/io/PrintStream;)V");
  load_method(exceptionMethods.byteArrayOutputStreamClass,
              &exceptionMethods.byteArrayOutputStreamCtor, "<init>", "()V");
  load_method(exceptionMethods.printStreamClass,
              &exceptionMethods.printStreamCtor, "<init>",
              "(Ljava/io/OutputStream;)V");
}

void deinit() {
#ifndef _WIN32
  // Delete TLS keys.
  pthread_key_delete(tlsKey);
#endif

  // Destroy locks.
  destroy_lock(&jni_context.locks.classLoadingLock);

  // Delete references to exception handling classes.
  if (jniEnv != NULL) {
    (*jniEnv)->DeleteGlobalRef(jniEnv, exceptionMethods.objectClass);
    (*jniEnv)->DeleteGlobalRef(jniEnv, exceptionMethods.exceptionClass);
    (*jniEnv)->DeleteGlobalRef(jniEnv, exceptionMethods.printStreamClass);
    (*jniEnv)->DeleteGlobalRef(jniEnv,
                               exceptionMethods.byteArrayOutputStreamClass);
  }
}

JNIEXPORT void JNICALL JNI_OnUnload(JavaVM* jvm, void* reserved) {
  deinit();
}

/// Get JVM associated with current process.
/// Returns NULL if no JVM is running.
FFI_PLUGIN_EXPORT
JavaVM* GetJavaVM() {
  return jni_context.jvm;
}

// Android specifics

FFI_PLUGIN_EXPORT
jobject GetClassLoader() {
  attach_thread();
  return (*jniEnv)->NewGlobalRef(jniEnv, jni_context.classLoader);
}

FFI_PLUGIN_EXPORT
jobject GetApplicationContext() {
  attach_thread();
  return (*jniEnv)->NewGlobalRef(jniEnv, jni_context.appContext);
}

FFI_PLUGIN_EXPORT
jobject GetCurrentActivity() {
  attach_thread();
  return (*jniEnv)->NewGlobalRef(jniEnv, jni_context.currentActivity);
}

// JNI Initialization

#ifdef __ANDROID__
JNIEXPORT void JNICALL
Java_com_github_dart_1lang_jni_JniPlugin_initializeJni(JNIEnv* env,
                                                       jobject obj,
                                                       jobject appContext,
                                                       jobject classLoader) {
  jniEnv = env;
  (*env)->GetJavaVM(env, &jni_context.jvm);
  jni_context.classLoader = (*env)->NewGlobalRef(env, classLoader);
  jni_context.appContext = (*env)->NewGlobalRef(env, appContext);
  jclass classLoaderClass = (*env)->GetObjectClass(env, classLoader);
  jni_context.loadClassMethod =
      (*env)->GetMethodID(env, classLoaderClass, "loadClass",
                          "(Ljava/lang/String;)Ljava/lang/Class;");
  init();
}

JNIEXPORT void JNICALL
Java_com_github_dart_1lang_jni_JniPlugin_setJniActivity(JNIEnv* env,
                                                        jobject obj,
                                                        jobject activity,
                                                        jobject context) {
  jniEnv = env;
  if (jni_context.currentActivity != NULL) {
    (*env)->DeleteGlobalRef(env, jni_context.currentActivity);
  }
  jni_context.currentActivity = (*env)->NewGlobalRef(env, activity);
  if (jni_context.appContext != NULL) {
    (*env)->DeleteGlobalRef(env, jni_context.appContext);
  }
  jni_context.appContext = (*env)->NewGlobalRef(env, context);
}

// Sometimes you may get linker error trying to link JNI_CreateJavaVM APIs
// on Android NDK. So IFDEF is required.
#else
#ifdef _WIN32
// Pre-initialization of critical section on windows - this is required because
// there's no coordination between multiple isolates calling Spawn.
//
// Taken from https://stackoverflow.com/a/12858955
CRITICAL_SECTION spawnLock = {0};
BOOL WINAPI DllMain(HINSTANCE hinstDLL,   // handle to DLL module
                    DWORD fdwReason,      // reason for calling function
                    LPVOID lpReserved) {  // reserved
  switch (fdwReason) {
    case DLL_PROCESS_ATTACH:
      // Initialize once for each new process.
      // Return FALSE to fail DLL load.
      InitializeCriticalSection(&spawnLock);
      break;
    case DLL_THREAD_DETACH:
      if (jniEnv != NULL) {
        detach_thread(jniEnv);
      }
      break;
    case DLL_PROCESS_DETACH:
      // Perform any necessary cleanup.
      DeleteCriticalSection(&spawnLock);
      break;
  }
  return TRUE;  // Successful DLL_PROCESS_ATTACH.
}
#else
pthread_mutex_t spawnLock = PTHREAD_MUTEX_INITIALIZER;
#endif
FFI_PLUGIN_EXPORT
int SpawnJvm(JavaVMInitArgs* initArgs) {
  if (jni_context.jvm != NULL) {
    return DART_JNI_SINGLETON_EXISTS;
  }

  acquire_lock(&spawnLock);
  // Init may have happened in the meanwhile.
  if (jni_context.jvm != NULL) {
    release_lock(&spawnLock);
    return DART_JNI_SINGLETON_EXISTS;
  }
  JavaVMOption jvmopt[1];
  char class_path[] = "-Djava.class.path=.";
  jvmopt[0].optionString = class_path;
  JavaVMInitArgs vmArgs;
  if (!initArgs) {
    vmArgs.version = JNI_VERSION_1_6;
    vmArgs.nOptions = 1;
    vmArgs.options = jvmopt;
    vmArgs.ignoreUnrecognized = JNI_TRUE;
    initArgs = &vmArgs;
  }
  const long flag =
      JNI_CreateJavaVM(&jni_context.jvm, __ENVP_CAST & jniEnv, initArgs);
  if (flag != JNI_OK) {
    return flag;
  }
  init();
  release_lock(&spawnLock);

  return JNI_OK;
}
#endif

FFI_PLUGIN_EXPORT
JniExceptionDetails GetExceptionDetails(jthrowable exception) {
  JniExceptionDetails details;
  details.message = (*jniEnv)->CallObjectMethod(
      jniEnv, exception, exceptionMethods.toStringMethod);
  // No exception is thrown from toString.
  (*jniEnv)->ExceptionClear(jniEnv);
  jobject buffer =
      (*jniEnv)->NewObject(jniEnv, exceptionMethods.byteArrayOutputStreamClass,
                           exceptionMethods.byteArrayOutputStreamCtor);
  jobject printStream =
      (*jniEnv)->NewObject(jniEnv, exceptionMethods.printStreamClass,
                           exceptionMethods.printStreamCtor, buffer);
  (*jniEnv)->CallVoidMethod(
      jniEnv, exception, exceptionMethods.printStackTraceMethod, printStream);
  // No exception is thrown from printStackTrace.
  (*jniEnv)->ExceptionClear(jniEnv);
  details.stacktrace = (*jniEnv)->CallObjectMethod(
      jniEnv, buffer, exceptionMethods.toStringMethod);
  // No exception is thrown from toString.
  (*jniEnv)->ExceptionClear(jniEnv);
  details.message = to_global_ref(details.message);
  details.stacktrace = to_global_ref(details.stacktrace);
  return details;
}

// These will not be required after migrating to Dart-only bindings.
FFI_PLUGIN_EXPORT JniContext* GetJniContextPtr() {
  return jni;
}

FFI_PLUGIN_EXPORT JNIEnv* GetJniEnv() {
  if (jni_context.jvm == NULL) {
    return NULL;
  }
  attach_thread();
  return jniEnv;
}

FFI_PLUGIN_EXPORT intptr_t InitDartApiDL(void* data) {
  return Dart_InitializeApiDL(data);
}

FFI_PLUGIN_EXPORT int64_t GetCurrentIsolateId() {
  return (int64_t)Dart_CurrentIsolate_DL();
}

// com.github.dart_lang.jni.DartException
jclass _c_DartException = NULL;

jmethodID _m_DartException__ctor = NULL;
FFI_PLUGIN_EXPORT JniResult DartException__ctor(jstring message,
                                                jthrowable cause) {
  attach_thread();
  load_class_global_ref(
      &_c_DartException,
      "com/github/dart_lang/jni/PortProxyBuilder$DartException");
  if (_c_DartException == NULL)
    return (JniResult){.value = {.j = 0}, .exception = check_exception()};
  load_method(_c_DartException, &_m_DartException__ctor, "<init>",
              "(Ljava/lang/String;Ljava/lang/Throwable;)V");
  if (_m_DartException__ctor == NULL)
    return (JniResult){.value = {.j = 0}, .exception = check_exception()};
  jobject _result = (*jniEnv)->NewObject(
      jniEnv, _c_DartException, _m_DartException__ctor, message, cause);
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
  return NULL;  // Never happens.
}

FFI_PLUGIN_EXPORT
Dart_FinalizableHandle newBooleanFinalizableHandle(Dart_Handle object,
                                                   bool* reference) {
  return Dart_NewFinalizableHandle_DL(object, reference, 1, freeBoolean);
}

FFI_PLUGIN_EXPORT
void deleteFinalizableHandle(Dart_FinalizableHandle finalizableHandle,
                             Dart_Handle object) {
  Dart_DeleteFinalizableHandle_DL(finalizableHandle, object);
}

jclass _c_Object = NULL;
jclass _c_Long = NULL;

jmethodID _m_Long_init = NULL;

JNIEXPORT jobjectArray JNICALL
Java_com_github_dart_1lang_jni_PortProxyBuilder__1invoke(
    JNIEnv* env,
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
Java_com_github_dart_1lang_jni_PortProxyBuilder__1cleanUp(JNIEnv* env,
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
