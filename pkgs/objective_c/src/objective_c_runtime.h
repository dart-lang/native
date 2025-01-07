// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file exposes a subset of the Objective C runtime. Ideally we'd just run
// ffigen directly on the runtime headers that come with XCode, but those
// headers don't have everything we need (e.g. the ObjCBlockImpl struct).

#ifndef OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_H_
#define OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_H_

#include "include/dart_api_dl.h"

typedef struct _ObjCSelector ObjCSelector;
typedef struct _ObjCObject ObjCObject;
typedef struct _ObjCBlockImpl ObjCBlockImpl;
typedef struct _ObjCProtocol ObjCProtocol;

ObjCSelector *sel_registerName(const char *name);
const char * sel_getName(ObjCSelector* sel);
ObjCObject *objc_getClass(const char *name);
ObjCObject *objc_retain(ObjCObject *object);
ObjCObject *objc_retainBlock(const ObjCObject *object);
void objc_release(ObjCObject *object);
ObjCObject *objc_autorelease(ObjCObject *object);
ObjCObject *object_getClass(ObjCObject *object);
ObjCObject** objc_copyClassList(unsigned int* count);

// The signature of this function is just a placeholder. This function is used
// by every method invocation, and is cast to every signature we need.
void objc_msgSend(void);
void objc_msgSend_fpret(void);
void objc_msgSend_stret(void);

typedef struct _ObjCMethodDesc {
  ObjCSelector* name;
  const char* types;
} ObjCMethodDesc;

ObjCProtocol* objc_getProtocol(const char* name);
ObjCMethodDesc protocol_getMethodDescription(
    ObjCProtocol* protocol, ObjCSelector* sel, bool isRequiredMethod,
    bool isInstanceMethod);
const char *protocol_getName(ObjCProtocol *proto);

#endif  // OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_H_
