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

static void DOBJC_disposeListenerInvocation(void* peer) {
  DOBJC_ListenerInvocation* invocation = (DOBJC_ListenerInvocation*)peer;
  if (invocation->dispose_args != NULL) {
    invocation->dispose_args(invocation->args);
  }
  free(invocation->args);
  objc_release((ObjCObjectImpl*)invocation->block);
  free(invocation);
}

// Dart_HandleFinalizer for an undeliverable listener invocation. The VM runs
// this only if the message is not delivered (the owner isolate has shut down,
// or shuts down before processing it). May run on any thread, so the ObjC
// releases are routed through the main thread, like DOBJC_finalizeObject.
static void DOBJC_finalizeListenerInvocation(void* isolate_callback_data,
                                             void* peer) {
  DOBJC_runOnMainThread(DOBJC_disposeListenerInvocation, peer);
}

FFI_EXPORT void DOBJC_listenerBlockInvokeStub(void) {}

FFI_EXPORT void DOBJC_postListenerInvocation(
    ObjCBlockImpl* block, void* args, DOBJC_ListenerArgsDispose dispose_args) {
  DOBJC_ListenerInvocation* invocation =
      (DOBJC_ListenerInvocation*)malloc(sizeof(DOBJC_ListenerInvocation));
  invocation->block = (ObjCBlockImpl*)objc_retainBlock((ObjCObjectImpl*)block);
  invocation->args = args;
  invocation->dispose_args = dispose_args;
  Dart_CObject message;
  message.type = Dart_CObject_kNativePointer;
  message.value.as_native_pointer.ptr = (intptr_t)invocation;
  message.value.as_native_pointer.size = sizeof(DOBJC_ListenerInvocation);
  message.value.as_native_pointer.callback = DOBJC_finalizeListenerInvocation;
  // Ownership of the invocation depends on how the post goes:
  //  - Delivered: the Dart-side invoker cleans up; the finalizer is skipped.
  //  - Post refused (owner isolate already gone): the VM drops the finalizer
  //    records ("ownership of external data remains with the poster",
  //    PortMap::PostMessage), so clean up inline here.
  //  - Enqueued but never processed (owner isolate shuts down first): the VM
  //    runs the finalizer while destroying the undelivered message.
  if (!Dart_PostCObject_DL(block->invoke_port, &message)) {
    DOBJC_finalizeListenerInvocation(NULL, invocation);
  }
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

FFI_EXPORT DOBJC_Context* DOBJC_fillContext(DOBJC_Context* context) {
  context->version = 2;
  context->newWaiter = DOBJC_newWaiter;
  context->awaitWaiter = DOBJC_awaitWaiter;
  context->currentIsolate = Dart_CurrentIsolate_DL;
  context->enterIsolate = Dart_EnterIsolate_DL;
  context->exitIsolate = Dart_ExitIsolate_DL;
  context->getMainPortId = Dart_GetMainPortId_DL;
  context->getCurrentThreadOwnsIsolate = Dart_GetCurrentThreadOwnsIsolate_DL;
  context->postListenerInvocation = DOBJC_postListenerInvocation;
  return context;
}
