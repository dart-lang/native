// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef OBJECTIVE_C_SRC_OBJECTIVE_C_H_
#define OBJECTIVE_C_SRC_OBJECTIVE_C_H_

#include "objective_c_runtime.h"

// Dispose helper for ObjC blocks that wrap a Dart closure.
void disposeObjCBlockWithClosure(ObjCBlock* block);

// Returns whether the block is valid and live. The pointer must point to
// readable memory, or be null. May (rarely) return false positives.
bool isValidBlock(ObjCBlock* block);

// Returns whether the pointer is part of a readable page of memory.
bool isReadableMemory(void* ptr);

#endif  // OBJECTIVE_C_SRC_OBJECTIVE_C_H_
