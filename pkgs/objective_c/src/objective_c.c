// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "objective_c.h"

#include <mach/mach.h>
#include <mach/vm_map.h>
#include <stdint.h>
#include <stdlib.h>

#include "include/dart_api_dl.h"
#include "objective_c_runtime.h"

// Dispose helper for ObjC blocks that wrap a Dart closure. For these blocks,
// the target is an int ID, and the dispose_port is listening for these IDs.
FFI_EXPORT void DOBJC_disposeObjCBlockWithClosure(ObjCBlockImpl* block) {
  Dart_PostInteger_DL(block->dispose_port, (int64_t)block->target);
}

static bool isReadableMemory(const void* addr, void* out, size_t size) {
  if (addr == NULL) return false;
  if (((uintptr_t)addr & (sizeof(uintptr_t) - 1)) != 0) return false;
  vm_size_t out_size = 0;
  kern_return_t kr =
      vm_read_overwrite(mach_task_self(), (vm_address_t)addr, (vm_size_t)size,
                        (vm_address_t)out, &out_size);
  return kr == KERN_SUCCESS && out_size == size;
}

FFI_EXPORT bool DOBJC_isValidBlock(ObjCBlockImpl* block) {
  void* isa = NULL;
  if (!isReadableMemory(block, &isa, sizeof(void*))) return false;
  return isa == &_NSConcreteStackBlock || isa == &_NSConcreteMallocBlock ||
         isa == &_NSConcreteAutoBlock || isa == &_NSConcreteFinalizingBlock ||
         isa == &_NSConcreteGlobalBlock || isa == &_NSConcreteWeakBlockVariable;
}

FFI_EXPORT bool DOBJC_isValidObject(ObjCObjectImpl* object) {
  if (object == NULL) return false;
  if (((uintptr_t)object & objc_debug_taggedpointer_mask) != 0) {
    // Tagged pointers encode their payload inline in the pointer bits rather
    // than pointing to readable memory. `object_getClass` looks up the tag
    // index in libobjc's static tagged-pointer class table without
    // dereferencing `object`.
    return object_getClass(object) != NULL;
  }

  uintptr_t isa = 0;
  if (!isReadableMemory(object, &isa, sizeof(uintptr_t))) return false;

  if ((isa & 1) != 0) {
    // Most Objective-C instances use a non-pointer `isa` packing metadata
    // (flags, inline refcount, etc.) alongside the class address, setting
    // bit 0 and magic bits (`object_getClass` errors if they don't match).
    if ((isa & objc_debug_isa_magic_mask) != objc_debug_isa_magic_value) {
      return false;
    }
  } else {
    // `Class` objects, blocks, constant objects, and instances of classes
    // requiring a raw `isa` store a plain 8-byte-aligned `Class` pointer
    // directly in `isa`, leaving the low 3 bits zero.
    if (isa == 0 || (isa & 0x7) != 0) return false;
  }

  uintptr_t cls = isa & objc_debug_isa_class_mask;
  uintptr_t cls_isa = 0;
  if (!isReadableMemory((const void*)cls, &cls_isa, sizeof(uintptr_t))) {
    return false;
  }
  return cls_isa != 0 && (cls_isa & 0x7) == 0;
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

FFI_EXPORT DOBJC_Context* DOBJC_createContext(void) {
  DOBJC_Context* context = (DOBJC_Context*)malloc(sizeof(DOBJC_Context));
  context->version = 2;
  context->newWaiter = DOBJC_newWaiter;
  context->awaitWaiter = DOBJC_awaitWaiter;
  context->currentIsolate = Dart_CurrentIsolate_DL;
  context->enterIsolate = Dart_EnterIsolate_DL;
  context->exitIsolate = Dart_ExitIsolate_DL;
  context->getMainPortId = Dart_GetMainPortId_DL;
  context->getCurrentThreadOwnsIsolate = Dart_GetCurrentThreadOwnsIsolate_DL;
  context->invokeListenerPortBlock = DOBJC_invokeListenerPortBlock;
  context->invokeBlockingPortBlock = DOBJC_invokeBlockingPortBlock;
  return context;
}
