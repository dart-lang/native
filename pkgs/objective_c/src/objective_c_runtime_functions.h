// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This file exposes a subset of the Objective C runtime. Ideally we'd just run
// ffigen directly on the runtime headers that come with XCode, but those
// headers don't have everything we need (e.g. the ObjCBlock struct).

#ifndef OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_FUNCTIONS_H_
#define OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_FUNCTIONS_H_

#include "include/dart_api_dl.h"
#include "objective_c_runtime_types.h"

ObjCSelector* sel_registerName(const char *name);
ObjCObject* objc_getClass(const char *name);
ObjCObject* objc_retain(ObjCObject* object);
void objc_release(ObjCObject* object);

// The signature of this function is just a placeholder. This function is used by
// every method invocation, and is cast to every signature we need.
void objc_msgSend();
void objc_msgSend_fpret();
void objc_msgSend_stret();

extern void* const _NSConcreteGlobalBlock;

ObjCBlock* _Block_copy(ObjCBlock* object);
void _Block_release(ObjCBlock* object);

#endif  // OBJECTIVE_C_SRC_OBJECTIVE_C_RUNTIME_FUNCTIONS_H_
