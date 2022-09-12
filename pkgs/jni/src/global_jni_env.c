// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "global_jni_env.h"
jint globalEnv_GetVersion() {
    attach_thread();
    return (*jniEnv)->GetVersion(jniEnv);
}

jclass globalEnv_DefineClass(const char * name, jobject loader, const jbyte * buf, jsize bufLen) {
    attach_thread();
    return to_global_ref((*jniEnv)->DefineClass(jniEnv, name, loader, buf, bufLen));
}

jclass globalEnv_FindClass(const char * name) {
    attach_thread();
    return to_global_ref((*jniEnv)->FindClass(jniEnv, name));
}

jmethodID globalEnv_FromReflectedMethod(jobject method) {
    attach_thread();
    return (*jniEnv)->FromReflectedMethod(jniEnv, method);
}

jfieldID globalEnv_FromReflectedField(jobject field) {
    attach_thread();
    return (*jniEnv)->FromReflectedField(jniEnv, field);
}

jobject globalEnv_ToReflectedMethod(jclass cls, jmethodID methodId, jboolean isStatic) {
    attach_thread();
    return to_global_ref((*jniEnv)->ToReflectedMethod(jniEnv, cls, methodId, isStatic));
}

jclass globalEnv_GetSuperclass(jclass clazz) {
    attach_thread();
    return to_global_ref((*jniEnv)->GetSuperclass(jniEnv, clazz));
}

jboolean globalEnv_IsAssignableFrom(jclass clazz1, jclass clazz2) {
    attach_thread();
    return (*jniEnv)->IsAssignableFrom(jniEnv, clazz1, clazz2);
}

jobject globalEnv_ToReflectedField(jclass cls, jfieldID fieldID, jboolean isStatic) {
    attach_thread();
    return to_global_ref((*jniEnv)->ToReflectedField(jniEnv, cls, fieldID, isStatic));
}

jint globalEnv_Throw(jthrowable obj) {
    attach_thread();
    return (*jniEnv)->Throw(jniEnv, obj);
}

jint globalEnv_ThrowNew(jclass clazz, const char * message) {
    attach_thread();
    return (*jniEnv)->ThrowNew(jniEnv, clazz, message);
}

jthrowable globalEnv_ExceptionOccurred() {
    attach_thread();
    return to_global_ref((*jniEnv)->ExceptionOccurred(jniEnv));
}

void globalEnv_ExceptionDescribe() {
    attach_thread();
    (*jniEnv)->ExceptionDescribe(jniEnv);
}

void globalEnv_ExceptionClear() {
    attach_thread();
    (*jniEnv)->ExceptionClear(jniEnv);
}

void globalEnv_FatalError(const char * msg) {
    attach_thread();
    (*jniEnv)->FatalError(jniEnv, msg);
}

jint globalEnv_PushLocalFrame(jint capacity) {
    attach_thread();
    return (*jniEnv)->PushLocalFrame(jniEnv, capacity);
}

jobject globalEnv_PopLocalFrame(jobject result) {
    attach_thread();
    return to_global_ref((*jniEnv)->PopLocalFrame(jniEnv, result));
}

jobject globalEnv_NewGlobalRef(jobject obj) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewGlobalRef(jniEnv, obj));
}

void globalEnv_DeleteGlobalRef(jobject globalRef) {
    attach_thread();
    (*jniEnv)->DeleteGlobalRef(jniEnv, globalRef);
}

jboolean globalEnv_IsSameObject(jobject ref1, jobject ref2) {
    attach_thread();
    return (*jniEnv)->IsSameObject(jniEnv, ref1, ref2);
}

jint globalEnv_EnsureLocalCapacity(jint capacity) {
    attach_thread();
    return (*jniEnv)->EnsureLocalCapacity(jniEnv, capacity);
}

jobject globalEnv_AllocObject(jclass clazz) {
    attach_thread();
    return to_global_ref((*jniEnv)->AllocObject(jniEnv, clazz));
}

jobject globalEnv_NewObject(jclass arg1, jmethodID arg2) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewObject(jniEnv, arg1, arg2));
}

jobject globalEnv_NewObjectA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewObjectA(jniEnv, clazz, methodID, args));
}

jclass globalEnv_GetObjectClass(jobject obj) {
    attach_thread();
    return to_global_ref((*jniEnv)->GetObjectClass(jniEnv, obj));
}

jboolean globalEnv_IsInstanceOf(jobject obj, jclass clazz) {
    attach_thread();
    return (*jniEnv)->IsInstanceOf(jniEnv, obj, clazz);
}

jmethodID globalEnv_GetMethodID(jclass clazz, const char * name, const char * sig) {
    attach_thread();
    return (*jniEnv)->GetMethodID(jniEnv, clazz, name, sig);
}

jobject globalEnv_CallObjectMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    return to_global_ref((*jniEnv)->CallObjectMethod(jniEnv, arg1, arg2));
}

jobject globalEnv_CallObjectMethodA(jobject obj, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return to_global_ref((*jniEnv)->CallObjectMethodA(jniEnv, obj, methodID, args));
}

jboolean globalEnv_CallBooleanMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallBooleanMethod(jniEnv, arg1, arg2);
}

jboolean globalEnv_CallBooleanMethodA(jobject obj, jmethodID methodId, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallBooleanMethodA(jniEnv, obj, methodId, args);
}

jbyte globalEnv_CallByteMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallByteMethod(jniEnv, arg1, arg2);
}

jbyte globalEnv_CallByteMethodA(jobject obj, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallByteMethodA(jniEnv, obj, methodID, args);
}

jchar globalEnv_CallCharMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallCharMethod(jniEnv, arg1, arg2);
}

jchar globalEnv_CallCharMethodA(jobject obj, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallCharMethodA(jniEnv, obj, methodID, args);
}

jshort globalEnv_CallShortMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallShortMethod(jniEnv, arg1, arg2);
}

jshort globalEnv_CallShortMethodA(jobject obj, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallShortMethodA(jniEnv, obj, methodID, args);
}

jint globalEnv_CallIntMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallIntMethod(jniEnv, arg1, arg2);
}

jint globalEnv_CallIntMethodA(jobject obj, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallIntMethodA(jniEnv, obj, methodID, args);
}

jlong globalEnv_CallLongMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallLongMethod(jniEnv, arg1, arg2);
}

jlong globalEnv_CallLongMethodA(jobject obj, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallLongMethodA(jniEnv, obj, methodID, args);
}

jfloat globalEnv_CallFloatMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallFloatMethod(jniEnv, arg1, arg2);
}

jfloat globalEnv_CallFloatMethodA(jobject obj, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallFloatMethodA(jniEnv, obj, methodID, args);
}

jdouble globalEnv_CallDoubleMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallDoubleMethod(jniEnv, arg1, arg2);
}

jdouble globalEnv_CallDoubleMethodA(jobject obj, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallDoubleMethodA(jniEnv, obj, methodID, args);
}

void globalEnv_CallVoidMethod(jobject arg1, jmethodID arg2) {
    attach_thread();
    (*jniEnv)->CallVoidMethod(jniEnv, arg1, arg2);
}

void globalEnv_CallVoidMethodA(jobject obj, jmethodID methodID, const jvalue * args) {
    attach_thread();
    (*jniEnv)->CallVoidMethodA(jniEnv, obj, methodID, args);
}

jobject globalEnv_CallNonvirtualObjectMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    return to_global_ref((*jniEnv)->CallNonvirtualObjectMethod(jniEnv, arg1, arg2, arg3));
}

jobject globalEnv_CallNonvirtualObjectMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return to_global_ref((*jniEnv)->CallNonvirtualObjectMethodA(jniEnv, obj, clazz, methodID, args));
}

jboolean globalEnv_CallNonvirtualBooleanMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualBooleanMethod(jniEnv, arg1, arg2, arg3);
}

jboolean globalEnv_CallNonvirtualBooleanMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualBooleanMethodA(jniEnv, obj, clazz, methodID, args);
}

jbyte globalEnv_CallNonvirtualByteMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualByteMethod(jniEnv, arg1, arg2, arg3);
}

jbyte globalEnv_CallNonvirtualByteMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualByteMethodA(jniEnv, obj, clazz, methodID, args);
}

jchar globalEnv_CallNonvirtualCharMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualCharMethod(jniEnv, arg1, arg2, arg3);
}

jchar globalEnv_CallNonvirtualCharMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualCharMethodA(jniEnv, obj, clazz, methodID, args);
}

jshort globalEnv_CallNonvirtualShortMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualShortMethod(jniEnv, arg1, arg2, arg3);
}

jshort globalEnv_CallNonvirtualShortMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualShortMethodA(jniEnv, obj, clazz, methodID, args);
}

jint globalEnv_CallNonvirtualIntMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualIntMethod(jniEnv, arg1, arg2, arg3);
}

jint globalEnv_CallNonvirtualIntMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualIntMethodA(jniEnv, obj, clazz, methodID, args);
}

jlong globalEnv_CallNonvirtualLongMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualLongMethod(jniEnv, arg1, arg2, arg3);
}

jlong globalEnv_CallNonvirtualLongMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualLongMethodA(jniEnv, obj, clazz, methodID, args);
}

jfloat globalEnv_CallNonvirtualFloatMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualFloatMethod(jniEnv, arg1, arg2, arg3);
}

jfloat globalEnv_CallNonvirtualFloatMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualFloatMethodA(jniEnv, obj, clazz, methodID, args);
}

jdouble globalEnv_CallNonvirtualDoubleMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualDoubleMethod(jniEnv, arg1, arg2, arg3);
}

jdouble globalEnv_CallNonvirtualDoubleMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallNonvirtualDoubleMethodA(jniEnv, obj, clazz, methodID, args);
}

void globalEnv_CallNonvirtualVoidMethod(jobject arg1, jclass arg2, jmethodID arg3) {
    attach_thread();
    (*jniEnv)->CallNonvirtualVoidMethod(jniEnv, arg1, arg2, arg3);
}

void globalEnv_CallNonvirtualVoidMethodA(jobject obj, jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    (*jniEnv)->CallNonvirtualVoidMethodA(jniEnv, obj, clazz, methodID, args);
}

jfieldID globalEnv_GetFieldID(jclass clazz, const char * name, const char * sig) {
    attach_thread();
    return (*jniEnv)->GetFieldID(jniEnv, clazz, name, sig);
}

jobject globalEnv_GetObjectField(jobject obj, jfieldID fieldID) {
    attach_thread();
    return to_global_ref((*jniEnv)->GetObjectField(jniEnv, obj, fieldID));
}

jboolean globalEnv_GetBooleanField(jobject obj, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetBooleanField(jniEnv, obj, fieldID);
}

jbyte globalEnv_GetByteField(jobject obj, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetByteField(jniEnv, obj, fieldID);
}

jchar globalEnv_GetCharField(jobject obj, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetCharField(jniEnv, obj, fieldID);
}

jshort globalEnv_GetShortField(jobject obj, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetShortField(jniEnv, obj, fieldID);
}

jint globalEnv_GetIntField(jobject obj, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetIntField(jniEnv, obj, fieldID);
}

jlong globalEnv_GetLongField(jobject obj, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetLongField(jniEnv, obj, fieldID);
}

jfloat globalEnv_GetFloatField(jobject obj, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetFloatField(jniEnv, obj, fieldID);
}

jdouble globalEnv_GetDoubleField(jobject obj, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetDoubleField(jniEnv, obj, fieldID);
}

void globalEnv_SetObjectField(jobject obj, jfieldID fieldID, jobject val) {
    attach_thread();
    (*jniEnv)->SetObjectField(jniEnv, obj, fieldID, val);
}

void globalEnv_SetBooleanField(jobject obj, jfieldID fieldID, jboolean val) {
    attach_thread();
    (*jniEnv)->SetBooleanField(jniEnv, obj, fieldID, val);
}

void globalEnv_SetByteField(jobject obj, jfieldID fieldID, jbyte val) {
    attach_thread();
    (*jniEnv)->SetByteField(jniEnv, obj, fieldID, val);
}

void globalEnv_SetCharField(jobject obj, jfieldID fieldID, jchar val) {
    attach_thread();
    (*jniEnv)->SetCharField(jniEnv, obj, fieldID, val);
}

void globalEnv_SetShortField(jobject obj, jfieldID fieldID, jshort val) {
    attach_thread();
    (*jniEnv)->SetShortField(jniEnv, obj, fieldID, val);
}

void globalEnv_SetIntField(jobject obj, jfieldID fieldID, jint val) {
    attach_thread();
    (*jniEnv)->SetIntField(jniEnv, obj, fieldID, val);
}

void globalEnv_SetLongField(jobject obj, jfieldID fieldID, jlong val) {
    attach_thread();
    (*jniEnv)->SetLongField(jniEnv, obj, fieldID, val);
}

void globalEnv_SetFloatField(jobject obj, jfieldID fieldID, jfloat val) {
    attach_thread();
    (*jniEnv)->SetFloatField(jniEnv, obj, fieldID, val);
}

void globalEnv_SetDoubleField(jobject obj, jfieldID fieldID, jdouble val) {
    attach_thread();
    (*jniEnv)->SetDoubleField(jniEnv, obj, fieldID, val);
}

jmethodID globalEnv_GetStaticMethodID(jclass clazz, const char * name, const char * sig) {
    attach_thread();
    return (*jniEnv)->GetStaticMethodID(jniEnv, clazz, name, sig);
}

jobject globalEnv_CallStaticObjectMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    return to_global_ref((*jniEnv)->CallStaticObjectMethod(jniEnv, arg1, arg2));
}

jobject globalEnv_CallStaticObjectMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return to_global_ref((*jniEnv)->CallStaticObjectMethodA(jniEnv, clazz, methodID, args));
}

jboolean globalEnv_CallStaticBooleanMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallStaticBooleanMethod(jniEnv, arg1, arg2);
}

jboolean globalEnv_CallStaticBooleanMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallStaticBooleanMethodA(jniEnv, clazz, methodID, args);
}

jbyte globalEnv_CallStaticByteMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallStaticByteMethod(jniEnv, arg1, arg2);
}

jbyte globalEnv_CallStaticByteMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallStaticByteMethodA(jniEnv, clazz, methodID, args);
}

jchar globalEnv_CallStaticCharMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallStaticCharMethod(jniEnv, arg1, arg2);
}

jchar globalEnv_CallStaticCharMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallStaticCharMethodA(jniEnv, clazz, methodID, args);
}

jshort globalEnv_CallStaticShortMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallStaticShortMethod(jniEnv, arg1, arg2);
}

jshort globalEnv_CallStaticShortMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallStaticShortMethodA(jniEnv, clazz, methodID, args);
}

jint globalEnv_CallStaticIntMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallStaticIntMethod(jniEnv, arg1, arg2);
}

jint globalEnv_CallStaticIntMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallStaticIntMethodA(jniEnv, clazz, methodID, args);
}

jlong globalEnv_CallStaticLongMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallStaticLongMethod(jniEnv, arg1, arg2);
}

jlong globalEnv_CallStaticLongMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallStaticLongMethodA(jniEnv, clazz, methodID, args);
}

jfloat globalEnv_CallStaticFloatMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallStaticFloatMethod(jniEnv, arg1, arg2);
}

jfloat globalEnv_CallStaticFloatMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallStaticFloatMethodA(jniEnv, clazz, methodID, args);
}

jdouble globalEnv_CallStaticDoubleMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    return (*jniEnv)->CallStaticDoubleMethod(jniEnv, arg1, arg2);
}

jdouble globalEnv_CallStaticDoubleMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    return (*jniEnv)->CallStaticDoubleMethodA(jniEnv, clazz, methodID, args);
}

void globalEnv_CallStaticVoidMethod(jclass arg1, jmethodID arg2) {
    attach_thread();
    (*jniEnv)->CallStaticVoidMethod(jniEnv, arg1, arg2);
}

void globalEnv_CallStaticVoidMethodA(jclass clazz, jmethodID methodID, const jvalue * args) {
    attach_thread();
    (*jniEnv)->CallStaticVoidMethodA(jniEnv, clazz, methodID, args);
}

jfieldID globalEnv_GetStaticFieldID(jclass clazz, const char * name, const char * sig) {
    attach_thread();
    return (*jniEnv)->GetStaticFieldID(jniEnv, clazz, name, sig);
}

jobject globalEnv_GetStaticObjectField(jclass clazz, jfieldID fieldID) {
    attach_thread();
    return to_global_ref((*jniEnv)->GetStaticObjectField(jniEnv, clazz, fieldID));
}

jboolean globalEnv_GetStaticBooleanField(jclass clazz, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetStaticBooleanField(jniEnv, clazz, fieldID);
}

jbyte globalEnv_GetStaticByteField(jclass clazz, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetStaticByteField(jniEnv, clazz, fieldID);
}

jchar globalEnv_GetStaticCharField(jclass clazz, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetStaticCharField(jniEnv, clazz, fieldID);
}

jshort globalEnv_GetStaticShortField(jclass clazz, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetStaticShortField(jniEnv, clazz, fieldID);
}

jint globalEnv_GetStaticIntField(jclass clazz, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetStaticIntField(jniEnv, clazz, fieldID);
}

jlong globalEnv_GetStaticLongField(jclass clazz, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetStaticLongField(jniEnv, clazz, fieldID);
}

jfloat globalEnv_GetStaticFloatField(jclass clazz, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetStaticFloatField(jniEnv, clazz, fieldID);
}

jdouble globalEnv_GetStaticDoubleField(jclass clazz, jfieldID fieldID) {
    attach_thread();
    return (*jniEnv)->GetStaticDoubleField(jniEnv, clazz, fieldID);
}

void globalEnv_SetStaticObjectField(jclass clazz, jfieldID fieldID, jobject val) {
    attach_thread();
    (*jniEnv)->SetStaticObjectField(jniEnv, clazz, fieldID, val);
}

void globalEnv_SetStaticBooleanField(jclass clazz, jfieldID fieldID, jboolean val) {
    attach_thread();
    (*jniEnv)->SetStaticBooleanField(jniEnv, clazz, fieldID, val);
}

void globalEnv_SetStaticByteField(jclass clazz, jfieldID fieldID, jbyte val) {
    attach_thread();
    (*jniEnv)->SetStaticByteField(jniEnv, clazz, fieldID, val);
}

void globalEnv_SetStaticCharField(jclass clazz, jfieldID fieldID, jchar val) {
    attach_thread();
    (*jniEnv)->SetStaticCharField(jniEnv, clazz, fieldID, val);
}

void globalEnv_SetStaticShortField(jclass clazz, jfieldID fieldID, jshort val) {
    attach_thread();
    (*jniEnv)->SetStaticShortField(jniEnv, clazz, fieldID, val);
}

void globalEnv_SetStaticIntField(jclass clazz, jfieldID fieldID, jint val) {
    attach_thread();
    (*jniEnv)->SetStaticIntField(jniEnv, clazz, fieldID, val);
}

void globalEnv_SetStaticLongField(jclass clazz, jfieldID fieldID, jlong val) {
    attach_thread();
    (*jniEnv)->SetStaticLongField(jniEnv, clazz, fieldID, val);
}

void globalEnv_SetStaticFloatField(jclass clazz, jfieldID fieldID, jfloat val) {
    attach_thread();
    (*jniEnv)->SetStaticFloatField(jniEnv, clazz, fieldID, val);
}

void globalEnv_SetStaticDoubleField(jclass clazz, jfieldID fieldID, jdouble val) {
    attach_thread();
    (*jniEnv)->SetStaticDoubleField(jniEnv, clazz, fieldID, val);
}

jstring globalEnv_NewString(const jchar * unicodeChars, jsize len) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewString(jniEnv, unicodeChars, len));
}

jsize globalEnv_GetStringLength(jstring string) {
    attach_thread();
    return (*jniEnv)->GetStringLength(jniEnv, string);
}

const jchar * globalEnv_GetStringChars(jstring string, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetStringChars(jniEnv, string, isCopy);
}

void globalEnv_ReleaseStringChars(jstring string, const jchar * isCopy) {
    attach_thread();
    (*jniEnv)->ReleaseStringChars(jniEnv, string, isCopy);
}

jstring globalEnv_NewStringUTF(const char * bytes) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewStringUTF(jniEnv, bytes));
}

jsize globalEnv_GetStringUTFLength(jstring string) {
    attach_thread();
    return (*jniEnv)->GetStringUTFLength(jniEnv, string);
}

const char * globalEnv_GetStringUTFChars(jstring string, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetStringUTFChars(jniEnv, string, isCopy);
}

void globalEnv_ReleaseStringUTFChars(jstring string, const char * utf) {
    attach_thread();
    (*jniEnv)->ReleaseStringUTFChars(jniEnv, string, utf);
}

jsize globalEnv_GetArrayLength(jarray array) {
    attach_thread();
    return (*jniEnv)->GetArrayLength(jniEnv, array);
}

jobjectArray globalEnv_NewObjectArray(jsize length, jclass elementClass, jobject initialElement) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewObjectArray(jniEnv, length, elementClass, initialElement));
}

jobject globalEnv_GetObjectArrayElement(jobjectArray array, jsize index) {
    attach_thread();
    return to_global_ref((*jniEnv)->GetObjectArrayElement(jniEnv, array, index));
}

void globalEnv_SetObjectArrayElement(jobjectArray array, jsize index, jobject val) {
    attach_thread();
    (*jniEnv)->SetObjectArrayElement(jniEnv, array, index, val);
}

jbooleanArray globalEnv_NewBooleanArray(jsize length) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewBooleanArray(jniEnv, length));
}

jbyteArray globalEnv_NewByteArray(jsize length) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewByteArray(jniEnv, length));
}

jcharArray globalEnv_NewCharArray(jsize length) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewCharArray(jniEnv, length));
}

jshortArray globalEnv_NewShortArray(jsize length) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewShortArray(jniEnv, length));
}

jintArray globalEnv_NewIntArray(jsize length) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewIntArray(jniEnv, length));
}

jlongArray globalEnv_NewLongArray(jsize length) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewLongArray(jniEnv, length));
}

jfloatArray globalEnv_NewFloatArray(jsize length) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewFloatArray(jniEnv, length));
}

jdoubleArray globalEnv_NewDoubleArray(jsize length) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewDoubleArray(jniEnv, length));
}

jboolean * globalEnv_GetBooleanArrayElements(jbooleanArray array, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetBooleanArrayElements(jniEnv, array, isCopy);
}

jbyte * globalEnv_GetByteArrayElements(jbyteArray array, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetByteArrayElements(jniEnv, array, isCopy);
}

jchar * globalEnv_GetCharArrayElements(jcharArray array, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetCharArrayElements(jniEnv, array, isCopy);
}

jshort * globalEnv_GetShortArrayElements(jshortArray array, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetShortArrayElements(jniEnv, array, isCopy);
}

jint * globalEnv_GetIntArrayElements(jintArray array, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetIntArrayElements(jniEnv, array, isCopy);
}

jlong * globalEnv_GetLongArrayElements(jlongArray array, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetLongArrayElements(jniEnv, array, isCopy);
}

jfloat * globalEnv_GetFloatArrayElements(jfloatArray array, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetFloatArrayElements(jniEnv, array, isCopy);
}

jdouble * globalEnv_GetDoubleArrayElements(jdoubleArray array, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetDoubleArrayElements(jniEnv, array, isCopy);
}

void globalEnv_ReleaseBooleanArrayElements(jbooleanArray array, jboolean * elems, jint mode) {
    attach_thread();
    (*jniEnv)->ReleaseBooleanArrayElements(jniEnv, array, elems, mode);
}

void globalEnv_ReleaseByteArrayElements(jbyteArray array, jbyte * elems, jint mode) {
    attach_thread();
    (*jniEnv)->ReleaseByteArrayElements(jniEnv, array, elems, mode);
}

void globalEnv_ReleaseCharArrayElements(jcharArray array, jchar * elems, jint mode) {
    attach_thread();
    (*jniEnv)->ReleaseCharArrayElements(jniEnv, array, elems, mode);
}

void globalEnv_ReleaseShortArrayElements(jshortArray array, jshort * elems, jint mode) {
    attach_thread();
    (*jniEnv)->ReleaseShortArrayElements(jniEnv, array, elems, mode);
}

void globalEnv_ReleaseIntArrayElements(jintArray array, jint * elems, jint mode) {
    attach_thread();
    (*jniEnv)->ReleaseIntArrayElements(jniEnv, array, elems, mode);
}

void globalEnv_ReleaseLongArrayElements(jlongArray array, jlong * elems, jint mode) {
    attach_thread();
    (*jniEnv)->ReleaseLongArrayElements(jniEnv, array, elems, mode);
}

void globalEnv_ReleaseFloatArrayElements(jfloatArray array, jfloat * elems, jint mode) {
    attach_thread();
    (*jniEnv)->ReleaseFloatArrayElements(jniEnv, array, elems, mode);
}

void globalEnv_ReleaseDoubleArrayElements(jdoubleArray array, jdouble * elems, jint mode) {
    attach_thread();
    (*jniEnv)->ReleaseDoubleArrayElements(jniEnv, array, elems, mode);
}

void globalEnv_GetBooleanArrayRegion(jbooleanArray array, jsize start, jsize len, jboolean * buf) {
    attach_thread();
    (*jniEnv)->GetBooleanArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_GetByteArrayRegion(jbyteArray array, jsize start, jsize len, jbyte * buf) {
    attach_thread();
    (*jniEnv)->GetByteArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_GetCharArrayRegion(jcharArray array, jsize start, jsize len, jchar * buf) {
    attach_thread();
    (*jniEnv)->GetCharArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_GetShortArrayRegion(jshortArray array, jsize start, jsize len, jshort * buf) {
    attach_thread();
    (*jniEnv)->GetShortArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_GetIntArrayRegion(jintArray array, jsize start, jsize len, jint * buf) {
    attach_thread();
    (*jniEnv)->GetIntArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_GetLongArrayRegion(jlongArray array, jsize start, jsize len, jlong * buf) {
    attach_thread();
    (*jniEnv)->GetLongArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_GetFloatArrayRegion(jfloatArray array, jsize start, jsize len, jfloat * buf) {
    attach_thread();
    (*jniEnv)->GetFloatArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_GetDoubleArrayRegion(jdoubleArray array, jsize start, jsize len, jdouble * buf) {
    attach_thread();
    (*jniEnv)->GetDoubleArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_SetBooleanArrayRegion(jbooleanArray array, jsize start, jsize len, const jboolean * buf) {
    attach_thread();
    (*jniEnv)->SetBooleanArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_SetByteArrayRegion(jbyteArray array, jsize start, jsize len, const jbyte * buf) {
    attach_thread();
    (*jniEnv)->SetByteArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_SetCharArrayRegion(jcharArray array, jsize start, jsize len, const jchar * buf) {
    attach_thread();
    (*jniEnv)->SetCharArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_SetShortArrayRegion(jshortArray array, jsize start, jsize len, const jshort * buf) {
    attach_thread();
    (*jniEnv)->SetShortArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_SetIntArrayRegion(jintArray array, jsize start, jsize len, const jint * buf) {
    attach_thread();
    (*jniEnv)->SetIntArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_SetLongArrayRegion(jlongArray array, jsize start, jsize len, const jlong * buf) {
    attach_thread();
    (*jniEnv)->SetLongArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_SetFloatArrayRegion(jfloatArray array, jsize start, jsize len, const jfloat * buf) {
    attach_thread();
    (*jniEnv)->SetFloatArrayRegion(jniEnv, array, start, len, buf);
}

void globalEnv_SetDoubleArrayRegion(jdoubleArray array, jsize start, jsize len, const jdouble * buf) {
    attach_thread();
    (*jniEnv)->SetDoubleArrayRegion(jniEnv, array, start, len, buf);
}

jint globalEnv_RegisterNatives(jclass clazz, const JNINativeMethod * methods, jint nMethods) {
    attach_thread();
    return (*jniEnv)->RegisterNatives(jniEnv, clazz, methods, nMethods);
}

jint globalEnv_UnregisterNatives(jclass clazz) {
    attach_thread();
    return (*jniEnv)->UnregisterNatives(jniEnv, clazz);
}

jint globalEnv_MonitorEnter(jobject obj) {
    attach_thread();
    return (*jniEnv)->MonitorEnter(jniEnv, obj);
}

jint globalEnv_MonitorExit(jobject obj) {
    attach_thread();
    return (*jniEnv)->MonitorExit(jniEnv, obj);
}

jint globalEnv_GetJavaVM(JavaVM ** vm) {
    attach_thread();
    return (*jniEnv)->GetJavaVM(jniEnv, vm);
}

void globalEnv_GetStringRegion(jstring str, jsize start, jsize len, jchar * buf) {
    attach_thread();
    (*jniEnv)->GetStringRegion(jniEnv, str, start, len, buf);
}

void globalEnv_GetStringUTFRegion(jstring str, jsize start, jsize len, char * buf) {
    attach_thread();
    (*jniEnv)->GetStringUTFRegion(jniEnv, str, start, len, buf);
}

void * globalEnv_GetPrimitiveArrayCritical(jarray array, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetPrimitiveArrayCritical(jniEnv, array, isCopy);
}

void globalEnv_ReleasePrimitiveArrayCritical(jarray array, void * carray, jint mode) {
    attach_thread();
    (*jniEnv)->ReleasePrimitiveArrayCritical(jniEnv, array, carray, mode);
}

const jchar * globalEnv_GetStringCritical(jstring str, jboolean * isCopy) {
    attach_thread();
    return (*jniEnv)->GetStringCritical(jniEnv, str, isCopy);
}

void globalEnv_ReleaseStringCritical(jstring str, const jchar * carray) {
    attach_thread();
    (*jniEnv)->ReleaseStringCritical(jniEnv, str, carray);
}

jweak globalEnv_NewWeakGlobalRef(jobject obj) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewWeakGlobalRef(jniEnv, obj));
}

void globalEnv_DeleteWeakGlobalRef(jweak obj) {
    attach_thread();
    (*jniEnv)->DeleteWeakGlobalRef(jniEnv, obj);
}

jboolean globalEnv_ExceptionCheck() {
    attach_thread();
    return (*jniEnv)->ExceptionCheck(jniEnv);
}

jobject globalEnv_NewDirectByteBuffer(void * address, jlong capacity) {
    attach_thread();
    return to_global_ref((*jniEnv)->NewDirectByteBuffer(jniEnv, address, capacity));
}

void * globalEnv_GetDirectBufferAddress(jobject buf) {
    attach_thread();
    return (*jniEnv)->GetDirectBufferAddress(jniEnv, buf);
}

jlong globalEnv_GetDirectBufferCapacity(jobject buf) {
    attach_thread();
    return (*jniEnv)->GetDirectBufferCapacity(jniEnv, buf);
}

jobjectRefType globalEnv_GetObjectRefType(jobject obj) {
    attach_thread();
    return (*jniEnv)->GetObjectRefType(jniEnv, obj);
}

struct GlobalJniEnv globalEnv = {
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
    .IsSameObject = globalEnv_IsSameObject,
    .EnsureLocalCapacity = globalEnv_EnsureLocalCapacity,
    .AllocObject = globalEnv_AllocObject,
    .NewObject = globalEnv_NewObject,
    .NewObjectA = globalEnv_NewObjectA,
    .GetObjectClass = globalEnv_GetObjectClass,
    .IsInstanceOf = globalEnv_IsInstanceOf,
    .GetMethodID = globalEnv_GetMethodID,
    .CallObjectMethod = globalEnv_CallObjectMethod,
    .CallObjectMethodA = globalEnv_CallObjectMethodA,
    .CallBooleanMethod = globalEnv_CallBooleanMethod,
    .CallBooleanMethodA = globalEnv_CallBooleanMethodA,
    .CallByteMethod = globalEnv_CallByteMethod,
    .CallByteMethodA = globalEnv_CallByteMethodA,
    .CallCharMethod = globalEnv_CallCharMethod,
    .CallCharMethodA = globalEnv_CallCharMethodA,
    .CallShortMethod = globalEnv_CallShortMethod,
    .CallShortMethodA = globalEnv_CallShortMethodA,
    .CallIntMethod = globalEnv_CallIntMethod,
    .CallIntMethodA = globalEnv_CallIntMethodA,
    .CallLongMethod = globalEnv_CallLongMethod,
    .CallLongMethodA = globalEnv_CallLongMethodA,
    .CallFloatMethod = globalEnv_CallFloatMethod,
    .CallFloatMethodA = globalEnv_CallFloatMethodA,
    .CallDoubleMethod = globalEnv_CallDoubleMethod,
    .CallDoubleMethodA = globalEnv_CallDoubleMethodA,
    .CallVoidMethod = globalEnv_CallVoidMethod,
    .CallVoidMethodA = globalEnv_CallVoidMethodA,
    .CallNonvirtualObjectMethod = globalEnv_CallNonvirtualObjectMethod,
    .CallNonvirtualObjectMethodA = globalEnv_CallNonvirtualObjectMethodA,
    .CallNonvirtualBooleanMethod = globalEnv_CallNonvirtualBooleanMethod,
    .CallNonvirtualBooleanMethodA = globalEnv_CallNonvirtualBooleanMethodA,
    .CallNonvirtualByteMethod = globalEnv_CallNonvirtualByteMethod,
    .CallNonvirtualByteMethodA = globalEnv_CallNonvirtualByteMethodA,
    .CallNonvirtualCharMethod = globalEnv_CallNonvirtualCharMethod,
    .CallNonvirtualCharMethodA = globalEnv_CallNonvirtualCharMethodA,
    .CallNonvirtualShortMethod = globalEnv_CallNonvirtualShortMethod,
    .CallNonvirtualShortMethodA = globalEnv_CallNonvirtualShortMethodA,
    .CallNonvirtualIntMethod = globalEnv_CallNonvirtualIntMethod,
    .CallNonvirtualIntMethodA = globalEnv_CallNonvirtualIntMethodA,
    .CallNonvirtualLongMethod = globalEnv_CallNonvirtualLongMethod,
    .CallNonvirtualLongMethodA = globalEnv_CallNonvirtualLongMethodA,
    .CallNonvirtualFloatMethod = globalEnv_CallNonvirtualFloatMethod,
    .CallNonvirtualFloatMethodA = globalEnv_CallNonvirtualFloatMethodA,
    .CallNonvirtualDoubleMethod = globalEnv_CallNonvirtualDoubleMethod,
    .CallNonvirtualDoubleMethodA = globalEnv_CallNonvirtualDoubleMethodA,
    .CallNonvirtualVoidMethod = globalEnv_CallNonvirtualVoidMethod,
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
    .CallStaticObjectMethodA = globalEnv_CallStaticObjectMethodA,
    .CallStaticBooleanMethod = globalEnv_CallStaticBooleanMethod,
    .CallStaticBooleanMethodA = globalEnv_CallStaticBooleanMethodA,
    .CallStaticByteMethod = globalEnv_CallStaticByteMethod,
    .CallStaticByteMethodA = globalEnv_CallStaticByteMethodA,
    .CallStaticCharMethod = globalEnv_CallStaticCharMethod,
    .CallStaticCharMethodA = globalEnv_CallStaticCharMethodA,
    .CallStaticShortMethod = globalEnv_CallStaticShortMethod,
    .CallStaticShortMethodA = globalEnv_CallStaticShortMethodA,
    .CallStaticIntMethod = globalEnv_CallStaticIntMethod,
    .CallStaticIntMethodA = globalEnv_CallStaticIntMethodA,
    .CallStaticLongMethod = globalEnv_CallStaticLongMethod,
    .CallStaticLongMethodA = globalEnv_CallStaticLongMethodA,
    .CallStaticFloatMethod = globalEnv_CallStaticFloatMethod,
    .CallStaticFloatMethodA = globalEnv_CallStaticFloatMethodA,
    .CallStaticDoubleMethod = globalEnv_CallStaticDoubleMethod,
    .CallStaticDoubleMethodA = globalEnv_CallStaticDoubleMethodA,
    .CallStaticVoidMethod = globalEnv_CallStaticVoidMethod,
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

FFI_PLUGIN_EXPORT struct GlobalJniEnv *GetGlobalEnv(void) {
    if (jni.jvm == NULL) return NULL;
    return &globalEnv;
}
