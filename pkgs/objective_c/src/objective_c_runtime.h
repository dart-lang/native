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
void objc_msgSend();
void objc_msgSend_fpret();
void objc_msgSend_stret();

// See https://clang.llvm.org/docs/Block-ABI-Apple.html
typedef struct _ObjCBlockDesc {
  unsigned long int reserved;
  unsigned long int size;  // sizeof(ObjCBlockImpl)
  void (*copy_helper)(void *dst, void *src);
  void (*dispose_helper)(void *src);
  const char *signature;
} ObjCBlockDesc;

typedef struct _ObjCBlockImpl {
  void *isa;  // _NSConcreteGlobalBlock
  int flags;
  int reserved;
  void *invoke;  // RET (*invoke)(ObjCBlockImpl *, ARGS...);
  ObjCBlockDesc *descriptor;

  // Captured variables follow. These are specific to our use case.
  void *target;
  Dart_Port dispose_port;
} ObjCBlockImpl;

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

ObjCProtocol* objc_getProtocol(const char* name);
ObjCMethodDesc protocol_getMethodDescription(
    ObjCProtocol* protocol, ObjCSelector* sel, bool isRequiredMethod,
    bool isInstanceMethod);

#endif  // OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_H_
