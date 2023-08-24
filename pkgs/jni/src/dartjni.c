// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <jni.h>
#include <stdarg.h>
#include <stdint.h>

#include "dartjni.h"

#include "include/dart_api_dl.h"

void initAllLocks(JniLocks* locks) {
  init_lock(&locks->classLoadingLock);
  init_lock(&locks->fieldLoadingLock);
  init_lock(&locks->methodLoadingLock);
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

thread_local JNIEnv* jniEnv = NULL;

JniExceptionMethods exceptionMethods;

void initExceptionHandling(JniExceptionMethods* methods) {
  methods->objectClass = FindClass("java/lang/Object");
  methods->exceptionClass = FindClass("java/lang/Exception");
  methods->printStreamClass = FindClass("java/io/PrintStream");
  methods->byteArrayOutputStreamClass =
      FindClass("java/io/ByteArrayOutputStream");
  load_method(methods->objectClass, &methods->toStringMethod, "toString",
              "()Ljava/lang/String;");
  load_method(methods->exceptionClass, &methods->printStackTraceMethod,
              "printStackTrace", "(Ljava/io/PrintStream;)V");
  load_method(methods->byteArrayOutputStreamClass,
              &methods->byteArrayOutputStreamCtor, "<init>", "()V");
  load_method(methods->printStreamClass, &methods->printStreamCtor, "<init>",
              "(Ljava/io/OutputStream;)V");
}

/// Get JVM associated with current process.
/// Returns NULL if no JVM is running.
FFI_PLUGIN_EXPORT
JavaVM* GetJavaVM() {
  return jni_context.jvm;
}

FFI_PLUGIN_EXPORT
jclass FindClass(const char* name) {
  jclass cls = NULL;
  attach_thread();
  load_class_global_ref(&cls, name);
  return cls;
};

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
  initAllLocks(&jni_context.locks);
  initExceptionHandling(&exceptionMethods);
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
  initAllLocks(&jni_context.locks);
  initExceptionHandling(&exceptionMethods);
  release_lock(&spawnLock);

  return JNI_OK;
}
#endif

// accessors - a bunch of functions which are directly called by jnigen generated bindings
// and also package:jni reflective method access.

JniClassLookupResult getClass(char* internalName) {
  JniClassLookupResult result = {NULL, NULL};
  result.value = FindClass(internalName);
  result.exception = check_exception();
  return result;
}

typedef void* (*MemberGetter)(JNIEnv* env, jclass clazz, char* name, char* sig);

static inline JniPointerResult _getId(MemberGetter getter,
                                      jclass cls,
                                      char* name,
                                      char* sig) {
  JniPointerResult result = {NULL, NULL};
  attach_thread();
  result.value = getter(jniEnv, cls, name, sig);
  result.exception = check_exception();
  return result;
}

JniPointerResult getMethodID(jclass cls, char* name, char* sig) {
  return _getId((MemberGetter)(*jniEnv)->GetMethodID, cls, name, sig);
}

JniPointerResult getStaticMethodID(jclass cls, char* name, char* sig) {
  return _getId((MemberGetter)(*jniEnv)->GetStaticMethodID, cls, name, sig);
}

JniPointerResult getFieldID(jclass cls, char* name, char* sig) {
  return _getId((MemberGetter)(*jniEnv)->GetFieldID, cls, name, sig);
}

JniPointerResult getStaticFieldID(jclass cls, char* name, char* sig) {
  return _getId((MemberGetter)(*jniEnv)->GetStaticFieldID, cls, name, sig);
}

JniResult callMethod(jobject obj,
                     jmethodID fieldID,
                     int callType,
                     jvalue* args) {
  attach_thread();
  jvalue result = {.j = 0};
  switch (callType) {
    case booleanType:
      result.z = (*jniEnv)->CallBooleanMethodA(jniEnv, obj, fieldID, args);
      break;
    case byteType:
      result.b = (*jniEnv)->CallByteMethodA(jniEnv, obj, fieldID, args);
      break;
    case shortType:
      result.s = (*jniEnv)->CallShortMethodA(jniEnv, obj, fieldID, args);
      break;
    case charType:
      result.c = (*jniEnv)->CallCharMethodA(jniEnv, obj, fieldID, args);
      break;
    case intType:
      result.i = (*jniEnv)->CallIntMethodA(jniEnv, obj, fieldID, args);
      break;
    case longType:
      result.j = (*jniEnv)->CallLongMethodA(jniEnv, obj, fieldID, args);
      break;
    case floatType:
      result.f = (*jniEnv)->CallFloatMethodA(jniEnv, obj, fieldID, args);
      break;
    case doubleType:
      result.d = (*jniEnv)->CallDoubleMethodA(jniEnv, obj, fieldID, args);
      break;
    case objectType:
      result.l = (*jniEnv)->CallObjectMethodA(jniEnv, obj, fieldID, args);
      break;
    case voidType:
      (*jniEnv)->CallVoidMethodA(jniEnv, obj, fieldID, args);
      break;
  }
  jthrowable exception = check_exception();
  if (callType == objectType && exception == NULL) {
    result.l = to_global_ref(result.l);
  }
  JniResult jniResult = {.value = result, .exception = exception};
  return jniResult;
}

// TODO(#60): Any way to reduce this boilerplate?
JniResult callStaticMethod(jclass cls,
                           jmethodID methodID,
                           int callType,
                           jvalue* args) {
  attach_thread();
  jvalue result = {.j = 0};
  switch (callType) {
    case booleanType:
      result.z =
          (*jniEnv)->CallStaticBooleanMethodA(jniEnv, cls, methodID, args);
      break;
    case byteType:
      result.b = (*jniEnv)->CallStaticByteMethodA(jniEnv, cls, methodID, args);
      break;
    case shortType:
      result.s = (*jniEnv)->CallStaticShortMethodA(jniEnv, cls, methodID, args);
      break;
    case charType:
      result.c = (*jniEnv)->CallStaticCharMethodA(jniEnv, cls, methodID, args);
      break;
    case intType:
      result.i = (*jniEnv)->CallStaticIntMethodA(jniEnv, cls, methodID, args);
      break;
    case longType:
      result.j = (*jniEnv)->CallStaticLongMethodA(jniEnv, cls, methodID, args);
      break;
    case floatType:
      result.f = (*jniEnv)->CallStaticFloatMethodA(jniEnv, cls, methodID, args);
      break;
    case doubleType:
      result.d =
          (*jniEnv)->CallStaticDoubleMethodA(jniEnv, cls, methodID, args);
      break;
    case objectType:
      result.l =
          (*jniEnv)->CallStaticObjectMethodA(jniEnv, cls, methodID, args);
      break;
    case voidType:
      (*jniEnv)->CallStaticVoidMethodA(jniEnv, cls, methodID, args);
      break;
  }
  jthrowable exception = check_exception();
  if (callType == objectType && exception == NULL) {
    result.l = to_global_ref(result.l);
  }
  JniResult jniResult = {.value = result, .exception = exception};
  return jniResult;
}

JniResult getField(jobject obj, jfieldID fieldID, int callType) {
  attach_thread();
  jvalue result = {.j = 0};
  switch (callType) {
    case booleanType:
      result.z = (*jniEnv)->GetBooleanField(jniEnv, obj, fieldID);
      break;
    case byteType:
      result.b = (*jniEnv)->GetByteField(jniEnv, obj, fieldID);
      break;
    case shortType:
      result.s = (*jniEnv)->GetShortField(jniEnv, obj, fieldID);
      break;
    case charType:
      result.c = (*jniEnv)->GetCharField(jniEnv, obj, fieldID);
      break;
    case intType:
      result.i = (*jniEnv)->GetIntField(jniEnv, obj, fieldID);
      break;
    case longType:
      result.j = (*jniEnv)->GetLongField(jniEnv, obj, fieldID);
      break;
    case floatType:
      result.f = (*jniEnv)->GetFloatField(jniEnv, obj, fieldID);
      break;
    case doubleType:
      result.d = (*jniEnv)->GetDoubleField(jniEnv, obj, fieldID);
      break;
    case objectType:
      result.l = (*jniEnv)->GetObjectField(jniEnv, obj, fieldID);
      break;
    case voidType:
      // This error should have been handled in Dart.
      break;
  }
  jthrowable exception = check_exception();
  if (callType == objectType && exception == NULL) {
    result.l = to_global_ref(result.l);
  }
  JniResult jniResult = {.value = result, .exception = exception};
  return jniResult;
}

FFI_PLUGIN_EXPORT
JniResult getStaticField(jclass cls, jfieldID fieldID, int callType) {
  attach_thread();
  jvalue result = {.j = 0};
  switch (callType) {
    case booleanType:
      result.z = (*jniEnv)->GetStaticBooleanField(jniEnv, cls, fieldID);
      break;
    case byteType:
      result.b = (*jniEnv)->GetStaticByteField(jniEnv, cls, fieldID);
      break;
    case shortType:
      result.s = (*jniEnv)->GetStaticShortField(jniEnv, cls, fieldID);
      break;
    case charType:
      result.c = (*jniEnv)->GetStaticCharField(jniEnv, cls, fieldID);
      break;
    case intType:
      result.i = (*jniEnv)->GetStaticIntField(jniEnv, cls, fieldID);
      break;
    case longType:
      result.j = (*jniEnv)->GetStaticLongField(jniEnv, cls, fieldID);
      break;
    case floatType:
      result.f = (*jniEnv)->GetStaticFloatField(jniEnv, cls, fieldID);
      break;
    case doubleType:
      result.d = (*jniEnv)->GetStaticDoubleField(jniEnv, cls, fieldID);
      break;
    case objectType:
      result.l = (*jniEnv)->GetStaticObjectField(jniEnv, cls, fieldID);
      break;
    case voidType:
      // This error should have been handled in dart.
      // is there a way to mark this as unreachable?
      // or throw exception in Dart using Dart's C API.
      break;
  }
  jthrowable exception = check_exception();
  if (callType == objectType && exception == NULL) {
    result.l = to_global_ref(result.l);
  }
  JniResult jniResult = {.value = result, .exception = exception};
  return jniResult;
}

JniResult newObject(jclass cls, jmethodID ctor, jvalue* args) {
  attach_thread();
  jobject result = (*jniEnv)->NewObjectA(jniEnv, cls, ctor, args);
  return to_global_ref_result(result);
}

JniResult newPrimitiveArray(jsize length, int type) {
  attach_thread();
  jarray array;
  switch (type) {
    case booleanType:
      array = (*jniEnv)->NewBooleanArray(jniEnv, length);
      break;
    case byteType:
      array = (*jniEnv)->NewByteArray(jniEnv, length);
      break;
    case shortType:
      array = (*jniEnv)->NewShortArray(jniEnv, length);
      break;
    case charType:
      array = (*jniEnv)->NewCharArray(jniEnv, length);
      break;
    case intType:
      array = (*jniEnv)->NewIntArray(jniEnv, length);
      break;
    case longType:
      array = (*jniEnv)->NewLongArray(jniEnv, length);
      break;
    case floatType:
      array = (*jniEnv)->NewFloatArray(jniEnv, length);
      break;
    case doubleType:
      array = (*jniEnv)->NewDoubleArray(jniEnv, length);
      break;
    case objectType:
    case voidType:
      // This error should have been handled in dart.
      // is there a way to mark this as unreachable?
      // or throw exception in Dart using Dart's C API.
      break;
  }
  return to_global_ref_result(array);
}

JniResult newObjectArray(jsize length,
                         jclass elementClass,
                         jobject initialElement) {
  attach_thread();
  jarray array =
      (*jniEnv)->NewObjectArray(jniEnv, length, elementClass, initialElement);
  return to_global_ref_result(array);
}

JniResult getArrayElement(jarray array, int index, int type) {
  JniResult result = {{.l = NULL}, NULL};
  attach_thread();
  jvalue value;
  switch (type) {
    case booleanType:
      (*jniEnv)->GetBooleanArrayRegion(jniEnv, array, index, 1, &value.z);
      break;
    case byteType:
      (*jniEnv)->GetByteArrayRegion(jniEnv, array, index, 1, &value.b);
      break;
    case shortType:
      (*jniEnv)->GetShortArrayRegion(jniEnv, array, index, 1, &value.s);
      break;
    case charType:
      (*jniEnv)->GetCharArrayRegion(jniEnv, array, index, 1, &value.c);
      break;
    case intType:
      (*jniEnv)->GetIntArrayRegion(jniEnv, array, index, 1, &value.i);
      break;
    case longType:
      (*jniEnv)->GetLongArrayRegion(jniEnv, array, index, 1, &value.j);
      break;
    case floatType:
      (*jniEnv)->GetFloatArrayRegion(jniEnv, array, index, 1, &value.f);
      break;
    case doubleType:
      (*jniEnv)->GetDoubleArrayRegion(jniEnv, array, index, 1, &value.d);
      break;
    case objectType:
      value.l = (*jniEnv)->GetObjectArrayElement(jniEnv, array, index);
    case voidType:
      // This error should have been handled in dart.
      // is there a way to mark this as unreachable?
      // or throw exception in Dart using Dart's C API.
      break;
  }
  jthrowable exception = check_exception();
  if (type == objectType && exception == NULL) {
    value.l = to_global_ref(value.l);
  }
  JniResult jniResult = {.value = value, .exception = exception};
  return jniResult;
}

JniExceptionDetails getExceptionDetails(jthrowable exception) {
  JniExceptionDetails details;
  details.message = (*jniEnv)->CallObjectMethod(
      jniEnv, exception, exceptionMethods.toStringMethod);
  jobject buffer =
      (*jniEnv)->NewObject(jniEnv, exceptionMethods.byteArrayOutputStreamClass,
                           exceptionMethods.byteArrayOutputStreamCtor);
  jobject printStream =
      (*jniEnv)->NewObject(jniEnv, exceptionMethods.printStreamClass,
                           exceptionMethods.printStreamCtor, buffer);
  (*jniEnv)->CallVoidMethod(
      jniEnv, exception, exceptionMethods.printStackTraceMethod, printStream);
  details.stacktrace = (*jniEnv)->CallObjectMethod(
      jniEnv, buffer, exceptionMethods.toStringMethod);
  details.message = to_global_ref(details.message);
  details.stacktrace = to_global_ref(details.stacktrace);
  return details;
}

JniAccessorsStruct accessors = {
    .getClass = getClass,
    .getFieldID = getFieldID,
    .getStaticFieldID = getStaticFieldID,
    .getMethodID = getMethodID,
    .getStaticMethodID = getStaticMethodID,
    .newObject = newObject,
    .newPrimitiveArray = newPrimitiveArray,
    .newObjectArray = newObjectArray,
    .getArrayElement = getArrayElement,
    .callMethod = callMethod,
    .callStaticMethod = callStaticMethod,
    .getField = getField,
    .getStaticField = getStaticField,
    .getExceptionDetails = getExceptionDetails,
};

FFI_PLUGIN_EXPORT JniAccessorsStruct* GetAccessors() {
  return &accessors;
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
