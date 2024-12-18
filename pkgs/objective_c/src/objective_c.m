// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/NSThread.h>
#import <dispatch/dispatch.h>

#include "ffi.h"

FFI_EXPORT void DOBJC_runOnMainThread(void (*fn)(void *), void *arg) {
#ifdef NO_MAIN_THREAD_DISPATCH
  fn(arg);
#else
  if ([NSThread isMainThread]) {
    fn(arg);
  } else {
    dispatch_async(dispatch_get_main_queue(), ^{
      fn(arg);
    });
  }
#endif
}
