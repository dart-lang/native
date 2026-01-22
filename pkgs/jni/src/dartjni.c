// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <jni.h>
#include <stdarg.h>
#include <stdint.h>

#include "dartjni.h"

#if !defined(_WIN32)
pthread_key_t tlsKey;
pthread_mutex_t spawnLock = PTHREAD_MUTEX_INITIALIZER;
#endif

int8_t captureStackTraceOnRelease = 0;

FFI_PLUGIN_EXPORT
void setCaptureStackTraceOnRelease(int8_t value) {
  captureStackTraceOnRelease = value;
}

FFI_PLUGIN_EXPORT
int8_t getCaptureStackTraceOnRelease() {
  return captureStackTraceOnRelease;
}

#include <string.h>

typedef struct JniClassCacheNode {
  char* name;
  jclass value;
  struct JniClassCacheNode* prev;
  struct JniClassCacheNode* next;
  struct JniClassCacheNode* hashNext;
} JniClassCacheNode;

typedef struct JniClassCache {
  JniClassCacheNode** buckets;
  JniClassCacheNode* head;
  JniClassCacheNode* tail;
  int capacity;
  int size;
  int bucketCount;
  MutexLock lock;
} JniClassCache;

// Default capacity 256
#define DEFAULT_CACHE_CAPACITY 256
// Load factor 0.75 roughly, so buckets = capacity * 1.33
#define DEFAULT_BUCKET_COUNT 341

JniClassCache jniClassCache = {
    .buckets = NULL,
    .head = NULL,
    .tail = NULL,
    .capacity = DEFAULT_CACHE_CAPACITY,
    .size = 0,
    .bucketCount = DEFAULT_BUCKET_COUNT,
};

static unsigned long hash_string(const char* str) {
  unsigned long hash = 5381;
  int c;
  while ((c = *str++))
    hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
  return hash;
}

static void init_cache_if_needed() {
  if (jniClassCache.buckets == NULL) {
    init_lock(&jniClassCache.lock);
    // Double checked locking
    acquire_lock(&jniClassCache.lock);
    if (jniClassCache.buckets == NULL) {
      jniClassCache.buckets = (JniClassCacheNode**)calloc(
          jniClassCache.bucketCount, sizeof(JniClassCacheNode*));
    }
    release_lock(&jniClassCache.lock);
  }
}

static void remove_node(JniClassCacheNode* node) {
  if (node->prev) {
    node->prev->next = node->next;
  } else {
    jniClassCache.head = node->next;
  }
  if (node->next) {
    node->next->prev = node->prev;
  } else {
    jniClassCache.tail = node->prev;
  }
}

static void add_to_head(JniClassCacheNode* node) {
  node->next = jniClassCache.head;
  node->prev = NULL;
  if (jniClassCache.head) {
    jniClassCache.head->prev = node;
  }
  jniClassCache.head = node;
  if (jniClassCache.tail == NULL) {
    jniClassCache.tail = node;
  }
}

static void move_to_head(JniClassCacheNode* node) {
  remove_node(node);
  add_to_head(node);
}

static void evict_tail() {
  if (jniClassCache.tail == NULL) return;
  JniClassCacheNode* node = jniClassCache.tail;

  // Remove from list
  remove_node(node);

  // Remove from buckets
  unsigned long hash = hash_string(node->name);
  int index = hash % jniClassCache.bucketCount;
  JniClassCacheNode* curr = jniClassCache.buckets[index];
  JniClassCacheNode* prev = NULL;
  while (curr != NULL) {
    if (curr == node) {
      if (prev) {
        prev->hashNext = curr->hashNext;
      } else {
        jniClassCache.buckets[index] = curr->hashNext;
      }
      break;
    }
    prev = curr;
    curr = curr->hashNext;
  }

  // Free resources
  attach_thread();
  (*jniEnv)->DeleteGlobalRef(jniEnv, node->value);
  free(node->name);
  free(node);
  jniClassCache.size--;
}

FFI_PLUGIN_EXPORT
void SetClassCacheSize(int size) {
  init_cache_if_needed();
  acquire_lock(&jniClassCache.lock);
  jniClassCache.capacity = size;
  while (jniClassCache.size > jniClassCache.capacity) {
    evict_tail();
  }
  release_lock(&jniClassCache.lock);
}

FFI_PLUGIN_EXPORT
JniClassLookupResult GetCachedClass(const char* name) {
  init_cache_if_needed();
  if (name == NULL) {
      return (JniClassLookupResult){NULL, NULL};
  }
  
  acquire_lock(&jniClassCache.lock);
  
  unsigned long hash = hash_string(name);
  int index = hash % jniClassCache.bucketCount;
  JniClassCacheNode* node = jniClassCache.buckets[index];
  
  while (node != NULL) {
    if (strcmp(node->name, name) == 0) {
      // Hit
      move_to_head(node);
      
      // Return a new global ref so the caller owns one, 
      // but the cache keeps its own global ref.
      // Wait, requirement says "Return NewGlobalRef". 
      // The cache holds a GlobalRef. We should hand out a NewGlobalRef 
      // so the user can release it without affecting the cache.
      
      // We need to attach thread to call NewGlobalRef
      attach_thread();
      jclass cls = (*jniEnv)->NewGlobalRef(jniEnv, node->value);
      release_lock(&jniClassCache.lock);
      return (JniClassLookupResult){cls, NULL};
    }
    node = node->hashNext;
  }
  
  // Miss
  // Release lock while loading class to avoid holding it during JNI call
  release_lock(&jniClassCache.lock);
  
  // Load class implementation (similar to FindClassUnchecked)
  attach_thread();
  jclass cls;
  load_class_platform(&cls, name);
  
  jthrowable exception = NULL;
  if ((*jniEnv)->ExceptionCheck(jniEnv)) {
      exception = check_exception();
      return (JniClassLookupResult){NULL, exception};
  }
  
  // Convert local to global for the cache
  jclass globalCls = (*jniEnv)->NewGlobalRef(jniEnv, cls);
  (*jniEnv)->DeleteLocalRef(jniEnv, cls);
  
  // Create new node
  JniClassCacheNode* newNode = (JniClassCacheNode*)malloc(sizeof(JniClassCacheNode));
  newNode->name = strdup(name); // Need strdup
  newNode->value = globalCls;
  newNode->hashNext = NULL;
  
  // Re-acquire lock to insert
  acquire_lock(&jniClassCache.lock);
  
  // Check if it was inserted while we were loading (double check)
  // Re-calculate hash/index as they are same
  node = jniClassCache.buckets[index];
  while (node != NULL) {
    if (strcmp(node->name, name) == 0) {
      // It was inserted by another thread. Use that one.
      move_to_head(node);
      // Free our speculative load
      (*jniEnv)->DeleteGlobalRef(jniEnv, newNode->value);
      free(newNode->name);
      free(newNode);
      
      jclass returnCls = (*jniEnv)->NewGlobalRef(jniEnv, node->value);
      release_lock(&jniClassCache.lock);
      return (JniClassLookupResult){returnCls, NULL};
    }
    node = node->hashNext;
  }
  
  // Insert new node
  if (jniClassCache.size >= jniClassCache.capacity) {
    evict_tail();
  }
  
  newNode->hashNext = jniClassCache.buckets[index];
  jniClassCache.buckets[index] = newNode;
  add_to_head(newNode);
  jniClassCache.size++;
  
  // Return a new global ref for the caller
  jclass returnCls = (*jniEnv)->NewGlobalRef(jniEnv, globalCls);
  
  release_lock(&jniClassCache.lock);
  
  return (JniClassLookupResult){returnCls, NULL};
}

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
};

JniContext* jni = &jni_context;
THREAD_LOCAL JNIEnv* jniEnv = NULL;
JniExceptionMethods exceptionMethods;

void init() {
#if !defined(_WIN32)
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
#if !defined(_WIN32)
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

// JNI Initialization
#if defined(__ANDROID__)
JNIEXPORT void JNICALL
Java_com_github_dart_1lang_jni_JniPlugin_setClassLoader(JNIEnv* env,
                                                        jclass clazz,
                                                        jobject classLoader) {
  jniEnv = env;
  (*env)->GetJavaVM(env, &jni_context.jvm);
  jni_context.classLoader = (*env)->NewGlobalRef(env, classLoader);
  jclass classLoaderClass = (*env)->GetObjectClass(env, classLoader);
  jni_context.loadClassMethod =
      (*env)->GetMethodID(env, classLoaderClass, "loadClass",
                          "(Ljava/lang/String;)Ljava/lang/Class;");
  init();
}

// Sometimes you may get linker error trying to link JNI_CreateJavaVM APIs
// on Android NDK. So IFDEF is required.
#else
#ifdef _WIN32
SRWLOCK spawnLock = SRWLOCK_INIT;

BOOL WINAPI DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpReserved) {
  switch (fdwReason) {
    case DLL_THREAD_DETACH:
      if (jniEnv != NULL) {
        detach_thread(jniEnv);
      }
      break;
  }
  return TRUE;
}
#endif
FFI_PLUGIN_EXPORT
JniErrorCode SpawnJvm(JavaVMInitArgs* initArgs) {
  if (jni_context.jvm != NULL) {
    return SINGLETON_EXISTS;
  }

  acquire_lock(&spawnLock);
  // Init may have happened in the meanwhile.
  if (jni_context.jvm != NULL) {
    release_lock(&spawnLock);
    return SINGLETON_EXISTS;
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

void freeStackTracePtr(void* isolate_callback_data, void* peer) {
  char** ptr = (char**)peer;
  if (*ptr != NULL) {
    free_mem(*ptr);
  }
  free_mem(peer);
}

FFI_PLUGIN_EXPORT
Dart_FinalizableHandle newStackTraceFinalizableHandle(Dart_Handle object,
                                                      char* reference) {
  return Dart_NewFinalizableHandle_DL(object, reference, 1, freeStackTracePtr);
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
    jobjectArray args,
    jboolean isBlocking,
    jboolean mayEnterIsolate) {
  CallbackResult* result = NULL;
  if (isBlocking) {
    result = (CallbackResult*)malloc(sizeof(CallbackResult));
  }
  if ((isolateId != (jlong)Dart_CurrentIsolate_DL() && !mayEnterIsolate) ||
      !isBlocking) {
    if (isBlocking) {
      init_lock(&result->lock);
      init_cond(&result->cond);
      acquire_lock(&result->lock);
      result->ready = 0;
      result->object = NULL;
    }

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

    if (isBlocking) {
      while (!result->ready) {
        wait_for(&result->cond, &result->lock);
      }

      release_lock(&result->lock);
      destroy_lock(&result->lock);
      destroy_cond(&result->cond);
    }
  } else {
    // Flutter-specific: `mayEnterIsolate` is `true` when the proxy was
    // constructed on the main thread and is being invoked on the main thread.
    //
    // When the current isolate is `null`, enter the main isolate that is pinned
    // to the main thread first before invoking the `functionPtr`.
    assert(Dart_CurrentIsolate_DL() == NULL ||
           Dart_CurrentIsolate_DL() == (Dart_Isolate)isolateId);
    bool mustEnterIsolate = Dart_CurrentIsolate_DL() == NULL && mayEnterIsolate;
    if (mustEnterIsolate) {
      Dart_EnterIsolate_DL((Dart_Isolate)isolateId);
    }
    typedef jobject (*DartCallback)(uint64_t, jobject, jobject);
    result->object = ((DartCallback)functionPtr)(
        port, (*env)->NewGlobalRef(env, methodDescriptor),
        (*env)->NewGlobalRef(env, args));
    if (mustEnterIsolate) {
      Dart_ExitIsolate_DL();
    }
  }
  if (!isBlocking) {
    // No result is created in this case, there is nothing to clean up either.
    return NULL;
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
