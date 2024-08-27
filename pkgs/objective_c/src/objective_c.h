// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_OBJECTIVE_C_H_
#define OBJECTIVE_C_SRC_OBJECTIVE_C_H_

#include "include/dart_api_dl.h"
#include "objective_c_runtime.h"

// Dispose helper for ObjC blocks that wrap a Dart closure.
void disposeObjCBlockWithClosure(ObjCBlockImpl* block);

// Returns whether the block is valid and live. The pointer must point to
// readable memory, or be null. May (rarely) return false positives.
bool isValidBlock(ObjCBlockImpl* block);

// Returns a new Dart_FinalizableHandle that will clean up the object when the
// Dart owner is garbage collected.
Dart_FinalizableHandle newFinalizableHandle(
    Dart_Handle owner, ObjCObject *object);

// Delete a finalizable handle. Doesn't run the finalization callback, so
// doesn't clean up the assocated pointer.
void deleteFinalizableHandle(Dart_FinalizableHandle handle, Dart_Handle owner);

// Returns a newly allocated bool* (initialized to false) that will be deleted
// by a Dart_FinalizableHandle when the owner is garbage collected.
bool* newFinalizableBool(Dart_Handle owner);

#endif  // OBJECTIVE_C_SRC_OBJECTIVE_C_H_
