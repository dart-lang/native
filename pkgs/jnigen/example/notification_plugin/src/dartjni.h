// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#pragma once

#include <jni.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if _WIN32
#include <windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

#if defined _WIN32
#define thread_local __declspec(thread)
#else
#define thread_local __thread
#endif

#ifdef __ANDROID__
#include <android/log.h>
#endif

#define JNI_LOG_TAG "Dart-JNI"

#ifdef __ANDROID__
#define __ENVP_CAST (JNIEnv **)
#else
#define __ENVP_CAST (void **)
#endif

typedef struct JniContext {
	JavaVM *jvm;
	jobject classLoader;
	jmethodID loadClassMethod;
	jobject currentActivity;
	jobject appContext;
} JniContext;

extern thread_local JNIEnv *jniEnv;

extern JniContext jni;

enum DartJniLogLevel {
	JNI_VERBOSE = 2,
	JNI_DEBUG,
	JNI_INFO,
	JNI_WARN,
	JNI_ERROR
};

enum JniType {
	boolType = 0,
	byteType = 1,
	shortType = 2,
	charType = 3,
	intType = 4,
	longType = 5,
	floatType = 6,
	doubleType = 7,
	objectType = 8,
	voidType = 9,
};

FFI_PLUGIN_EXPORT JniContext GetJniContext();

FFI_PLUGIN_EXPORT JavaVM *GetJavaVM(void);

FFI_PLUGIN_EXPORT int DestroyJavaVM();

FFI_PLUGIN_EXPORT JNIEnv *GetJniEnv(void);

FFI_PLUGIN_EXPORT JNIEnv *SpawnJvm(JavaVMInitArgs *args);

FFI_PLUGIN_EXPORT jclass LoadClass(const char *name);

FFI_PLUGIN_EXPORT jobject GetClassLoader(void);

FFI_PLUGIN_EXPORT jobject GetApplicationContext(void);

FFI_PLUGIN_EXPORT jobject GetCurrentActivity(void);

/// For use by jni_gen's generated code
/// don't use these.

// these 2 fn ptr vars will be defined by generated code library
extern JniContext (*context_getter)(void);
extern JNIEnv *(*env_getter)(void);

// this function will be exported by generated code library
// it will set above 2 variables.
FFI_PLUGIN_EXPORT void setJniGetters(struct JniContext (*cg)(void),
		JNIEnv *(*eg)(void));

// `static inline` because `inline` doesn't work, it may still not
// inline the function in which case a linker error may be produced.
//
// There has to be a better way to do this. Either to force inlining on target
// platforms, or just leave it as normal function.

static inline void __load_class_into(jclass *cls, const char *name) {
#ifdef __ANDROID__
	jstring className = (*jniEnv)->NewStringUTF(jniEnv, name);
	*cls = (*jniEnv)->CallObjectMethod(jniEnv, jni.classLoader,
	                                   jni.loadClassMethod, className);
	(*jniEnv)->DeleteLocalRef(jniEnv, className);
#else
	*cls = (*jniEnv)->FindClass(jniEnv, name);
#endif
}

static inline void load_class(jclass *cls, const char *name) {
	if (*cls == NULL) {
		__load_class_into(cls, name);
	}
}

static inline void load_class_gr(jclass *cls, const char *name) {
	if (*cls == NULL) {
		jclass tmp;
		__load_class_into(&tmp, name);
		*cls = (*jniEnv)->NewGlobalRef(jniEnv, tmp);
		(*jniEnv)->DeleteLocalRef(jniEnv, tmp);
	}
}

static inline void attach_thread() {
	if (jniEnv == NULL) {
		(*jni.jvm)->AttachCurrentThread(jni.jvm, __ENVP_CAST & jniEnv,
		                                NULL);
	}
}

static inline void load_env() {
	if (jniEnv == NULL) {
		jni = context_getter();
		jniEnv = env_getter();
	}
}

static inline void load_method(jclass cls, jmethodID *res, const char *name,
                               const char *sig) {
	if (*res == NULL) {
		*res = (*jniEnv)->GetMethodID(jniEnv, cls, name, sig);
	}
}

static inline void load_static_method(jclass cls, jmethodID *res,
                                      const char *name, const char *sig) {
	if (*res == NULL) {
		*res = (*jniEnv)->GetStaticMethodID(jniEnv, cls, name, sig);
	}
}

static inline void load_field(jclass cls, jfieldID *res, const char *name,
                              const char *sig) {
	if (*res == NULL) {
		*res = (*jniEnv)->GetFieldID(jniEnv, cls, name, sig);
	}
}

static inline void load_static_field(jclass cls, jfieldID *res,
                                     const char *name, const char *sig) {
	if (*res == NULL) {
		*res = (*jniEnv)->GetStaticFieldID(jniEnv, cls, name, sig);
	}
}

static inline jobject to_global_ref(jobject ref) {
	jobject g = (*jniEnv)->NewGlobalRef(jniEnv, ref);
	(*jniEnv)->DeleteLocalRef(jniEnv, ref);
	return g;
}

