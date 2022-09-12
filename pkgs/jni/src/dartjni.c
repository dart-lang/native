// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include <jni.h>
#include <stdint.h>

#include "dartjni.h"

JniContext jni = {NULL, NULL, NULL, NULL, NULL};

thread_local JNIEnv *jniEnv = NULL;

FFI_PLUGIN_EXPORT JniContext GetJniContext() { return jni; }

/// Get JVM associated with current process.
/// Returns NULL if no JVM is running.
FFI_PLUGIN_EXPORT
JavaVM *GetJavaVM() { return jni.jvm; }

/// Destroys the JVM.
///
/// Returns 0 on success and appropriate error code on failure.
FFI_PLUGIN_EXPORT
int DestroyJavaVM() {
	int result = (*jni.jvm)->DestroyJavaVM(jni.jvm);
	jni.jvm = NULL;
	return result;
}

/// Returns Application classLoader (on Android), 
/// which can be used to load application and platform classes.
/// ...
/// On other platforms, NULL is returned.
FFI_PLUGIN_EXPORT
jobject GetClassLoader() {
	attach_thread();
	return (*jniEnv)->NewLocalRef(jniEnv, jni.classLoader);
}

/// Load class through platform-specific mechanism.
///
/// Currently uses application classloader on android,
/// and JNIEnv->FindClass on other platforms.
FFI_PLUGIN_EXPORT
jclass LoadClass(const char *name) {
	jclass cls = NULL;
	attach_thread();
	load_class(&cls, name);
	return to_global_ref(cls);
};

FFI_PLUGIN_EXPORT
JNIEnv *GetJniEnv() {
	if (jni.jvm == NULL) {
		return NULL;
	}
	attach_thread();
	return jniEnv;
}

/// Returns application context on Android.
///
/// On other platforms, NULL is returned.
FFI_PLUGIN_EXPORT
jobject GetApplicationContext() {
	attach_thread();
	return (*jniEnv)->NewGlobalRef(jniEnv, jni.appContext);
}

/// Returns current activity of the app
FFI_PLUGIN_EXPORT
jobject GetCurrentActivity() {
	attach_thread();
	return (*jniEnv)->NewGlobalRef(jniEnv, jni.currentActivity);
}

#ifdef __ANDROID__
JNIEXPORT void JNICALL Java_com_github_dart_1lang_jni_JniPlugin_initializeJni(
    JNIEnv *env, jobject obj, jobject appContext, jobject classLoader) {
	jniEnv = env;
	(*env)->GetJavaVM(env, &jni.jvm);
	jni.classLoader = (*env)->NewGlobalRef(env, classLoader);
	jni.appContext = (*env)->NewGlobalRef(env, appContext);
	jclass classLoaderClass = (*env)->GetObjectClass(env, classLoader);
	jni.loadClassMethod =
	    (*env)->GetMethodID(env, classLoaderClass, "loadClass",
	                        "(Ljava/lang/String;)Ljava/lang/Class;");
}

JNIEXPORT void JNICALL Java_com_github_dart_1lang_jni_JniPlugin_setJniActivity(JNIEnv *env, jobject obj, jobject activity, jobject context) {
	jniEnv = env;
	if (jni.currentActivity != NULL) {
		(*env)->DeleteGlobalRef(env, jni.currentActivity);
	}
	jni.currentActivity = (*env)->NewGlobalRef(env, activity);
	if (jni.appContext != NULL) {
		(*env)->DeleteGlobalRef(env, jni.appContext);
	}
	jni.appContext = (*env)->NewGlobalRef(env, context);
}

// Sometimes you may get linker error trying to link JNI_CreateJavaVM APIs
// on Android NDK. So IFDEF is required.
#else
FFI_PLUGIN_EXPORT
JNIEnv *SpawnJvm(JavaVMInitArgs *initArgs) {
	JavaVMOption jvmopt[1];
	char class_path[] = "-Djava.class.path=.";
	jvmopt[0].optionString = class_path;
	JavaVMInitArgs vmArgs;
	if (!initArgs) {
		vmArgs.version = JNI_VERSION_1_2;
		vmArgs.nOptions = 1;
		vmArgs.options = jvmopt;
		vmArgs.ignoreUnrecognized = JNI_TRUE;
		initArgs = &vmArgs;
	}
	const long flag =
	    JNI_CreateJavaVM(&jni.jvm, __ENVP_CAST &jniEnv, initArgs);
	if (flag == JNI_ERR) {
		return NULL;
	}
	return jniEnv;
}
#endif

