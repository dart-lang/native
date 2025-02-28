// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "objective_c.h"

#include <stdint.h>
#include <stdlib.h>

#include "include/dart_api_dl.h"
#include "objective_c_runtime.h"

// Dispose helper for ObjC blocks that wrap a Dart closure. For these blocks,
// the target is an int ID, and the dispose_port is listening for these IDs.
FFI_EXPORT void DOBJC_disposeObjCBlockWithClosure(ObjCBlockImpl* block) {
  Dart_PostInteger_DL(block->dispose_port, (int64_t)block->target);
}

FFI_EXPORT bool DOBJC_isValidBlock(ObjCBlockImpl* block) {
  if (block == NULL) return false;
  void* isa = block->isa;
  return isa == &_NSConcreteStackBlock || isa == &_NSConcreteMallocBlock ||
         isa == &_NSConcreteAutoBlock || isa == &_NSConcreteFinalizingBlock ||
         isa == &_NSConcreteGlobalBlock || isa == &_NSConcreteWeakBlockVariable;
}

FFI_EXPORT void DOBJC_finalizeObject(void* isolate_callback_data, void* peer) {
  // objc_release works for Objects and Blocks.
  DOBJC_runOnMainThread((void (*)(void*))objc_release, peer);
}

FFI_EXPORT Dart_FinalizableHandle
DOBJC_newFinalizableHandle(Dart_Handle owner, ObjCObject* object) {
  return Dart_NewFinalizableHandle_DL(owner, object, 0, DOBJC_finalizeObject);
}

FFI_EXPORT void DOBJC_deleteFinalizableHandle(Dart_FinalizableHandle handle,
                                              Dart_Handle owner) {
  Dart_DeleteFinalizableHandle_DL(handle, owner);
}

static void finalizeMalloc(void* isolate_callback_data, void* peer) {
  free(peer);
}

FFI_EXPORT bool* DOBJC_newFinalizableBool(Dart_Handle owner) {
  bool* pointer = (bool*)malloc(1);
  *pointer = false;
  Dart_NewFinalizableHandle_DL(owner, pointer, 1, finalizeMalloc);
  return pointer;
}

FFI_EXPORT intptr_t DOBJC_InitializeApi(void* data) {
  return Dart_InitializeApiDL(data);
}

FFI_EXPORT DOBJC_Context* DOBJC_fillContext(DOBJC_Context* context) {
  context->version = 1;
  context->newWaiter = DOBJC_newWaiter;
  context->awaitWaiter = DOBJC_awaitWaiter;
  context->currentIsolate = Dart_CurrentIsolateDL;
  context->enterIsolate = Dart_EnterIsolateDL;
  context->exitIsolate = Dart_ExitIsolateDL;
  context->getMainPortId = Dart_GetMainPortIdDL;
  context->getCurrentThreadOwnsIsolate = Dart_GetCurrentThreadOwnsIsolateDL;
  return context;
}
