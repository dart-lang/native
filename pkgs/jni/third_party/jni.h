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

/* ANNOTATED COPY FOR DART JNI LIBRARY */

#pragma once

#include <stdarg.h>
#include <stdint.h>

/* Primitive types that match up with Java equivalents. */
typedef uint8_t jboolean; /* unsigned 8 bits */
typedef int8_t jbyte;     /* signed 8 bits */
typedef uint16_t jchar;   /* unsigned 16 bits */
typedef int16_t jshort;   /* signed 16 bits */
typedef int32_t jint;     /* signed 32 bits */
typedef int64_t jlong;    /* signed 64 bits */
typedef float jfloat;     /* 32-bit IEEE 754 */
typedef double jdouble;   /* 64-bit IEEE 754 */

/* "cardinal indices and sizes" */
typedef jint jsize;

#ifdef __cplusplus
/*
 * Reference types, in C++
 */
class _jobject
{
};
class _jclass : public _jobject
{
};
class _jstring : public _jobject
{
};
class _jarray : public _jobject
{
};
class _jobjectArray : public _jarray
{
};
class _jbooleanArray : public _jarray
{
};
class _jbyteArray : public _jarray
{
};
class _jcharArray : public _jarray
{
};
class _jshortArray : public _jarray
{
};
class _jintArray : public _jarray
{
};
class _jlongArray : public _jarray
{
};
class _jfloatArray : public _jarray
{
};
class _jdoubleArray : public _jarray
{
};
class _jthrowable : public _jobject
{
};

typedef _jobject *jobject;
typedef _jclass *jclass;
typedef _jstring *jstring;
typedef _jarray *jarray;
typedef _jobjectArray *jobjectArray;
typedef _jbooleanArray *jbooleanArray;
typedef _jbyteArray *jbyteArray;
typedef _jcharArray *jcharArray;
typedef _jshortArray *jshortArray;
typedef _jintArray *jintArray;
typedef _jlongArray *jlongArray;
typedef _jfloatArray *jfloatArray;
typedef _jdoubleArray *jdoubleArray;
typedef _jthrowable *jthrowable;
typedef _jobject *jweak;

#else /* not __cplusplus */

/*
 * Reference types, in C.
 */
typedef void *jobject;
typedef jobject jclass;
typedef jobject jstring;
typedef jobject jarray;
typedef jarray jobjectArray;
typedef jarray jbooleanArray;
typedef jarray jbyteArray;
typedef jarray jcharArray;
typedef jarray jshortArray;
typedef jarray jintArray;
typedef jarray jlongArray;
typedef jarray jfloatArray;
typedef jarray jdoubleArray;
typedef jobject jthrowable;
typedef jobject jweak;

#endif /* not __cplusplus */

struct _jfieldID;                   /* opaque structure */
typedef struct _jfieldID *jfieldID; /* field IDs */

struct _jmethodID;                    /* opaque structure */
typedef struct _jmethodID *jmethodID; /* method IDs */

struct JNIInvokeInterface;

typedef union jvalue
{
    jboolean z;
    jbyte b;
    jchar c;
    jshort s;
    jint i;
    jlong j;
    jfloat f;
    jdouble d;
    jobject l;
} jvalue;

typedef enum jobjectRefType
{
    JNIInvalidRefType = 0,
    JNILocalRefType = 1,
    JNIGlobalRefType = 2,
    JNIWeakGlobalRefType = 3
} jobjectRefType;

typedef struct
{
    const char *name;
    const char *signature;
    void *fnPtr;
} JNINativeMethod;

struct _JNIEnv;
struct _JavaVM;
typedef const struct JNINativeInterface *C_JNIEnv;

#if defined(__cplusplus)
typedef _JNIEnv JNIEnv;
typedef _JavaVM JavaVM;
#else
typedef const struct JNINativeInterface *JNIEnv;
typedef const struct JNIInvokeInterface *JavaVM;
#endif

/*
 * Table of interface function pointers.
 */
struct JNINativeInterface
{
    void *reserved0;
    void *reserved1;
    void *reserved2;
    void *reserved3;

    jint (*GetVersion)(JNIEnv *env);
    jclass (*DefineClass)(JNIEnv *env, const char *name, jobject loader, const jbyte *buf,
                          jsize bufLen);
    jclass (*FindClass)(JNIEnv *env, const char *name);

    jmethodID (*FromReflectedMethod)(JNIEnv *env, jobject method);
    jfieldID (*FromReflectedField)(JNIEnv *env, jobject field);

    /* spec doesn't show jboolean parameter */

    jobject (*ToReflectedMethod)(JNIEnv *env, jclass cls, jmethodID methodId, jboolean isStatic);

    jclass (*GetSuperclass)(JNIEnv *env, jclass clazz);
    jboolean (*IsAssignableFrom)(JNIEnv *env, jclass clazz1, jclass clazz2);

    /* spec doesn't show jboolean parameter */

    jobject (*ToReflectedField)(JNIEnv *env, jclass cls, jfieldID fieldID, jboolean isStatic);

    jint (*Throw)(JNIEnv *env, jthrowable obj);
    jint (*ThrowNew)(JNIEnv *env, jclass clazz, const char *message);
    jthrowable (*ExceptionOccurred)(JNIEnv *env);
    void (*ExceptionDescribe)(JNIEnv *env);
    void (*ExceptionClear)(JNIEnv *env);
    void (*FatalError)(JNIEnv *env, const char *msg);

    jint (*PushLocalFrame)(JNIEnv *env, jint capacity);
    jobject (*PopLocalFrame)(JNIEnv *env, jobject result);

    jobject (*NewGlobalRef)(JNIEnv *env, jobject obj);
    void (*DeleteGlobalRef)(JNIEnv *env, jobject globalRef);
    void (*DeleteLocalRef)(JNIEnv *env, jobject localRef);
    jboolean (*IsSameObject)(JNIEnv *env, jobject ref1, jobject ref2);

    jobject (*NewLocalRef)(JNIEnv *env, jobject obj);
    jint (*EnsureLocalCapacity)(JNIEnv *env, jint capacity);

    jobject (*AllocObject)(JNIEnv *env, jclass clazz);
    jobject (*NewObject)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jobject (*NewObjectV)(JNIEnv *, jclass, jmethodID, void *);
    jobject (*NewObjectA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);

    jclass (*GetObjectClass)(JNIEnv *env, jobject obj);
    jboolean (*IsInstanceOf)(JNIEnv *env, jobject obj, jclass clazz);
    jmethodID (*GetMethodID)(JNIEnv *env, jclass clazz, const char *name, const char *sig);

    jobject (*CallObjectMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    jobject (*CallObjectMethodV)(JNIEnv *, jobject, jmethodID, void *);
    jobject (*CallObjectMethodA)(JNIEnv *env, jobject obj, jmethodID methodID, const jvalue *args);
    jboolean (*CallBooleanMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    jboolean (*CallBooleanMethodV)(JNIEnv *, jobject, jmethodID, void *);
    jboolean (*CallBooleanMethodA)(JNIEnv *env, jobject obj, jmethodID methodId, const jvalue *args);
    jbyte (*CallByteMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    jbyte (*CallByteMethodV)(JNIEnv *, jobject, jmethodID, void *);
    jbyte (*CallByteMethodA)(JNIEnv *env, jobject obj, jmethodID methodID, const jvalue *args);
    jchar (*CallCharMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    jchar (*CallCharMethodV)(JNIEnv *, jobject, jmethodID, void *);
    jchar (*CallCharMethodA)(JNIEnv *env, jobject obj, jmethodID methodID, const jvalue *args);
    jshort (*CallShortMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    jshort (*CallShortMethodV)(JNIEnv *, jobject, jmethodID, void *);
    jshort (*CallShortMethodA)(JNIEnv *env, jobject obj, jmethodID methodID, const jvalue *args);
    jint (*CallIntMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    jint (*CallIntMethodV)(JNIEnv *, jobject, jmethodID, void *);
    jint (*CallIntMethodA)(JNIEnv *env, jobject obj, jmethodID methodID, const jvalue *args);
    jlong (*CallLongMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    jlong (*CallLongMethodV)(JNIEnv *, jobject, jmethodID, void *);
    jlong (*CallLongMethodA)(JNIEnv *env, jobject obj, jmethodID methodID, const jvalue *args);
    jfloat (*CallFloatMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    jfloat (*CallFloatMethodV)(JNIEnv *, jobject, jmethodID, void *);
    jfloat (*CallFloatMethodA)(JNIEnv *env, jobject obj, jmethodID methodID, const jvalue *args);
    jdouble (*CallDoubleMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    jdouble (*CallDoubleMethodV)(JNIEnv *, jobject, jmethodID, void *);
    jdouble (*CallDoubleMethodA)(JNIEnv *env, jobject obj, jmethodID methodID, const jvalue *args);
    void (*CallVoidMethod)(JNIEnv *env, jobject obj, jmethodID methodID, ...);
    void (*CallVoidMethodV)(JNIEnv *, jobject, jmethodID, void *);
    void (*CallVoidMethodA)(JNIEnv *env, jobject obj, jmethodID methodID, const jvalue *args);

    jobject (*CallNonvirtualObjectMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                          jmethodID methodID, ...);
    jobject (*CallNonvirtualObjectMethodV)(JNIEnv *, jobject, jclass,
                                           jmethodID, void *);
    jobject (*CallNonvirtualObjectMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                           jmethodID methodID, const jvalue *args);
    jboolean (*CallNonvirtualBooleanMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                            jmethodID methodID, ...);
    jboolean (*CallNonvirtualBooleanMethodV)(JNIEnv *, jobject, jclass,
                                             jmethodID, void *);
    jboolean (*CallNonvirtualBooleanMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                             jmethodID methodID, const jvalue *args);
    jbyte (*CallNonvirtualByteMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                      jmethodID methodID, ...);
    jbyte (*CallNonvirtualByteMethodV)(JNIEnv *, jobject, jclass,
                                       jmethodID, void *);
    jbyte (*CallNonvirtualByteMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                       jmethodID methodID, const jvalue *args);
    jchar (*CallNonvirtualCharMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                      jmethodID methodID, ...);
    jchar (*CallNonvirtualCharMethodV)(JNIEnv *, jobject, jclass,
                                       jmethodID, void *);
    jchar (*CallNonvirtualCharMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                       jmethodID methodID, const jvalue *args);
    jshort (*CallNonvirtualShortMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                        jmethodID methodID, ...);
    jshort (*CallNonvirtualShortMethodV)(JNIEnv *, jobject, jclass,
                                         jmethodID, void *);
    jshort (*CallNonvirtualShortMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                         jmethodID methodID, const jvalue *args);
    jint (*CallNonvirtualIntMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                    jmethodID methodID, ...);
    jint (*CallNonvirtualIntMethodV)(JNIEnv *, jobject, jclass,
                                     jmethodID, void *);
    jint (*CallNonvirtualIntMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                     jmethodID methodID, const jvalue *args);
    jlong (*CallNonvirtualLongMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                      jmethodID methodID, ...);
    jlong (*CallNonvirtualLongMethodV)(JNIEnv *, jobject, jclass,
                                       jmethodID, void *);
    jlong (*CallNonvirtualLongMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                       jmethodID methodID, const jvalue *args);
    jfloat (*CallNonvirtualFloatMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                      jmethodID methodID, ...);
    jfloat (*CallNonvirtualFloatMethodV)(JNIEnv *, jobject, jclass,
                                         jmethodID, void *);
    jfloat (*CallNonvirtualFloatMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                         jmethodID methodID, const jvalue *args);
    jdouble (*CallNonvirtualDoubleMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                      jmethodID methodID, ...);
    jdouble (*CallNonvirtualDoubleMethodV)(JNIEnv *, jobject, jclass,
                                           jmethodID, void *);
    jdouble (*CallNonvirtualDoubleMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                           jmethodID methodID, const jvalue *args);
    void (*CallNonvirtualVoidMethod)(JNIEnv *env, jobject obj, jclass clazz,
                                      jmethodID methodID, ...);
    void (*CallNonvirtualVoidMethodV)(JNIEnv *, jobject, jclass,
                                      jmethodID, void *);
    void (*CallNonvirtualVoidMethodA)(JNIEnv *env, jobject obj, jclass clazz,
                                      jmethodID methodID, const jvalue *args);

    jfieldID (*GetFieldID)(JNIEnv *env, jclass clazz, const char *name, const char *sig);

    jobject (*GetObjectField)(JNIEnv *env, jobject obj, jfieldID fieldID);
    jboolean (*GetBooleanField)(JNIEnv *env, jobject obj, jfieldID fieldID);
    jbyte (*GetByteField)(JNIEnv *env, jobject obj, jfieldID fieldID);
    jchar (*GetCharField)(JNIEnv *env, jobject obj, jfieldID fieldID);
    jshort (*GetShortField)(JNIEnv *env, jobject obj, jfieldID fieldID);
    jint (*GetIntField)(JNIEnv *env, jobject obj, jfieldID fieldID);
    jlong (*GetLongField)(JNIEnv *env, jobject obj, jfieldID fieldID);
    jfloat (*GetFloatField)(JNIEnv *env, jobject obj, jfieldID fieldID);
    jdouble (*GetDoubleField)(JNIEnv *env, jobject obj, jfieldID fieldID);

    void (*SetObjectField)(JNIEnv *env, jobject obj, jfieldID fieldID, jobject val);
    void (*SetBooleanField)(JNIEnv *env, jobject obj, jfieldID fieldID, jboolean val);
    void (*SetByteField)(JNIEnv *env, jobject obj, jfieldID fieldID, jbyte val);
    void (*SetCharField)(JNIEnv *env, jobject obj, jfieldID fieldID, jchar val);
    void (*SetShortField)(JNIEnv *env, jobject obj, jfieldID fieldID, jshort val);
    void (*SetIntField)(JNIEnv *env, jobject obj, jfieldID fieldID, jint val);
    void (*SetLongField)(JNIEnv *env, jobject obj, jfieldID fieldID, jlong val);
    void (*SetFloatField)(JNIEnv *env, jobject obj, jfieldID fieldID, jfloat val);
    void (*SetDoubleField)(JNIEnv *env, jobject obj, jfieldID fieldID, jdouble val);

    jmethodID (*GetStaticMethodID)(JNIEnv *env, jclass clazz, const char *name, const char *sig);

    jobject (*CallStaticObjectMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jobject (*CallStaticObjectMethodV)(JNIEnv *, jclass, jmethodID, void *);
    jobject (*CallStaticObjectMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);
    jboolean (*CallStaticBooleanMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jboolean (*CallStaticBooleanMethodV)(JNIEnv *, jclass, jmethodID,
                                         void *);
    jboolean (*CallStaticBooleanMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);
    jbyte (*CallStaticByteMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jbyte (*CallStaticByteMethodV)(JNIEnv *, jclass, jmethodID, void *);
    jbyte (*CallStaticByteMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);
    jchar (*CallStaticCharMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jchar (*CallStaticCharMethodV)(JNIEnv *, jclass, jmethodID, void *);
    jchar (*CallStaticCharMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);
    jshort (*CallStaticShortMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jshort (*CallStaticShortMethodV)(JNIEnv *, jclass, jmethodID, void *);
    jshort (*CallStaticShortMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);
    jint (*CallStaticIntMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jint (*CallStaticIntMethodV)(JNIEnv *, jclass, jmethodID, void *);
    jint (*CallStaticIntMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);
    jlong (*CallStaticLongMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jlong (*CallStaticLongMethodV)(JNIEnv *, jclass, jmethodID, void *);
    jlong (*CallStaticLongMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);
    jfloat (*CallStaticFloatMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jfloat (*CallStaticFloatMethodV)(JNIEnv *, jclass, jmethodID, void *);
    jfloat (*CallStaticFloatMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);
    jdouble (*CallStaticDoubleMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    jdouble (*CallStaticDoubleMethodV)(JNIEnv *, jclass, jmethodID, void *);
    jdouble (*CallStaticDoubleMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);
    void (*CallStaticVoidMethod)(JNIEnv *env, jclass clazz, jmethodID methodID, ...);
    void (*CallStaticVoidMethodV)(JNIEnv *, jclass, jmethodID, void *);
    void (*CallStaticVoidMethodA)(JNIEnv *env, jclass clazz, jmethodID methodID, const jvalue *args);

    jfieldID (*GetStaticFieldID)(JNIEnv *env, jclass clazz, const char *name,
                                 const char *sig);

    jobject (*GetStaticObjectField)(JNIEnv *env, jclass clazz, jfieldID fieldID);
    jboolean (*GetStaticBooleanField)(JNIEnv *env, jclass clazz, jfieldID fieldID);
    jbyte (*GetStaticByteField)(JNIEnv *env, jclass clazz, jfieldID fieldID);
    jchar (*GetStaticCharField)(JNIEnv *env, jclass clazz, jfieldID fieldID);
    jshort (*GetStaticShortField)(JNIEnv *env, jclass clazz, jfieldID fieldID);
    jint (*GetStaticIntField)(JNIEnv *env, jclass clazz, jfieldID fieldID);
    jlong (*GetStaticLongField)(JNIEnv *env, jclass clazz, jfieldID fieldID);
    jfloat (*GetStaticFloatField)(JNIEnv *env, jclass clazz, jfieldID fieldID);
    jdouble (*GetStaticDoubleField)(JNIEnv *env, jclass clazz, jfieldID fieldID);

    void (*SetStaticObjectField)(JNIEnv *env, jclass clazz, jfieldID fieldID, jobject val);
    void (*SetStaticBooleanField)(JNIEnv *env, jclass clazz, jfieldID fieldID, jboolean val);
    void (*SetStaticByteField)(JNIEnv *env, jclass clazz, jfieldID fieldID, jbyte val);
    void (*SetStaticCharField)(JNIEnv *env, jclass clazz, jfieldID fieldID, jchar val);
    void (*SetStaticShortField)(JNIEnv *env, jclass clazz, jfieldID fieldID, jshort val);
    void (*SetStaticIntField)(JNIEnv *env, jclass clazz, jfieldID fieldID, jint val);
    void (*SetStaticLongField)(JNIEnv *env, jclass clazz, jfieldID fieldID, jlong val);
    void (*SetStaticFloatField)(JNIEnv *env, jclass clazz, jfieldID fieldID, jfloat val);
    void (*SetStaticDoubleField)(JNIEnv *env, jclass clazz, jfieldID fieldID, jdouble val);

    jstring (*NewString)(JNIEnv *env, const jchar *unicodeChars, jsize len);
    jsize (*GetStringLength)(JNIEnv *env, jstring string);
    const jchar *(*GetStringChars)(JNIEnv *env, jstring string, jboolean *isCopy);
    void (*ReleaseStringChars)(JNIEnv *env, jstring string, const jchar *isCopy);
    jstring (*NewStringUTF)(JNIEnv *env, const char *bytes);
    jsize (*GetStringUTFLength)(JNIEnv *env, jstring string);
    const char *(*GetStringUTFChars)(JNIEnv *env, jstring string, jboolean *isCopy);
    void (*ReleaseStringUTFChars)(JNIEnv *env, jstring string, const char *utf);
    jsize (*GetArrayLength)(JNIEnv *env, jarray array);
    jobjectArray (*NewObjectArray)(JNIEnv *env, jsize length, jclass elementClass, jobject initialElement);
    jobject (*GetObjectArrayElement)(JNIEnv *env, jobjectArray array, jsize index);
    void (*SetObjectArrayElement)(JNIEnv *env, jobjectArray array, jsize index, jobject val);

    jbooleanArray (*NewBooleanArray)(JNIEnv *env, jsize length);
    jbyteArray (*NewByteArray)(JNIEnv *env, jsize length);
    jcharArray (*NewCharArray)(JNIEnv *env, jsize length);
    jshortArray (*NewShortArray)(JNIEnv *env, jsize length);
    jintArray (*NewIntArray)(JNIEnv *env, jsize length);
    jlongArray (*NewLongArray)(JNIEnv *env, jsize length);
    jfloatArray (*NewFloatArray)(JNIEnv *env, jsize length);
    jdoubleArray (*NewDoubleArray)(JNIEnv *env, jsize length);

    jboolean *(*GetBooleanArrayElements)(JNIEnv *env, jbooleanArray array, jboolean *isCopy);
    jbyte *(*GetByteArrayElements)(JNIEnv *env, jbyteArray array, jboolean *isCopy);
    jchar *(*GetCharArrayElements)(JNIEnv *env, jcharArray array, jboolean *isCopy);
    jshort *(*GetShortArrayElements)(JNIEnv *env, jshortArray array, jboolean *isCopy);
    jint *(*GetIntArrayElements)(JNIEnv *env, jintArray array, jboolean *isCopy);
    jlong *(*GetLongArrayElements)(JNIEnv *env, jlongArray array, jboolean *isCopy);
    jfloat *(*GetFloatArrayElements)(JNIEnv *env, jfloatArray array, jboolean *isCopy);
    jdouble *(*GetDoubleArrayElements)(JNIEnv *env, jdoubleArray array, jboolean *isCopy);

    void (*ReleaseBooleanArrayElements)(JNIEnv *env, jbooleanArray array,
                                        jboolean *elems, jint mode);
    void (*ReleaseByteArrayElements)(JNIEnv *env, jbyteArray array,
                                     jbyte *elems, jint mode);
    void (*ReleaseCharArrayElements)(JNIEnv *env, jcharArray array,
                                     jchar *elems, jint mode);
    void (*ReleaseShortArrayElements)(JNIEnv *env, jshortArray array,
                                      jshort *elems, jint mode);
    void (*ReleaseIntArrayElements)(JNIEnv *env, jintArray array,
                                    jint *elems, jint mode);
    void (*ReleaseLongArrayElements)(JNIEnv *env, jlongArray array,
                                     jlong *elems, jint mode);
    void (*ReleaseFloatArrayElements)(JNIEnv *env, jfloatArray array,
                                      jfloat *elems, jint mode);
    void (*ReleaseDoubleArrayElements)(JNIEnv *env, jdoubleArray array,
                                       jdouble *elems, jint mode);

    void (*GetBooleanArrayRegion)(JNIEnv *env, jbooleanArray array,
                                  jsize start, jsize len, jboolean *buf);
    void (*GetByteArrayRegion)(JNIEnv *env, jbyteArray array,
                               jsize start, jsize len, jbyte *buf);
    void (*GetCharArrayRegion)(JNIEnv *env, jcharArray array,
                               jsize start, jsize len, jchar *buf);
    void (*GetShortArrayRegion)(JNIEnv *env, jshortArray array,
                                jsize start, jsize len, jshort *buf);
    void (*GetIntArrayRegion)(JNIEnv *env, jintArray array,
                              jsize start, jsize len, jint *buf);
    void (*GetLongArrayRegion)(JNIEnv *env, jlongArray array,
                               jsize start, jsize len, jlong *buf);
    void (*GetFloatArrayRegion)(JNIEnv *env, jfloatArray array,
                                jsize start, jsize len, jfloat *buf);
    void (*GetDoubleArrayRegion)(JNIEnv *env, jdoubleArray array,
                                 jsize start, jsize len, jdouble *buf);

    /* spec shows these without const; some jni.h do, some don't */
    void (*SetBooleanArrayRegion)(JNIEnv *env, jbooleanArray array,
                                  jsize start, jsize len, const jboolean *buf);
    void (*SetByteArrayRegion)(JNIEnv *env, jbyteArray array,
                               jsize start, jsize len, const jbyte *buf);
    void (*SetCharArrayRegion)(JNIEnv *env, jcharArray array,
                               jsize start, jsize len, const jchar *buf);
    void (*SetShortArrayRegion)(JNIEnv *env, jshortArray array,
                                jsize start, jsize len, const jshort *buf);
    void (*SetIntArrayRegion)(JNIEnv *env, jintArray array,
                              jsize start, jsize len, const jint *buf);
    void (*SetLongArrayRegion)(JNIEnv *env, jlongArray array,
                               jsize start, jsize len, const jlong *buf);
    void (*SetFloatArrayRegion)(JNIEnv *env, jfloatArray array,
                                jsize start, jsize len, const jfloat *buf);
    void (*SetDoubleArrayRegion)(JNIEnv *env, jdoubleArray array,
                                 jsize start, jsize len, const jdouble *buf);

    jint (*RegisterNatives)(JNIEnv *env, jclass clazz, const JNINativeMethod *methods,
                            jint nMethods);
    jint (*UnregisterNatives)(JNIEnv *env, jclass clazz);
    jint (*MonitorEnter)(JNIEnv *env, jobject obj);
    jint (*MonitorExit)(JNIEnv *env, jobject obj);
    jint (*GetJavaVM)(JNIEnv *env, JavaVM **vm);

    void (*GetStringRegion)(JNIEnv *env, jstring str, jsize start, jsize len, jchar *buf);
    void (*GetStringUTFRegion)(JNIEnv *env, jstring str, jsize start, jsize len, char *buf);

    void *(*GetPrimitiveArrayCritical)(JNIEnv *env, jarray array, jboolean *isCopy);
    void (*ReleasePrimitiveArrayCritical)(JNIEnv *env, jarray array, void *carray, jint mode);

    const jchar *(*GetStringCritical)(JNIEnv *env, jstring str, jboolean *isCopy);
    void (*ReleaseStringCritical)(JNIEnv *env, jstring str, const jchar *carray);

    jweak (*NewWeakGlobalRef)(JNIEnv *env, jobject obj);
    void (*DeleteWeakGlobalRef)(JNIEnv *env, jweak obj);

    jboolean (*ExceptionCheck)(JNIEnv *env);

    jobject (*NewDirectByteBuffer)(JNIEnv *env, void *address, jlong capacity);
    void *(*GetDirectBufferAddress)(JNIEnv *env, jobject buf);
    jlong (*GetDirectBufferCapacity)(JNIEnv *env, jobject buf);

    /* added in JNI 1.6 */
    jobjectRefType (*GetObjectRefType)(JNIEnv *env, jobject obj);
};

/*
 * C++ object wrapper.
 *
 * This is usually overlaid on a C struct whose first element is a
 * JNINativeInterface*.  We rely somewhat on compiler behavior.
 */
struct _JNIEnv
{
    /* do not rename this; it does not seem to be entirely opaque */
    const struct JNINativeInterface *functions;

#if defined(__cplusplus)

    jint GetVersion()
    {
        return functions->GetVersion(this);
    }

    jclass DefineClass(const char *name, jobject loader, const jbyte *buf,
                       jsize bufLen)
    {
        return functions->DefineClass(this, name, loader, buf, bufLen);
    }

    jclass FindClass(const char *name)
    {
        return functions->FindClass(this, name);
    }

    jmethodID FromReflectedMethod(jobject method)
    {
        return functions->FromReflectedMethod(this, method);
    }

    jfieldID FromReflectedField(jobject field)
    {
        return functions->FromReflectedField(this, field);
    }

    jobject ToReflectedMethod(jclass cls, jmethodID methodID, jboolean isStatic)
    {
        return functions->ToReflectedMethod(this, cls, methodID, isStatic);
    }

    jclass GetSuperclass(jclass clazz)
    {
        return functions->GetSuperclass(this, clazz);
    }

    jboolean IsAssignableFrom(jclass clazz1, jclass clazz2)
    {
        return functions->IsAssignableFrom(this, clazz1, clazz2);
    }

    jobject ToReflectedField(jclass cls, jfieldID fieldID, jboolean isStatic)
    {
        return functions->ToReflectedField(this, cls, fieldID, isStatic);
    }

    jint Throw(jthrowable obj)
    {
        return functions->Throw(this, obj);
    }

    jint ThrowNew(jclass clazz, const char *message)
    {
        return functions->ThrowNew(this, clazz, message);
    }

    jthrowable ExceptionOccurred()
    {
        return functions->ExceptionOccurred(this);
    }

    void ExceptionDescribe()
    {
        functions->ExceptionDescribe(this);
    }

    void ExceptionClear()
    {
        functions->ExceptionClear(this);
    }

    void FatalError(const char *msg)
    {
        functions->FatalError(this, msg);
    }

    jint PushLocalFrame(jint capacity)
    {
        return functions->PushLocalFrame(this, capacity);
    }

    jobject PopLocalFrame(jobject result)
    {
        return functions->PopLocalFrame(this, result);
    }

    jobject NewGlobalRef(jobject obj)
    {
        return functions->NewGlobalRef(this, obj);
    }

    void DeleteGlobalRef(jobject globalRef)
    {
        functions->DeleteGlobalRef(this, globalRef);
    }

    void DeleteLocalRef(jobject localRef)
    {
        functions->DeleteLocalRef(this, localRef);
    }

    jboolean IsSameObject(jobject ref1, jobject ref2)
    {
        return functions->IsSameObject(this, ref1, ref2);
    }

    jobject NewLocalRef(jobject obj)
    {
        return functions->NewLocalRef(this, ref);
    }

    jint EnsureLocalCapacity(jint capacity)
    {
        return functions->EnsureLocalCapacity(this, capacity);
    }

    jobject AllocObject(jclass clazz)
    {
        return functions->AllocObject(this, clazz);
    }

    jobject NewObject(jclass clazz, jmethodID methodID, ...)
    {
        va_list args;
        va_start(args, methodID);
        jobject result = functions->NewObjectV(this, clazz, methodID, args);
        va_end(args);
        return result;
    }

    jobject NewObjectV(jclass clazz, jmethodID methodID, va_list args)
    {
        return functions->NewObjectV(this, clazz, methodID, args);
    }

    jobject NewObjectA(jclass clazz, jmethodID methodID, const jvalue *args)
    {
        return functions->NewObjectA(this, clazz, methodID, args);
    }

    jclass GetObjectClass(jobject obj)
    {
        return functions->GetObjectClass(this, obj);
    }

    jboolean IsInstanceOf(jobject obj, jclass clazz)
    {
        return functions->IsInstanceOf(this, obj, clazz);
    }

    jmethodID GetMethodID(jclass clazz, const char *name, const char *sig)
    {
        return functions->GetMethodID(this, clazz, name, sig);
    }

#define CALL_TYPE_METHOD(_jtype, _jname)                               \
    _jtype Call##_jname##Method(jobject obj, jmethodID methodID, ...)  \
    {                                                                  \
        _jtype result;                                                 \
        va_list args;                                                  \
        va_start(args, methodID);                                      \
        result = functions->Call##_jname##MethodV(this, obj, methodID, \
                                                  args);               \
        va_end(args);                                                  \
        return result;                                                 \
    }
#define CALL_TYPE_METHODV(_jtype, _jname)                                   \
    _jtype Call##_jname##MethodV(jobject obj, jmethodID methodID,           \
                                 va_list args)                              \
    {                                                                       \
        return functions->Call##_jname##MethodV(this, obj, methodID, args); \
    }
#define CALL_TYPE_METHODA(_jtype, _jname)                                   \
    _jtype Call##_jname##MethodA(jobject obj, jmethodID methodID,           \
                                 const jvalue *args)                        \
    {                                                                       \
        return functions->Call##_jname##MethodA(this, obj, methodID, args); \
    }

#define CALL_TYPE(_jtype, _jname)     \
    CALL_TYPE_METHOD(_jtype, _jname)  \
    CALL_TYPE_METHODV(_jtype, _jname) \
    CALL_TYPE_METHODA(_jtype, _jname)

    CALL_TYPE(jobject, Object)
    CALL_TYPE(jboolean, Boolean)
    CALL_TYPE(jbyte, Byte)
    CALL_TYPE(jchar, Char)
    CALL_TYPE(jshort, Short)
    CALL_TYPE(jint, Int)
    CALL_TYPE(jlong, Long)
    CALL_TYPE(jfloat, Float)
    CALL_TYPE(jdouble, Double)

    void CallVoidMethod(jobject obj, jmethodID methodID, ...)
    {
        va_list args;
        va_start(args, methodID);
        functions->CallVoidMethodV(this, obj, methodID, args);
        va_end(args);
    }
    void CallVoidMethodV(jobject obj, jmethodID methodID, va_list args)
    {
        functions->CallVoidMethodV(this, obj, methodID, args);
    }
    void CallVoidMethodA(jobject obj, jmethodID methodID, const jvalue *args)
    {
        functions->CallVoidMethodA(this, obj, methodID, args);
    }

#define CALL_NONVIRT_TYPE_METHOD(_jtype, _jname)                                    \
    _jtype CallNonvirtual##_jname##Method(jobject obj, jclass clazz,                \
                                          jmethodID methodID, ...)                  \
    {                                                                               \
        _jtype result;                                                              \
        va_list args;                                                               \
        va_start(args, methodID);                                                   \
        result = functions->CallNonvirtual##_jname##MethodV(this, obj,              \
                                                            clazz, methodID, args); \
        va_end(args);                                                               \
        return result;                                                              \
    }
#define CALL_NONVIRT_TYPE_METHODV(_jtype, _jname)                            \
    _jtype CallNonvirtual##_jname##MethodV(jobject obj, jclass clazz,        \
                                           jmethodID methodID, va_list args) \
    {                                                                        \
        return functions->CallNonvirtual##_jname##MethodV(this, obj, clazz,  \
                                                          methodID, args);   \
    }
#define CALL_NONVIRT_TYPE_METHODA(_jtype, _jname)                                  \
    _jtype CallNonvirtual##_jname##MethodA(jobject obj, jclass clazz,              \
                                           jmethodID methodID, const jvalue *args) \
    {                                                                              \
        return functions->CallNonvirtual##_jname##MethodA(this, obj, clazz,        \
                                                          methodID, args);         \
    }

#define CALL_NONVIRT_TYPE(_jtype, _jname)     \
    CALL_NONVIRT_TYPE_METHOD(_jtype, _jname)  \
    CALL_NONVIRT_TYPE_METHODV(_jtype, _jname) \
    CALL_NONVIRT_TYPE_METHODA(_jtype, _jname)

    CALL_NONVIRT_TYPE(jobject, Object)
    CALL_NONVIRT_TYPE(jboolean, Boolean)
    CALL_NONVIRT_TYPE(jbyte, Byte)
    CALL_NONVIRT_TYPE(jchar, Char)
    CALL_NONVIRT_TYPE(jshort, Short)
    CALL_NONVIRT_TYPE(jint, Int)
    CALL_NONVIRT_TYPE(jlong, Long)
    CALL_NONVIRT_TYPE(jfloat, Float)
    CALL_NONVIRT_TYPE(jdouble, Double)

    void CallNonvirtualVoidMethod(jobject obj, jclass clazz,
                                  jmethodID methodID, ...)
    {
        va_list args;
        va_start(args, methodID);
        functions->CallNonvirtualVoidMethodV(this, obj, clazz, methodID, args);
        va_end(args);
    }
    void CallNonvirtualVoidMethodV(jobject obj, jclass clazz,
                                   jmethodID methodID, va_list args)
    {
        functions->CallNonvirtualVoidMethodV(this, obj, clazz, methodID, args);
    }
    void CallNonvirtualVoidMethodA(jobject obj, jclass clazz,
                                   jmethodID methodID, const jvalue *args)
    {
        functions->CallNonvirtualVoidMethodA(this, obj, clazz, methodID, args);
    }

    jfieldID GetFieldID(jclass clazz, const char *name, const char *sig)
    {
        return functions->GetFieldID(this, clazz, name, sig);
    }

    jobject GetObjectField(jobject obj, jfieldID fieldID)
    {
        return functions->GetObjectField(this, obj, fieldID);
    }
    jboolean GetBooleanField(jobject obj, jfieldID fieldID)
    {
        return functions->GetBooleanField(this, obj, fieldID);
    }
    jbyte GetByteField(jobject obj, jfieldID fieldID)
    {
        return functions->GetByteField(this, obj, fieldID);
    }
    jchar GetCharField(jobject obj, jfieldID fieldID)
    {
        return functions->GetCharField(this, obj, fieldID);
    }
    jshort GetShortField(jobject obj, jfieldID fieldID)
    {
        return functions->GetShortField(this, obj, fieldID);
    }
    jint GetIntField(jobject obj, jfieldID fieldID)
    {
        return functions->GetIntField(this, obj, fieldID);
    }
    jlong GetLongField(jobject obj, jfieldID fieldID)
    {
        return functions->GetLongField(this, obj, fieldID);
    }
    jfloat GetFloatField(jobject obj, jfieldID fieldID)
    {
        return functions->GetFloatField(this, obj, fieldID);
    }
    jdouble GetDoubleField(jobject obj, jfieldID fieldID)
    {
        return functions->GetDoubleField(this, obj, fieldID);
    }

    void SetObjectField(jobject obj, jfieldID fieldID, jobject val)
    {
        functions->SetObjectField(this, obj, fieldID, val);
    }
    void SetBooleanField(jobject obj, jfieldID fieldID, jboolean val)
    {
        functions->SetBooleanField(this, obj, fieldID, val);
    }
    void SetByteField(jobject obj, jfieldID fieldID, jbyte val)
    {
        functions->SetByteField(this, obj, fieldID, val);
    }
    void SetCharField(jobject obj, jfieldID fieldID, jchar val)
    {
        functions->SetCharField(this, obj, fieldID, val);
    }
    void SetShortField(jobject obj, jfieldID fieldID, jshort val)
    {
        functions->SetShortField(this, obj, fieldID, val);
    }
    void SetIntField(jobject obj, jfieldID fieldID, jint val)
    {
        functions->SetIntField(this, obj, fieldID, val);
    }
    void SetLongField(jobject obj, jfieldID fieldID, jlong val)
    {
        functions->SetLongField(this, obj, fieldID, val);
    }
    void SetFloatField(jobject obj, jfieldID fieldID, jfloat val)
    {
        functions->SetFloatField(this, obj, fieldID, val);
    }
    void SetDoubleField(jobject obj, jfieldID fieldID, jdouble val)
    {
        functions->SetDoubleField(this, obj, fieldID, val);
    }

    jmethodID GetStaticMethodID(jclass clazz, const char *name, const char *sig)
    {
        return functions->GetStaticMethodID(this, clazz, name, sig);
    }

#define CALL_STATIC_TYPE_METHOD(_jtype, _jname)                          \
    _jtype CallStatic##_jname##Method(jclass clazz, jmethodID methodID,  \
                                      ...)                               \
    {                                                                    \
        _jtype result;                                                   \
        va_list args;                                                    \
        va_start(args, methodID);                                        \
        result = functions->CallStatic##_jname##MethodV(this, clazz,     \
                                                        methodID, args); \
        va_end(args);                                                    \
        return result;                                                   \
    }
#define CALL_STATIC_TYPE_METHODV(_jtype, _jname)                             \
    _jtype CallStatic##_jname##MethodV(jclass clazz, jmethodID methodID,     \
                                       va_list args)                         \
    {                                                                        \
        return functions->CallStatic##_jname##MethodV(this, clazz, methodID, \
                                                      args);                 \
    }
#define CALL_STATIC_TYPE_METHODA(_jtype, _jname)                             \
    _jtype CallStatic##_jname##MethodA(jclass clazz, jmethodID methodID,     \
                                       const jvalue *args)                   \
    {                                                                        \
        return functions->CallStatic##_jname##MethodA(this, clazz, methodID, \
                                                      args);                 \
    }

#define CALL_STATIC_TYPE(_jtype, _jname)     \
    CALL_STATIC_TYPE_METHOD(_jtype, _jname)  \
    CALL_STATIC_TYPE_METHODV(_jtype, _jname) \
    CALL_STATIC_TYPE_METHODA(_jtype, _jname)

    CALL_STATIC_TYPE(jobject, Object)
    CALL_STATIC_TYPE(jboolean, Boolean)
    CALL_STATIC_TYPE(jbyte, Byte)
    CALL_STATIC_TYPE(jchar, Char)
    CALL_STATIC_TYPE(jshort, Short)
    CALL_STATIC_TYPE(jint, Int)
    CALL_STATIC_TYPE(jlong, Long)
    CALL_STATIC_TYPE(jfloat, Float)
    CALL_STATIC_TYPE(jdouble, Double)

    void CallStaticVoidMethod(jclass clazz, jmethodID methodID, ...)
    {
        va_list args;
        va_start(args, methodID);
        functions->CallStaticVoidMethodV(this, clazz, methodID, args);
        va_end(args);
    }
    void CallStaticVoidMethodV(jclass clazz, jmethodID methodID, va_list args)
    {
        functions->CallStaticVoidMethodV(this, clazz, methodID, args);
    }
    void CallStaticVoidMethodA(jclass clazz, jmethodID methodID, const jvalue *args)
    {
        functions->CallStaticVoidMethodA(this, clazz, methodID, args);
    }

    jfieldID GetStaticFieldID(jclass clazz, const char *name, const char *sig)
    {
        return functions->GetStaticFieldID(this, clazz, name, sig);
    }

    jobject GetStaticObjectField(jclass clazz, jfieldID fieldID)
    {
        return functions->GetStaticObjectField(this, clazz, fieldID);
    }
    jboolean GetStaticBooleanField(jclass clazz, jfieldID fieldID)
    {
        return functions->GetStaticBooleanField(this, clazz, fieldID);
    }
    jbyte GetStaticByteField(jclass clazz, jfieldID fieldID)
    {
        return functions->GetStaticByteField(this, clazz, fieldID);
    }
    jchar GetStaticCharField(jclass clazz, jfieldID fieldID)
    {
        return functions->GetStaticCharField(this, clazz, fieldID);
    }
    jshort GetStaticShortField(jclass clazz, jfieldID fieldID)
    {
        return functions->GetStaticShortField(this, clazz, fieldID);
    }
    jint GetStaticIntField(jclass clazz, jfieldID fieldID)
    {
        return functions->GetStaticIntField(this, clazz, fieldID);
    }
    jlong GetStaticLongField(jclass clazz, jfieldID fieldID)
    {
        return functions->GetStaticLongField(this, clazz, fieldID);
    }
    jfloat GetStaticFloatField(jclass clazz, jfieldID fieldID)
    {
        return functions->GetStaticFloatField(this, clazz, fieldID);
    }
    jdouble GetStaticDoubleField(jclass clazz, jfieldID fieldID)
    {
        return functions->GetStaticDoubleField(this, clazz, fieldID);
    }

    void SetStaticObjectField(jclass clazz, jfieldID fieldID, jobject val)
    {
        functions->SetStaticObjectField(this, clazz, fieldID, val);
    }
    void SetStaticBooleanField(jclass clazz, jfieldID fieldID, jboolean val)
    {
        functions->SetStaticBooleanField(this, clazz, fieldID, val);
    }
    void SetStaticByteField(jclass clazz, jfieldID fieldID, jbyte val)
    {
        functions->SetStaticByteField(this, clazz, fieldID, val);
    }
    void SetStaticCharField(jclass clazz, jfieldID fieldID, jchar val)
    {
        functions->SetStaticCharField(this, clazz, fieldID, val);
    }
    void SetStaticShortField(jclass clazz, jfieldID fieldID, jshort val)
    {
        functions->SetStaticShortField(this, clazz, fieldID, val);
    }
    void SetStaticIntField(jclass clazz, jfieldID fieldID, jint val)
    {
        functions->SetStaticIntField(this, clazz, fieldID, val);
    }
    void SetStaticLongField(jclass clazz, jfieldID fieldID, jlong val)
    {
        functions->SetStaticLongField(this, clazz, fieldID, val);
    }
    void SetStaticFloatField(jclass clazz, jfieldID fieldID, jfloat val)
    {
        functions->SetStaticFloatField(this, clazz, fieldID, val);
    }
    void SetStaticDoubleField(jclass clazz, jfieldID fieldID, jdouble val)
    {
        functions->SetStaticDoubleField(this, clazz, fieldID, val);
    }

    jstring NewString(const jchar *unicodeChars, jsize len)
    {
        return functions->NewString(this, unicodeChars, len);
    }

    jsize GetStringLength(jstring string)
    {
        return functions->GetStringLength(this, string);
    }

    const jchar *GetStringChars(jstring string, jboolean *isCopy)
    {
        return functions->GetStringChars(this, string, isCopy);
    }

    void ReleaseStringChars(jstring string, const jchar *chars)
    {
        functions->ReleaseStringChars(this, string, chars);
    }

    jstring NewStringUTF(const char *bytes)
    {
        return functions->NewStringUTF(this, bytes);
    }

    jsize GetStringUTFLength(jstring string)
    {
        return functions->GetStringUTFLength(this, string);
    }

    const char *GetStringUTFChars(jstring string, jboolean *isCopy)
    {
        return functions->GetStringUTFChars(this, string, isCopy);
    }

    void ReleaseStringUTFChars(jstring string, const char *utf)
    {
        functions->ReleaseStringUTFChars(this, string, utf);
    }

    jsize GetArrayLength(jarray array)
    {
        return functions->GetArrayLength(this, array);
    }

    jobjectArray NewObjectArray(jsize length, jclass elementClass,
                                jobject initialElement)
    {
        return functions->NewObjectArray(this, length, elementClass,
                                         initialElement);
    }

    jobject GetObjectArrayElement(jobjectArray array, jsize index)
    {
        return functions->GetObjectArrayElement(this, array, index);
    }

    void SetObjectArrayElement(jobjectArray array, jsize index, jobject val)
    {
        functions->SetObjectArrayElement(this, array, index, val);
    }

    jbooleanArray NewBooleanArray(jsize length)
    {
        return functions->NewBooleanArray(this, length);
    }
    jbyteArray NewByteArray(jsize length)
    {
        return functions->NewByteArray(this, length);
    }
    jcharArray NewCharArray(jsize length)
    {
        return functions->NewCharArray(this, length);
    }
    jshortArray NewShortArray(jsize length)
    {
        return functions->NewShortArray(this, length);
    }
    jintArray NewIntArray(jsize length)
    {
        return functions->NewIntArray(this, length);
    }
    jlongArray NewLongArray(jsize length)
    {
        return functions->NewLongArray(this, length);
    }
    jfloatArray NewFloatArray(jsize length)
    {
        return functions->NewFloatArray(this, length);
    }
    jdoubleArray NewDoubleArray(jsize length)
    {
        return functions->NewDoubleArray(this, length);
    }

    jboolean *GetBooleanArrayElements(jbooleanArray array, jboolean *isCopy)
    {
        return functions->GetBooleanArrayElements(this, array, isCopy);
    }
    jbyte *GetByteArrayElements(jbyteArray array, jboolean *isCopy)
    {
        return functions->GetByteArrayElements(this, array, isCopy);
    }
    jchar *GetCharArrayElements(jcharArray array, jboolean *isCopy)
    {
        return functions->GetCharArrayElements(this, array, isCopy);
    }
    jshort *GetShortArrayElements(jshortArray array, jboolean *isCopy)
    {
        return functions->GetShortArrayElements(this, array, isCopy);
    }
    jint *GetIntArrayElements(jintArray array, jboolean *isCopy)
    {
        return functions->GetIntArrayElements(this, array, isCopy);
    }
    jlong *GetLongArrayElements(jlongArray array, jboolean *isCopy)
    {
        return functions->GetLongArrayElements(this, array, isCopy);
    }
    jfloat *GetFloatArrayElements(jfloatArray array, jboolean *isCopy)
    {
        return functions->GetFloatArrayElements(this, array, isCopy);
    }
    jdouble *GetDoubleArrayElements(jdoubleArray array, jboolean *isCopy)
    {
        return functions->GetDoubleArrayElements(this, array, isCopy);
    }

    void ReleaseBooleanArrayElements(jbooleanArray array, jboolean *elems,
                                     jint mode)
    {
        functions->ReleaseBooleanArrayElements(this, array, elems, mode);
    }
    void ReleaseByteArrayElements(jbyteArray array, jbyte *elems,
                                  jint mode)
    {
        functions->ReleaseByteArrayElements(this, array, elems, mode);
    }
    void ReleaseCharArrayElements(jcharArray array, jchar *elems,
                                  jint mode)
    {
        functions->ReleaseCharArrayElements(this, array, elems, mode);
    }
    void ReleaseShortArrayElements(jshortArray array, jshort *elems,
                                   jint mode)
    {
        functions->ReleaseShortArrayElements(this, array, elems, mode);
    }
    void ReleaseIntArrayElements(jintArray array, jint *elems,
                                 jint mode)
    {
        functions->ReleaseIntArrayElements(this, array, elems, mode);
    }
    void ReleaseLongArrayElements(jlongArray array, jlong *elems,
                                  jint mode)
    {
        functions->ReleaseLongArrayElements(this, array, elems, mode);
    }
    void ReleaseFloatArrayElements(jfloatArray array, jfloat *elems,
                                   jint mode)
    {
        functions->ReleaseFloatArrayElements(this, array, elems, mode);
    }
    void ReleaseDoubleArrayElements(jdoubleArray array, jdouble *elems,
                                    jint mode)
    {
        functions->ReleaseDoubleArrayElements(this, array, elems, mode);
    }

    void GetBooleanArrayRegion(jbooleanArray array, jsize start, jsize len,
                               jboolean *buf)
    {
        functions->GetBooleanArrayRegion(this, array, start, len, buf);
    }
    void GetByteArrayRegion(jbyteArray array, jsize start, jsize len,
                            jbyte *buf)
    {
        functions->GetByteArrayRegion(this, array, start, len, buf);
    }
    void GetCharArrayRegion(jcharArray array, jsize start, jsize len,
                            jchar *buf)
    {
        functions->GetCharArrayRegion(this, array, start, len, buf);
    }
    void GetShortArrayRegion(jshortArray array, jsize start, jsize len,
                             jshort *buf)
    {
        functions->GetShortArrayRegion(this, array, start, len, buf);
    }
    void GetIntArrayRegion(jintArray array, jsize start, jsize len,
                           jint *buf)
    {
        functions->GetIntArrayRegion(this, array, start, len, buf);
    }
    void GetLongArrayRegion(jlongArray array, jsize start, jsize len,
                            jlong *buf)
    {
        functions->GetLongArrayRegion(this, array, start, len, buf);
    }
    void GetFloatArrayRegion(jfloatArray array, jsize start, jsize len,
                             jfloat *buf)
    {
        functions->GetFloatArrayRegion(this, array, start, len, buf);
    }
    void GetDoubleArrayRegion(jdoubleArray array, jsize start, jsize len,
                              jdouble *buf)
    {
        functions->GetDoubleArrayRegion(this, array, start, len, buf);
    }

    void SetBooleanArrayRegion(jbooleanArray array, jsize start, jsize len,
                               const jboolean *buf)
    {
        functions->SetBooleanArrayRegion(this, array, start, len, buf);
    }
    void SetByteArrayRegion(jbyteArray array, jsize start, jsize len,
                            const jbyte *buf)
    {
        functions->SetByteArrayRegion(this, array, start, len, buf);
    }
    void SetCharArrayRegion(jcharArray array, jsize start, jsize len,
                            const jchar *buf)
    {
        functions->SetCharArrayRegion(this, array, start, len, buf);
    }
    void SetShortArrayRegion(jshortArray array, jsize start, jsize len,
                             const jshort *buf)
    {
        functions->SetShortArrayRegion(this, array, start, len, buf);
    }
    void SetIntArrayRegion(jintArray array, jsize start, jsize len,
                           const jint *buf)
    {
        functions->SetIntArrayRegion(this, array, start, len, buf);
    }
    void SetLongArrayRegion(jlongArray array, jsize start, jsize len,
                            const jlong *buf)
    {
        functions->SetLongArrayRegion(this, array, start, len, buf);
    }
    void SetFloatArrayRegion(jfloatArray array, jsize start, jsize len,
                             const jfloat *buf)
    {
        functions->SetFloatArrayRegion(this, array, start, len, buf);
    }
    void SetDoubleArrayRegion(jdoubleArray array, jsize start, jsize len,
                              const jdouble *buf)
    {
        functions->SetDoubleArrayRegion(this, array, start, len, buf);
    }

    jint RegisterNatives(jclass clazz, const JNINativeMethod *methods,
                         jint nMethods)
    {
        return functions->RegisterNatives(this, clazz, methods, nMethods);
    }

    jint UnregisterNatives(jclass clazz)
    {
        return functions->UnregisterNatives(this, clazz);
    }

    jint MonitorEnter(jobject obj)
    {
        return functions->MonitorEnter(this, obj);
    }

    jint MonitorExit(jobject obj)
    {
        return functions->MonitorExit(this, obj);
    }

    jint GetJavaVM(JavaVM **vm)
    {
        return functions->GetJavaVM(this, vm);
    }

    void GetStringRegion(jstring str, jsize start, jsize len, jchar *buf)
    {
        functions->GetStringRegion(this, str, start, len, buf);
    }

    void GetStringUTFRegion(jstring str, jsize start, jsize len, char *buf)
    {
        return functions->GetStringUTFRegion(this, str, start, len, buf);
    }

    void *GetPrimitiveArrayCritical(jarray array, jboolean *isCopy)
    {
        return functions->GetPrimitiveArrayCritical(this, array, isCopy);
    }

    void ReleasePrimitiveArrayCritical(jarray array, void *carray, jint mode)
    {
        functions->ReleasePrimitiveArrayCritical(this, array, carray, mode);
    }

    const jchar *GetStringCritical(jstring string, jboolean *isCopy)
    {
        return functions->GetStringCritical(this, string, isCopy);
    }

    void ReleaseStringCritical(jstring string, const jchar *carray)
    {
        functions->ReleaseStringCritical(this, string, carray);
    }

    jweak NewWeakGlobalRef(jobject obj)
    {
        return functions->NewWeakGlobalRef(this, obj);
    }

    void DeleteWeakGlobalRef(jweak obj)
    {
        functions->DeleteWeakGlobalRef(this, obj);
    }

    jboolean ExceptionCheck()
    {
        return functions->ExceptionCheck(this);
    }

    jobject NewDirectByteBuffer(void *address, jlong capacity)
    {
        return functions->NewDirectByteBuffer(this, address, capacity);
    }

    void *GetDirectBufferAddress(jobject buf)
    {
        return functions->GetDirectBufferAddress(this, buf);
    }

    jlong GetDirectBufferCapacity(jobject buf)
    {
        return functions->GetDirectBufferCapacity(this, buf);
    }

    /* added in JNI 1.6 */
    jobjectRefType GetObjectRefType(jobject obj)
    {
        return functions->GetObjectRefType(this, obj);
    }
#endif /*__cplusplus*/
};

/*
 * JNI invocation interface.
 */
struct JNIInvokeInterface
{
    void *reserved0;
    void *reserved1;
    void *reserved2;

    jint (*DestroyJavaVM)(JavaVM *vm);
    jint (*AttachCurrentThread)(JavaVM *vm, JNIEnv **p_env, void *thr_args);
    jint (*DetachCurrentThread)(JavaVM *vm);
    jint (*GetEnv)(JavaVM *vm, void **p_env, jint version);
    jint (*AttachCurrentThreadAsDaemon)(JavaVM *vm, JNIEnv **p_env, void *thr_args);
};

/*
 * C++ version.
 */
struct _JavaVM
{
    const struct JNIInvokeInterface *functions;

#if defined(__cplusplus)
    jint DestroyJavaVM()
    {
        return functions->DestroyJavaVM(this);
    }
    jint AttachCurrentThread(JNIEnv **p_env, void *thr_args)
    {
        return functions->AttachCurrentThread(this, p_env, thr_args);
    }
    jint DetachCurrentThread()
    {
        return functions->DetachCurrentThread(this);
    }
    jint GetEnv(void **env, jint version)
    {
        return functions->GetEnv(this, env, version);
    }
    jint AttachCurrentThreadAsDaemon(JNIEnv **p_env, void *thr_args)
    {
        return functions->AttachCurrentThreadAsDaemon(this, p_env, thr_args);
    }
#endif /*__cplusplus*/
};

struct JavaVMAttachArgs
{
    jint version;     /* must be >= JNI_VERSION_1_2 */
    const char *name; /* NULL or name of thread as modified UTF-8 str */
    jobject group;    /* global ref of a ThreadGroup object, or NULL */
};
typedef struct JavaVMAttachArgs JavaVMAttachArgs;

/*
 * JNI 1.2+ initialization.  (As of 1.6, the pre-1.2 structures are no
 * longer supported.)
 */
typedef struct JavaVMOption
{
    const char *optionString;
    void *extraInfo;
} JavaVMOption;

typedef struct JavaVMInitArgs
{
    jint version; /* use JNI_VERSION_1_2 or later */

    jint nOptions;
    JavaVMOption *options;
    jboolean ignoreUnrecognized;
} JavaVMInitArgs;

#ifdef __cplusplus
extern "C"
{
#endif
    /*
     * VM initialization functions.
     *
     * Note these are the only symbols exported for JNI by the VM.
     */

    jint JNI_GetDefaultJavaVMInitArgs(void *);
    jint JNI_CreateJavaVM(JavaVM **, JNIEnv **, void *);
    jint JNI_GetCreatedJavaVMs(JavaVM **, jsize, jsize *);

#define JNIIMPORT
#define JNIEXPORT __attribute__((visibility("default")))
#define JNICALL

    /*
     * Prototypes for functions exported by loadable shared libs.  These are
     * called by JNI, not provided by JNI.
     */
    JNIEXPORT jint JNI_OnLoad(JavaVM *vm, void *reserved);
    JNIEXPORT void JNI_OnUnload(JavaVM *vm, void *reserved);

#ifdef __cplusplus
}
#endif

/*
 * Manifest constants.
 */
#define JNI_FALSE 0
#define JNI_TRUE 1

#define JNI_VERSION_1_1 0x00010001
#define JNI_VERSION_1_2 0x00010002
#define JNI_VERSION_1_4 0x00010004
#define JNI_VERSION_1_6 0x00010006

#define JNI_OK (0)         /* no error */
#define JNI_ERR (-1)       /* generic error */
#define JNI_EDETACHED (-2) /* thread detached from the VM */
#define JNI_EVERSION (-3)  /* JNI version error */
#define JNI_ENOMEM (-4)    /* Out of memory */
#define JNI_EEXIST (-5)    /* VM already created */
#define JNI_EINVAL (-6)    /* Invalid argument */

#define JNI_COMMIT 1 /* copy content, do not free buffer */
#define JNI_ABORT 2  /* free buffer w/o copying back */
