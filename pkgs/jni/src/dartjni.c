#include <jni.h>
#include <stdint.h>

#include "dartjni.h"

struct jni_context jni = {NULL, NULL, NULL, NULL, NULL};

thread_local JNIEnv *jniEnv = NULL;

int jni_log_level = JNI_INFO;

FFI_PLUGIN_EXPORT
void SetJNILogging(int level) {
	jni_log_level = level;
}

void jni_log(int level, const char *format, ...) {
	// TODO(#16): This is not working.
	if (level >= jni_log_level) {
		va_list args;
        va_start(args, format);
#ifdef __ANDROID__
		__android_log_print(level, JNI_LOG_TAG, format, args);
#else
		// fprintf(stderr, "%s: ", JNI_LOG_TAG);
		vfprintf(stderr, format, args);
#endif
        va_end(args);
	}
}

FFI_PLUGIN_EXPORT struct jni_context GetJniContext() { return jni; }

/// Get JVM associated with current process.
/// Returns NULL if no JVM is running.
FFI_PLUGIN_EXPORT
JavaVM *GetJavaVM() { return jni.jvm; }

/// Returns Application classLoader (on Android), 
/// which can be used to load application and platform classes.
/// ...
/// On other platforms, NULL is returned.
FFI_PLUGIN_EXPORT
jobject GetClassLoader() {
	attach_thread();
	return (*jniEnv)->NewLocalRef(jniEnv, jni.classLoader);
}


/// Load class through platform-specific mechanism
/// ...
/// Currently uses application classloader on android,
/// and JNIEnv->FindClass on other platforms.
FFI_PLUGIN_EXPORT
jclass LoadClass(const char *name) {
	jclass cls = NULL;
	attach_thread();
	load_class(&cls, name);
	return cls;
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
	// Any publicly callable method
	// can be called from an unattached thread.
	// I Learned this the hard way.
	attach_thread();
	return (*jniEnv)->NewLocalRef(jniEnv, jni.appContext);
}

/// Returns current activity of the app
FFI_PLUGIN_EXPORT
jobject GetCurrentActivity() {
	attach_thread();
	return (*jniEnv)->NewLocalRef(jniEnv, jni.currentActivity);
}

FFI_PLUGIN_EXPORT
jstring ToJavaString(char *str) {
	attach_thread();
	jstring s = (*jniEnv)->NewStringUTF(jniEnv, str);
	jstring g = (*jniEnv)->NewGlobalRef(jniEnv, s);
	(*jniEnv)->DeleteLocalRef(jniEnv, s);
	return g;
}

FFI_PLUGIN_EXPORT
const char *GetJavaStringChars(jstring jstr) {
	const char *buf = (*jniEnv)->GetStringUTFChars(jniEnv, jstr, NULL);
	return buf;
}

FFI_PLUGIN_EXPORT
void ReleaseJavaStringChars(jstring jstr, const char *buf) {
	(*jniEnv)->ReleaseStringUTFChars(jniEnv, jstr, buf);
}

#ifdef __ANDROID__
JNIEXPORT void JNICALL Java_dev_dart_jni_JniPlugin_initializeJni(
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

JNIEXPORT void JNICALL Java_dev_dart_jni_JniPlugin_setJniActivity(JNIEnv *env, jobject obj, jobject activity, jobject context) {
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
	jni_log(JNI_DEBUG, "JNI Version: %d\n", initArgs->version);
	const long flag =
	    JNI_CreateJavaVM(&jni.jvm, __ENVP_CAST &jniEnv, initArgs);
	if (flag == JNI_ERR) {
		return NULL;
	}
	return jniEnv;
}
#endif

