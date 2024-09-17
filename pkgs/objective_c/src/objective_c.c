// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "objective_c.h"

#include <stdlib.h>

#include "include/dart_api_dl.h"
#include "objective_c_runtime.h"

// Dispose helper for ObjC blocks that wrap a Dart closure. For these blocks,
// the target is an int ID, and the dispose_port is listening for these IDs.
void disposeObjCBlockWithClosure(ObjCBlockImpl* block) {
  Dart_PostInteger_DL(block->dispose_port, (int64_t)block->target);
}

bool isValidBlock(ObjCBlockImpl* block) {
  if (block == NULL) return false;
  void* isa = block->isa;
  return isa == &_NSConcreteStackBlock || isa == &_NSConcreteMallocBlock ||
         isa == &_NSConcreteAutoBlock || isa == &_NSConcreteFinalizingBlock ||
         isa == &_NSConcreteGlobalBlock || isa == &_NSConcreteWeakBlockVariable;
}

void finalizeObject(void* isolate_callback_data, void* peer) {
  // objc_release works for Objects and Blocks.
  runOnMainThread(objectRelease, peer);
  // objectRelease(peer);
}

Dart_FinalizableHandle newFinalizableHandle(Dart_Handle owner,
                                                  ObjCObject* object) {
  return Dart_NewFinalizableHandle_DL(owner, object, 0, finalizeObject);
}

void deleteFinalizableHandle(Dart_FinalizableHandle handle, Dart_Handle owner) {
  Dart_DeleteFinalizableHandle_DL(handle, owner);
}

void finalizeMalloc(void* isolate_callback_data, void* peer) {
  free(peer);
}

bool* newFinalizableBool(Dart_Handle owner) {
  bool* pointer = (bool*)malloc(1);
  *pointer = false;
  Dart_NewFinalizableHandle_DL(owner, pointer, 1, finalizeMalloc);
  return pointer;
}

void runOnMainThread(void(*fn)(void*), void* arg);

int _global_retain_count = 0;

ObjCObject *objectRetain(ObjCObject *object) {
  ++_global_retain_count;
  return objc_retain(object);
}

ObjCObject *blockRetain(ObjCObject *object) {
  ++_global_retain_count;
  return objc_retainBlock(object);
}

void objectRelease(ObjCObject *object) {
  --_global_retain_count;
  objc_release(object);
}

int getGlobalRetainCount() {
  return _global_retain_count;
}
