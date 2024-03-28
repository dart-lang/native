// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file exposes a subset of the Objective C runtime. Ideally we'd just run
// ffigen directly on the runtime headers that come with XCode, but those
// headers don't have everything we need (e.g. the ObjCBlock struct).

typedef struct _ObjCSelector ObjCSelector;
typedef struct _ObjCObject ObjCObject;

ObjCSelector* sel_registerName(const char *name);
ObjCObject* objc_getClass(const char *name);
ObjCObject* objc_retain(ObjCObject* object);
void objc_release(ObjCObject* object);

// See https://clang.llvm.org/docs/Block-ABI-Apple.html
typedef struct _ObjCBlockDesc {
  unsigned long int reserved;
  unsigned long int size;  // sizeof(_ObjCBlock)
  void (*copy_helper)(void *dst, void *src);
  void (*dispose_helper)(void *src);
  const char *signature;
} ObjCBlockDesc;

extern void* const _NSConcreteGlobalBlock;

typedef struct _ObjCBlock {
    void *isa;  // _NSConcreteGlobalBlock
    int flags;
    int reserved;
    void *invoke;  // RET (*invoke)(ObjCBlock *, ARGS...);
    ObjCBlockDesc *descriptor;

    // Captured variables follow. These are specific to our use case.
    void* target;
} ObjCBlock;

ObjCBlock* Block_copy(ObjCBlock* object);
void Block_release(ObjCBlock* object);
