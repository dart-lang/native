// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// TODO(#660): Temporarily separated from dartjni.h to prevent unnecessary
// copies for based bindings. Will be merged with dartjni.h once the C-based
// bindings are removed.

#pragma once

#include "dartjni.h"
#include "include/dart_api_dl.h"

FFI_PLUGIN_EXPORT intptr_t InitDartApiDL(void* data);

FFI_PLUGIN_EXPORT
JniResult DartException__ctor(jstring message);

FFI_PLUGIN_EXPORT
JniResult PortContinuation__ctor(int64_t j);

FFI_PLUGIN_EXPORT
JniResult PortProxy__newInstance(jobject binaryName,
                                 int64_t port,
                                 int64_t functionPtr);

FFI_PLUGIN_EXPORT void resultFor(CallbackResult* result, jobject object);

FFI_PLUGIN_EXPORT
Dart_FinalizableHandle newJObjectFinalizableHandle(Dart_Handle object,
                                                   jobject reference,
                                                   jobjectRefType refType);

FFI_PLUGIN_EXPORT
Dart_FinalizableHandle newBooleanFinalizableHandle(Dart_Handle object,
                                                   bool* reference);

FFI_PLUGIN_EXPORT
void deleteFinalizableHandle(Dart_FinalizableHandle finalizableHandle,
                             Dart_Handle object);
