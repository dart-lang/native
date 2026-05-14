// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file exposes a subset of the Objective C runtime. Ideally we'd just run
// FFIgen directly on the runtime headers that come with XCode, but those
// headers don't have everything we need (e.g. the ObjCBlockImpl struct).

#ifndef OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_H_
#define OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_H_

#include "include/dart_api_dl.h"

typedef struct _ObjCSelector ObjCSelector;
typedef struct _ObjCObjectImpl ObjCObjectImpl;
typedef struct _ObjCProtocolImpl ObjCProtocolImpl;

ObjCSelector *sel_registerName(const char *name);
const char * sel_getName(ObjCSelector* sel);
ObjCObjectImpl *objc_getClass(const char *name);
ObjCObjectImpl *objc_retain(ObjCObjectImpl *object);
ObjCObjectImpl *objc_retainBlock(const ObjCObjectImpl *object);
void objc_release(ObjCObjectImpl *object);
ObjCObjectImpl *objc_autorelease(ObjCObjectImpl *object);
ObjCObjectImpl *object_getClass(ObjCObjectImpl *object);
ObjCObjectImpl** objc_copyClassList(unsigned int* count);
void *objc_autoreleasePoolPush(void);
void objc_autoreleasePoolPop(void *pool);

// The signature of this function is just a placeholder. This function is used
// by every method invocation, and is cast to every signature we need.
void objc_msgSend(void);
void objc_msgSend_fpret(void);
void objc_msgSend_stret(void);

// https://opensource.apple.com/source/libclosure/libclosure-38/Block_private.h
extern void *_NSConcreteStackBlock[32];
extern void *_NSConcreteMallocBlock[32];
extern void *_NSConcreteAutoBlock[32];
extern void *_NSConcreteFinalizingBlock[32];
extern void *_NSConcreteGlobalBlock[32];
extern void *_NSConcreteWeakBlockVariable[32];

typedef struct _ObjCMethodDesc {
  ObjCSelector* name;
  const char* types;
} ObjCMethodDesc;

ObjCProtocolImpl* objc_getProtocol(const char* name);
ObjCMethodDesc protocol_getMethodDescription(
    ObjCProtocolImpl* protocol, ObjCSelector* sel, bool isRequiredMethod,
    bool isInstanceMethod);
const char *protocol_getName(ObjCProtocolImpl *proto);

extern const ObjCObjectImpl *NSKeyValueChangeIndexesKey;
extern const ObjCObjectImpl *NSKeyValueChangeKindKey;
extern const ObjCObjectImpl *NSKeyValueChangeNewKey;
extern const ObjCObjectImpl *NSKeyValueChangeNotificationIsPriorKey;
extern const ObjCObjectImpl *NSKeyValueChangeOldKey;
extern const ObjCObjectImpl *NSLocalizedDescriptionKey;

#endif  // OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_H_
