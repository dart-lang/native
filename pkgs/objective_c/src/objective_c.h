// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_OBJECTIVE_C_H_
#define OBJECTIVE_C_SRC_OBJECTIVE_C_H_

#include "ffi.h"
#include "include/dart_api_dl.h"
#include "objective_c_runtime.h"

// Initialize the Dart API.
FFI_EXPORT intptr_t DOBJC_initializeApi(void *data);

// Dispose helper for ObjC blocks that wrap a Dart closure.
FFI_EXPORT void DOBJC_disposeObjCBlockWithClosure(ObjCBlockImpl *block);

// Returns whether the block is valid and live. The pointer must point to
// readable memory, or be null. May (rarely) return false positives.
FFI_EXPORT bool DOBJC_isValidBlock(ObjCBlockImpl *block);

// Returns a new Dart_FinalizableHandle that will clean up the object when the
// Dart owner is garbage collected.
FFI_EXPORT Dart_FinalizableHandle DOBJC_newFinalizableHandle(
    Dart_Handle owner, ObjCObject* object, void* destroyed_flag);

// Delete a finalizable handle. Doesn't run the finalization callback, so
// doesn't clean up the assocated pointer.
FFI_EXPORT void DOBJC_deleteFinalizableHandle(Dart_FinalizableHandle handle,
                                              Dart_Handle owner);

// Returns a newly allocated bool* (initialized to false) that will be deleted
// by a Dart_FinalizableHandle when the owner is garbage collected.
FFI_EXPORT bool *DOBJC_newFinalizableBool(Dart_Handle owner);

// Runs fn(arg) on the main thread. If runOnMainThread is already running on the
// main thread, fn(arg) is invoked synchronously. Otherwise it is dispatched to
// the main thread (ie dispatch_async(dispatch_get_main_queue(), ...)).
//
// This assumes that the main thread is executing its queue. If not, #define
// NO_MAIN_THREAD_DISPATCH to disable this, and run fn(arg) synchronously. The
// flutter runner does execute the main dispatch queue, but the Dart VM doesn't.
FFI_EXPORT void DOBJC_runOnMainThread(void (*fn)(void *), void *arg);

// Functions for creating a waiter, signaling it, and waiting for the signal. A
// waiter is one-time-use, and the object that newWaiter creates will be
// destroyed once signalWaiter and awaitWaiter are called exactly once.
FFI_EXPORT void *DOBJC_newWaiter(void* flag);
FFI_EXPORT void DOBJC_signalWaiter(void *waiter);
FFI_EXPORT void DOBJC_awaitWaiter(void *waiter);

// A destroyed flag is a DOBJCAtomicBool used to track whether a Dart object is
// still alive. DOBJC_newDestroyedFlag returns a +1 reference that is held in a
// _DOBJCObjectWithDestroyedFlag, and balanced by DOBJC_flipDestroyedFlag. Other
// code that needs to know whether the object is alive can cast it to a
// DOBJCAtomicBool, hold a strong reference to it (so it outlives the object it
// is tracking), and check its value.
FFI_EXPORT void *DOBJC_newDestroyedFlag();
FFI_EXPORT void DOBJC_flipDestroyedFlag(void* flag);

// Context object containing functions needed by the ffigen bindings. Any
// changes to this struct should bump the `version` field filled in by
// package:objective_c, and checked by ffigen. Never change or delete existing
// fields. Keep in sync with the struct defined in ffigen's writer.dart.
typedef struct _DOBJC_Context {
  int64_t version;
  void* (*newWaiter)(void*);
  void (*awaitWaiter)(void*);
  Dart_Isolate (*currentIsolate)(void);
  void (*enterIsolate)(Dart_Isolate);
  void (*exitIsolate)(void);
  int64_t (*getMainPortId)(void);
  bool (*getCurrentThreadOwnsIsolate)(int64_t);
} DOBJC_Context;
FFI_EXPORT DOBJC_Context* DOBJC_fillContext(DOBJC_Context* context);

#endif  // OBJECTIVE_C_SRC_OBJECTIVE_C_H_
