// Auto generated file. Do not edit.

// This is generated from JNI header in Android NDK. License for the same is
// provided below.

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

#include <stdint.h>
#include "../dartjni.h"

typedef struct GlobalJniEnvStruct {
  void* reserved0;
  void* reserved1;
  void* reserved2;
  void* reserved3;
  JniResult (*GetVersion)();
  JniClassLookupResult (*DefineClass)(char* name,
                                      jobject loader,
                                      jbyte* buf,
                                      jsize bufLen);
  JniClassLookupResult (*FindClass)(char* name);
  JniPointerResult (*FromReflectedMethod)(jobject method);
  JniPointerResult (*FromReflectedField)(jobject field);
  JniResult (*ToReflectedMethod)(jclass cls,
                                 jmethodID methodId,
                                 jboolean isStatic);
  JniClassLookupResult (*GetSuperclass)(jclass clazz);
  JniResult (*IsAssignableFrom)(jclass clazz1, jclass clazz2);
  JniResult (*ToReflectedField)(jclass cls,
                                jfieldID fieldID,
                                jboolean isStatic);
  JniResult (*Throw)(jthrowable obj);
  JniResult (*ThrowNew)(jclass clazz, char* message);
  JniResult (*ExceptionOccurred)();
  jthrowable (*ExceptionDescribe)();
  jthrowable (*ExceptionClear)();
  jthrowable (*FatalError)(char* msg);
  JniResult (*PushLocalFrame)(jint capacity);
  JniResult (*PopLocalFrame)(jobject result);
  JniResult (*NewGlobalRef)(jobject obj);
  jthrowable (*DeleteGlobalRef)(jobject globalRef);
  jthrowable (*DeleteLocalRef)(jobject localRef);
  JniResult (*IsSameObject)(jobject ref1, jobject ref2);
  JniResult (*NewLocalRef)(jobject obj);
  JniResult (*EnsureLocalCapacity)(jint capacity);
  JniResult (*AllocObject)(jclass clazz);
  JniResult (*NewObject)(jclass clazz, jmethodID methodID, ...);
  JniResult (*NewObjectV)(jclass, jmethodID, void*);
  JniResult (*NewObjectA)(jclass clazz, jmethodID methodID, jvalue* args);
  JniClassLookupResult (*GetObjectClass)(jobject obj);
  JniResult (*IsInstanceOf)(jobject obj, jclass clazz);
  JniPointerResult (*GetMethodID)(jclass clazz, char* name, char* sig);
  JniResult (*CallObjectMethod)(jobject obj, jmethodID methodID, ...);
  JniResult (*CallObjectMethodV)(jobject, jmethodID, void*);
  JniResult (*CallObjectMethodA)(jobject obj, jmethodID methodID, jvalue* args);
  JniResult (*CallBooleanMethod)(jobject obj, jmethodID methodID, ...);
  JniResult (*CallBooleanMethodV)(jobject, jmethodID, void*);
  JniResult (*CallBooleanMethodA)(jobject obj,
                                  jmethodID methodId,
                                  jvalue* args);
  JniResult (*CallByteMethod)(jobject obj, jmethodID methodID, ...);
  JniResult (*CallByteMethodV)(jobject, jmethodID, void*);
  JniResult (*CallByteMethodA)(jobject obj, jmethodID methodID, jvalue* args);
  JniResult (*CallCharMethod)(jobject obj, jmethodID methodID, ...);
  JniResult (*CallCharMethodV)(jobject, jmethodID, void*);
  JniResult (*CallCharMethodA)(jobject obj, jmethodID methodID, jvalue* args);
  JniResult (*CallShortMethod)(jobject obj, jmethodID methodID, ...);
  JniResult (*CallShortMethodV)(jobject, jmethodID, void*);
  JniResult (*CallShortMethodA)(jobject obj, jmethodID methodID, jvalue* args);
  JniResult (*CallIntMethod)(jobject obj, jmethodID methodID, ...);
  JniResult (*CallIntMethodV)(jobject, jmethodID, void*);
  JniResult (*CallIntMethodA)(jobject obj, jmethodID methodID, jvalue* args);
  JniResult (*CallLongMethod)(jobject obj, jmethodID methodID, ...);
  JniResult (*CallLongMethodV)(jobject, jmethodID, void*);
  JniResult (*CallLongMethodA)(jobject obj, jmethodID methodID, jvalue* args);
  JniResult (*CallFloatMethod)(jobject obj, jmethodID methodID, ...);
  JniResult (*CallFloatMethodV)(jobject, jmethodID, void*);
  JniResult (*CallFloatMethodA)(jobject obj, jmethodID methodID, jvalue* args);
  JniResult (*CallDoubleMethod)(jobject obj, jmethodID methodID, ...);
  JniResult (*CallDoubleMethodV)(jobject, jmethodID, void*);
  JniResult (*CallDoubleMethodA)(jobject obj, jmethodID methodID, jvalue* args);
  jthrowable (*CallVoidMethod)(jobject obj, jmethodID methodID, ...);
  jthrowable (*CallVoidMethodV)(jobject, jmethodID, void*);
  jthrowable (*CallVoidMethodA)(jobject obj, jmethodID methodID, jvalue* args);
  JniResult (*CallNonvirtualObjectMethod)(jobject obj,
                                          jclass clazz,
                                          jmethodID methodID,
                                          ...);
  JniResult (*CallNonvirtualObjectMethodV)(jobject, jclass, jmethodID, void*);
  JniResult (*CallNonvirtualObjectMethodA)(jobject obj,
                                           jclass clazz,
                                           jmethodID methodID,
                                           jvalue* args);
  JniResult (*CallNonvirtualBooleanMethod)(jobject obj,
                                           jclass clazz,
                                           jmethodID methodID,
                                           ...);
  JniResult (*CallNonvirtualBooleanMethodV)(jobject, jclass, jmethodID, void*);
  JniResult (*CallNonvirtualBooleanMethodA)(jobject obj,
                                            jclass clazz,
                                            jmethodID methodID,
                                            jvalue* args);
  JniResult (*CallNonvirtualByteMethod)(jobject obj,
                                        jclass clazz,
                                        jmethodID methodID,
                                        ...);
  JniResult (*CallNonvirtualByteMethodV)(jobject, jclass, jmethodID, void*);
  JniResult (*CallNonvirtualByteMethodA)(jobject obj,
                                         jclass clazz,
                                         jmethodID methodID,
                                         jvalue* args);
  JniResult (*CallNonvirtualCharMethod)(jobject obj,
                                        jclass clazz,
                                        jmethodID methodID,
                                        ...);
  JniResult (*CallNonvirtualCharMethodV)(jobject, jclass, jmethodID, void*);
  JniResult (*CallNonvirtualCharMethodA)(jobject obj,
                                         jclass clazz,
                                         jmethodID methodID,
                                         jvalue* args);
  JniResult (*CallNonvirtualShortMethod)(jobject obj,
                                         jclass clazz,
                                         jmethodID methodID,
                                         ...);
  JniResult (*CallNonvirtualShortMethodV)(jobject, jclass, jmethodID, void*);
  JniResult (*CallNonvirtualShortMethodA)(jobject obj,
                                          jclass clazz,
                                          jmethodID methodID,
                                          jvalue* args);
  JniResult (*CallNonvirtualIntMethod)(jobject obj,
                                       jclass clazz,
                                       jmethodID methodID,
                                       ...);
  JniResult (*CallNonvirtualIntMethodV)(jobject, jclass, jmethodID, void*);
  JniResult (*CallNonvirtualIntMethodA)(jobject obj,
                                        jclass clazz,
                                        jmethodID methodID,
                                        jvalue* args);
  JniResult (*CallNonvirtualLongMethod)(jobject obj,
                                        jclass clazz,
                                        jmethodID methodID,
                                        ...);
  JniResult (*CallNonvirtualLongMethodV)(jobject, jclass, jmethodID, void*);
  JniResult (*CallNonvirtualLongMethodA)(jobject obj,
                                         jclass clazz,
                                         jmethodID methodID,
                                         jvalue* args);
  JniResult (*CallNonvirtualFloatMethod)(jobject obj,
                                         jclass clazz,
                                         jmethodID methodID,
                                         ...);
  JniResult (*CallNonvirtualFloatMethodV)(jobject, jclass, jmethodID, void*);
  JniResult (*CallNonvirtualFloatMethodA)(jobject obj,
                                          jclass clazz,
                                          jmethodID methodID,
                                          jvalue* args);
  JniResult (*CallNonvirtualDoubleMethod)(jobject obj,
                                          jclass clazz,
                                          jmethodID methodID,
                                          ...);
  JniResult (*CallNonvirtualDoubleMethodV)(jobject, jclass, jmethodID, void*);
  JniResult (*CallNonvirtualDoubleMethodA)(jobject obj,
                                           jclass clazz,
                                           jmethodID methodID,
                                           jvalue* args);
  jthrowable (*CallNonvirtualVoidMethod)(jobject obj,
                                         jclass clazz,
                                         jmethodID methodID,
                                         ...);
  jthrowable (*CallNonvirtualVoidMethodV)(jobject, jclass, jmethodID, void*);
  jthrowable (*CallNonvirtualVoidMethodA)(jobject obj,
                                          jclass clazz,
                                          jmethodID methodID,
                                          jvalue* args);
  JniPointerResult (*GetFieldID)(jclass clazz, char* name, char* sig);
  JniResult (*GetObjectField)(jobject obj, jfieldID fieldID);
  JniResult (*GetBooleanField)(jobject obj, jfieldID fieldID);
  JniResult (*GetByteField)(jobject obj, jfieldID fieldID);
  JniResult (*GetCharField)(jobject obj, jfieldID fieldID);
  JniResult (*GetShortField)(jobject obj, jfieldID fieldID);
  JniResult (*GetIntField)(jobject obj, jfieldID fieldID);
  JniResult (*GetLongField)(jobject obj, jfieldID fieldID);
  JniResult (*GetFloatField)(jobject obj, jfieldID fieldID);
  JniResult (*GetDoubleField)(jobject obj, jfieldID fieldID);
  jthrowable (*SetObjectField)(jobject obj, jfieldID fieldID, jobject val);
  jthrowable (*SetBooleanField)(jobject obj, jfieldID fieldID, jboolean val);
  jthrowable (*SetByteField)(jobject obj, jfieldID fieldID, jbyte val);
  jthrowable (*SetCharField)(jobject obj, jfieldID fieldID, jchar val);
  jthrowable (*SetShortField)(jobject obj, jfieldID fieldID, jshort val);
  jthrowable (*SetIntField)(jobject obj, jfieldID fieldID, jint val);
  jthrowable (*SetLongField)(jobject obj, jfieldID fieldID, jlong val);
  jthrowable (*SetFloatField)(jobject obj, jfieldID fieldID, jfloat val);
  jthrowable (*SetDoubleField)(jobject obj, jfieldID fieldID, jdouble val);
  JniPointerResult (*GetStaticMethodID)(jclass clazz, char* name, char* sig);
  JniResult (*CallStaticObjectMethod)(jclass clazz, jmethodID methodID, ...);
  JniResult (*CallStaticObjectMethodV)(jclass, jmethodID, void*);
  JniResult (*CallStaticObjectMethodA)(jclass clazz,
                                       jmethodID methodID,
                                       jvalue* args);
  JniResult (*CallStaticBooleanMethod)(jclass clazz, jmethodID methodID, ...);
  JniResult (*CallStaticBooleanMethodV)(jclass, jmethodID, void*);
  JniResult (*CallStaticBooleanMethodA)(jclass clazz,
                                        jmethodID methodID,
                                        jvalue* args);
  JniResult (*CallStaticByteMethod)(jclass clazz, jmethodID methodID, ...);
  JniResult (*CallStaticByteMethodV)(jclass, jmethodID, void*);
  JniResult (*CallStaticByteMethodA)(jclass clazz,
                                     jmethodID methodID,
                                     jvalue* args);
  JniResult (*CallStaticCharMethod)(jclass clazz, jmethodID methodID, ...);
  JniResult (*CallStaticCharMethodV)(jclass, jmethodID, void*);
  JniResult (*CallStaticCharMethodA)(jclass clazz,
                                     jmethodID methodID,
                                     jvalue* args);
  JniResult (*CallStaticShortMethod)(jclass clazz, jmethodID methodID, ...);
  JniResult (*CallStaticShortMethodV)(jclass, jmethodID, void*);
  JniResult (*CallStaticShortMethodA)(jclass clazz,
                                      jmethodID methodID,
                                      jvalue* args);
  JniResult (*CallStaticIntMethod)(jclass clazz, jmethodID methodID, ...);
  JniResult (*CallStaticIntMethodV)(jclass, jmethodID, void*);
  JniResult (*CallStaticIntMethodA)(jclass clazz,
                                    jmethodID methodID,
                                    jvalue* args);
  JniResult (*CallStaticLongMethod)(jclass clazz, jmethodID methodID, ...);
  JniResult (*CallStaticLongMethodV)(jclass, jmethodID, void*);
  JniResult (*CallStaticLongMethodA)(jclass clazz,
                                     jmethodID methodID,
                                     jvalue* args);
  JniResult (*CallStaticFloatMethod)(jclass clazz, jmethodID methodID, ...);
  JniResult (*CallStaticFloatMethodV)(jclass, jmethodID, void*);
  JniResult (*CallStaticFloatMethodA)(jclass clazz,
                                      jmethodID methodID,
                                      jvalue* args);
  JniResult (*CallStaticDoubleMethod)(jclass clazz, jmethodID methodID, ...);
  JniResult (*CallStaticDoubleMethodV)(jclass, jmethodID, void*);
  JniResult (*CallStaticDoubleMethodA)(jclass clazz,
                                       jmethodID methodID,
                                       jvalue* args);
  jthrowable (*CallStaticVoidMethod)(jclass clazz, jmethodID methodID, ...);
  jthrowable (*CallStaticVoidMethodV)(jclass, jmethodID, void*);
  jthrowable (*CallStaticVoidMethodA)(jclass clazz,
                                      jmethodID methodID,
                                      jvalue* args);
  JniPointerResult (*GetStaticFieldID)(jclass clazz, char* name, char* sig);
  JniResult (*GetStaticObjectField)(jclass clazz, jfieldID fieldID);
  JniResult (*GetStaticBooleanField)(jclass clazz, jfieldID fieldID);
  JniResult (*GetStaticByteField)(jclass clazz, jfieldID fieldID);
  JniResult (*GetStaticCharField)(jclass clazz, jfieldID fieldID);
  JniResult (*GetStaticShortField)(jclass clazz, jfieldID fieldID);
  JniResult (*GetStaticIntField)(jclass clazz, jfieldID fieldID);
  JniResult (*GetStaticLongField)(jclass clazz, jfieldID fieldID);
  JniResult (*GetStaticFloatField)(jclass clazz, jfieldID fieldID);
  JniResult (*GetStaticDoubleField)(jclass clazz, jfieldID fieldID);
  jthrowable (*SetStaticObjectField)(jclass clazz,
                                     jfieldID fieldID,
                                     jobject val);
  jthrowable (*SetStaticBooleanField)(jclass clazz,
                                      jfieldID fieldID,
                                      jboolean val);
  jthrowable (*SetStaticByteField)(jclass clazz, jfieldID fieldID, jbyte val);
  jthrowable (*SetStaticCharField)(jclass clazz, jfieldID fieldID, jchar val);
  jthrowable (*SetStaticShortField)(jclass clazz, jfieldID fieldID, jshort val);
  jthrowable (*SetStaticIntField)(jclass clazz, jfieldID fieldID, jint val);
  jthrowable (*SetStaticLongField)(jclass clazz, jfieldID fieldID, jlong val);
  jthrowable (*SetStaticFloatField)(jclass clazz, jfieldID fieldID, jfloat val);
  jthrowable (*SetStaticDoubleField)(jclass clazz,
                                     jfieldID fieldID,
                                     jdouble val);
  JniResult (*NewString)(jchar* unicodeChars, jsize len);
  JniResult (*GetStringLength)(jstring string);
  JniPointerResult (*GetStringChars)(jstring string, jboolean* isCopy);
  jthrowable (*ReleaseStringChars)(jstring string, jchar* isCopy);
  JniResult (*NewStringUTF)(char* bytes);
  JniResult (*GetStringUTFLength)(jstring string);
  JniPointerResult (*GetStringUTFChars)(jstring string, jboolean* isCopy);
  jthrowable (*ReleaseStringUTFChars)(jstring string, char* utf);
  JniResult (*GetArrayLength)(jarray array);
  JniResult (*NewObjectArray)(jsize length,
                              jclass elementClass,
                              jobject initialElement);
  JniResult (*GetObjectArrayElement)(jobjectArray array, jsize index);
  jthrowable (*SetObjectArrayElement)(jobjectArray array,
                                      jsize index,
                                      jobject val);
  JniResult (*NewBooleanArray)(jsize length);
  JniResult (*NewByteArray)(jsize length);
  JniResult (*NewCharArray)(jsize length);
  JniResult (*NewShortArray)(jsize length);
  JniResult (*NewIntArray)(jsize length);
  JniResult (*NewLongArray)(jsize length);
  JniResult (*NewFloatArray)(jsize length);
  JniResult (*NewDoubleArray)(jsize length);
  JniPointerResult (*GetBooleanArrayElements)(jbooleanArray array,
                                              jboolean* isCopy);
  JniPointerResult (*GetByteArrayElements)(jbyteArray array, jboolean* isCopy);
  JniPointerResult (*GetCharArrayElements)(jcharArray array, jboolean* isCopy);
  JniPointerResult (*GetShortArrayElements)(jshortArray array,
                                            jboolean* isCopy);
  JniPointerResult (*GetIntArrayElements)(jintArray array, jboolean* isCopy);
  JniPointerResult (*GetLongArrayElements)(jlongArray array, jboolean* isCopy);
  JniPointerResult (*GetFloatArrayElements)(jfloatArray array,
                                            jboolean* isCopy);
  JniPointerResult (*GetDoubleArrayElements)(jdoubleArray array,
                                             jboolean* isCopy);
  jthrowable (*ReleaseBooleanArrayElements)(jbooleanArray array,
                                            jboolean* elems,
                                            jint mode);
  jthrowable (*ReleaseByteArrayElements)(jbyteArray array,
                                         jbyte* elems,
                                         jint mode);
  jthrowable (*ReleaseCharArrayElements)(jcharArray array,
                                         jchar* elems,
                                         jint mode);
  jthrowable (*ReleaseShortArrayElements)(jshortArray array,
                                          jshort* elems,
                                          jint mode);
  jthrowable (*ReleaseIntArrayElements)(jintArray array,
                                        jint* elems,
                                        jint mode);
  jthrowable (*ReleaseLongArrayElements)(jlongArray array,
                                         jlong* elems,
                                         jint mode);
  jthrowable (*ReleaseFloatArrayElements)(jfloatArray array,
                                          jfloat* elems,
                                          jint mode);
  jthrowable (*ReleaseDoubleArrayElements)(jdoubleArray array,
                                           jdouble* elems,
                                           jint mode);
  jthrowable (*GetBooleanArrayRegion)(jbooleanArray array,
                                      jsize start,
                                      jsize len,
                                      jboolean* buf);
  jthrowable (*GetByteArrayRegion)(jbyteArray array,
                                   jsize start,
                                   jsize len,
                                   jbyte* buf);
  jthrowable (*GetCharArrayRegion)(jcharArray array,
                                   jsize start,
                                   jsize len,
                                   jchar* buf);
  jthrowable (*GetShortArrayRegion)(jshortArray array,
                                    jsize start,
                                    jsize len,
                                    jshort* buf);
  jthrowable (*GetIntArrayRegion)(jintArray array,
                                  jsize start,
                                  jsize len,
                                  jint* buf);
  jthrowable (*GetLongArrayRegion)(jlongArray array,
                                   jsize start,
                                   jsize len,
                                   jlong* buf);
  jthrowable (*GetFloatArrayRegion)(jfloatArray array,
                                    jsize start,
                                    jsize len,
                                    jfloat* buf);
  jthrowable (*GetDoubleArrayRegion)(jdoubleArray array,
                                     jsize start,
                                     jsize len,
                                     jdouble* buf);
  jthrowable (*SetBooleanArrayRegion)(jbooleanArray array,
                                      jsize start,
                                      jsize len,
                                      jboolean* buf);
  jthrowable (*SetByteArrayRegion)(jbyteArray array,
                                   jsize start,
                                   jsize len,
                                   jbyte* buf);
  jthrowable (*SetCharArrayRegion)(jcharArray array,
                                   jsize start,
                                   jsize len,
                                   jchar* buf);
  jthrowable (*SetShortArrayRegion)(jshortArray array,
                                    jsize start,
                                    jsize len,
                                    jshort* buf);
  jthrowable (*SetIntArrayRegion)(jintArray array,
                                  jsize start,
                                  jsize len,
                                  jint* buf);
  jthrowable (*SetLongArrayRegion)(jlongArray array,
                                   jsize start,
                                   jsize len,
                                   jlong* buf);
  jthrowable (*SetFloatArrayRegion)(jfloatArray array,
                                    jsize start,
                                    jsize len,
                                    jfloat* buf);
  jthrowable (*SetDoubleArrayRegion)(jdoubleArray array,
                                     jsize start,
                                     jsize len,
                                     jdouble* buf);
  JniResult (*RegisterNatives)(jclass clazz,
                               JNINativeMethod* methods,
                               jint nMethods);
  JniResult (*UnregisterNatives)(jclass clazz);
  JniResult (*MonitorEnter)(jobject obj);
  JniResult (*MonitorExit)(jobject obj);
  JniResult (*GetJavaVM)(JavaVM** vm);
  jthrowable (*GetStringRegion)(jstring str,
                                jsize start,
                                jsize len,
                                jchar* buf);
  jthrowable (*GetStringUTFRegion)(jstring str,
                                   jsize start,
                                   jsize len,
                                   char* buf);
  JniPointerResult (*GetPrimitiveArrayCritical)(jarray array, jboolean* isCopy);
  jthrowable (*ReleasePrimitiveArrayCritical)(jarray array,
                                              void* carray,
                                              jint mode);
  JniPointerResult (*GetStringCritical)(jstring str, jboolean* isCopy);
  jthrowable (*ReleaseStringCritical)(jstring str, jchar* carray);
  JniResult (*NewWeakGlobalRef)(jobject obj);
  jthrowable (*DeleteWeakGlobalRef)(jweak obj);
  JniResult (*ExceptionCheck)();
  JniResult (*NewDirectByteBuffer)(void* address, jlong capacity);
  JniPointerResult (*GetDirectBufferAddress)(jobject buf);
  JniResult (*GetDirectBufferCapacity)(jobject buf);
  JniResult (*GetObjectRefType)(jobject obj);
} GlobalJniEnvStruct;
FFI_PLUGIN_EXPORT GlobalJniEnvStruct* GetGlobalEnv();
FFI_PLUGIN_EXPORT JniResult globalEnv_NewObject(jclass clazz,
                                                jmethodID methodID,
                                                ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallObjectMethod(jobject obj,
                                                       jmethodID methodID,
                                                       ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallBooleanMethod(jobject obj,
                                                        jmethodID methodID,
                                                        ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallByteMethod(jobject obj,
                                                     jmethodID methodID,
                                                     ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallCharMethod(jobject obj,
                                                     jmethodID methodID,
                                                     ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallShortMethod(jobject obj,
                                                      jmethodID methodID,
                                                      ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallIntMethod(jobject obj,
                                                    jmethodID methodID,
                                                    ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallLongMethod(jobject obj,
                                                     jmethodID methodID,
                                                     ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallFloatMethod(jobject obj,
                                                      jmethodID methodID,
                                                      ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallDoubleMethod(jobject obj,
                                                       jmethodID methodID,
                                                       ...);
FFI_PLUGIN_EXPORT jthrowable globalEnv_CallVoidMethod(jobject obj,
                                                      jmethodID methodID,
                                                      ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualObjectMethod(jobject obj,
                                     jclass clazz,
                                     jmethodID methodID,
                                     ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualBooleanMethod(jobject obj,
                                      jclass clazz,
                                      jmethodID methodID,
                                      ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualByteMethod(jobject obj,
                                   jclass clazz,
                                   jmethodID methodID,
                                   ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualCharMethod(jobject obj,
                                   jclass clazz,
                                   jmethodID methodID,
                                   ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualShortMethod(jobject obj,
                                    jclass clazz,
                                    jmethodID methodID,
                                    ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualIntMethod(jobject obj,
                                  jclass clazz,
                                  jmethodID methodID,
                                  ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualLongMethod(jobject obj,
                                   jclass clazz,
                                   jmethodID methodID,
                                   ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualFloatMethod(jobject obj,
                                    jclass clazz,
                                    jmethodID methodID,
                                    ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallNonvirtualDoubleMethod(jobject obj,
                                     jclass clazz,
                                     jmethodID methodID,
                                     ...);
FFI_PLUGIN_EXPORT jthrowable
globalEnv_CallNonvirtualVoidMethod(jobject obj,
                                   jclass clazz,
                                   jmethodID methodID,
                                   ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticObjectMethod(jclass clazz,
                                                             jmethodID methodID,
                                                             ...);
FFI_PLUGIN_EXPORT JniResult
globalEnv_CallStaticBooleanMethod(jclass clazz, jmethodID methodID, ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticByteMethod(jclass clazz,
                                                           jmethodID methodID,
                                                           ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticCharMethod(jclass clazz,
                                                           jmethodID methodID,
                                                           ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticShortMethod(jclass clazz,
                                                            jmethodID methodID,
                                                            ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticIntMethod(jclass clazz,
                                                          jmethodID methodID,
                                                          ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticLongMethod(jclass clazz,
                                                           jmethodID methodID,
                                                           ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticFloatMethod(jclass clazz,
                                                            jmethodID methodID,
                                                            ...);
FFI_PLUGIN_EXPORT JniResult globalEnv_CallStaticDoubleMethod(jclass clazz,
                                                             jmethodID methodID,
                                                             ...);
FFI_PLUGIN_EXPORT jthrowable globalEnv_CallStaticVoidMethod(jclass clazz,
                                                            jmethodID methodID,
                                                            ...);
