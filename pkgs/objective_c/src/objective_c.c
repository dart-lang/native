// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "include/dart_api_dl.h"
#include "objective_c.h"
#include "objective_c_runtime.h"

// Dispose helper for ObjC blocks that wrap a Dart closure. For these blocks,
// the target is an int ID, and the dispose_port is listening for these IDs.
void disposeObjCBlockWithClosure(ObjCBlock* block) {
  Dart_PostInteger_DL(block->dispose_port, (Dart_Port)block->target);
}
