// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "objective_c.h"

#include <stdint.h>
#include <stdlib.h>

#include "include/dart_api_dl.h"
#include "objective_c_runtime.h"

typedef struct _ObjCBlockInternal {
  void *isa;
  int flags;
  int reserved;
  void *invoke;
  void *descriptor;
} ObjCBlockInternal;

// https://opensource.apple.com/source/libclosure/libclosure-38/Block_private.h
extern void *_NSConcreteStackBlock[32];
extern void *_NSConcreteMallocBlock[32];
extern void *_NSConcreteAutoBlock[32];
extern void *_NSConcreteFinalizingBlock[32];
extern void *_NSConcreteGlobalBlock[32];
extern void *_NSConcreteWeakBlockVariable[32];

// Dispose helper for ObjC blocks that wrap a Dart closure.
void DOBJC_disposeObjCBlockWithClosure(int64_t dispose_port, int64_t closure_id) {
  Dart_PostInteger_DL(dispose_port, closure_id);
}

bool DOBJC_isValidBlock(ObjCBlockImpl* block) {
  if (block == NULL) return false;
  ObjCBlockInternal* blk = (ObjCBlockInternal*)block;
  void* isa = blk->isa;
  return isa == &_NSConcreteStackBlock || isa == &_NSConcreteMallocBlock ||
         isa == &_NSConcreteAutoBlock || isa == &_NSConcreteFinalizingBlock ||
         isa == &_NSConcreteGlobalBlock || isa == &_NSConcreteWeakBlockVariable;
}

void DOBJC_finalizeObject(void* isolate_callback_data, void* peer) {
  // objc_release works for Objects and Blocks.
  DOBJC_runOnMainThread((void (*)(void*))objc_release, peer);
}

Dart_FinalizableHandle DOBJC_newFinalizableHandle(Dart_Handle owner,
                                            ObjCObject* object) {
  return Dart_NewFinalizableHandle_DL(owner, object, 0, DOBJC_finalizeObject);
}

void DOBJC_deleteFinalizableHandle(Dart_FinalizableHandle handle, Dart_Handle owner) {
  Dart_DeleteFinalizableHandle_DL(handle, owner);
}

static void finalizeMalloc(void* isolate_callback_data, void* peer) { free(peer); }

bool* DOBJC_newFinalizableBool(Dart_Handle owner) {
  bool* pointer = (bool*)malloc(1);
  *pointer = false;
  Dart_NewFinalizableHandle_DL(owner, pointer, 1, finalizeMalloc);
  return pointer;
}
