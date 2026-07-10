// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "objective_c.h"

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <dispatch/dispatch.h>

#include "include/dart_api_dl.h"
#include "objective_c_runtime.h"

_Atomic bool _mainThreadIsListening = false;

static void setListening(void* arg) {
  _mainThreadIsListening = true;
}

FFI_EXPORT intptr_t DOBJC_initializeApi(void* data) {
  dispatch_async_f(dispatch_get_main_queue(), NULL, setListening);
  return Dart_InitializeApiDL(data);
}

// Copy and dispose helper for ObjC blocks that wrap a Dart closure. For these
// blocks, the target is an int ID, and the dispose_port is listening for these
// IDs.
FFI_EXPORT void DOBJC_copyObjCBlockWithClosure(ObjCBlockImpl* dst,
                                               ObjCBlockImpl* src) {
  dst->target = src->target;
  dst->dispose_port = src->dispose_port;
}

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
DOBJC_newFinalizableHandle(Dart_Handle owner, ObjCObjectImpl* object) {
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

FFI_EXPORT bool DOBJC_postCObject(int64_t port_id, void* peer,
                                  void (*callback)(void*, void*)) {
  Dart_CObject c_post;
  c_post.type = Dart_CObject_kNativePointer;
  c_post.value.as_native_pointer.ptr = (intptr_t)peer;
  c_post.value.as_native_pointer.size = 0;
  c_post.value.as_native_pointer.callback = (Dart_HandleFinalizer)callback;
  if (!Dart_PostCObject_DL(port_id, &c_post)) {
    if (c_post.value.as_native_pointer.callback != NULL) {
      c_post.value.as_native_pointer.callback(
          NULL, (void*)c_post.value.as_native_pointer.ptr);
    }
    return false;
  }
  return true;
}

FFI_EXPORT DOBJC_Context* DOBJC_fillContext(DOBJC_Context* context) {
  context->version = 2;
  context->newWaiter = DOBJC_newWaiter;
  context->awaitWaiter = DOBJC_awaitWaiter;
  context->currentIsolate = Dart_CurrentIsolate_DL;
  context->enterIsolate = Dart_EnterIsolate_DL;
  context->exitIsolate = Dart_ExitIsolate_DL;
  context->getMainPortId = Dart_GetMainPortId_DL;
  context->getCurrentThreadOwnsIsolate = Dart_GetCurrentThreadOwnsIsolate_DL;
  context->postCObject = DOBJC_postCObject;
  return context;
}
