// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <Foundation/NSDate.h>
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

@interface DOBJCWaiter : NSObject {}
@property(strong) NSCondition* cond;
@property(strong) NSDate* timeout;
@property bool done;
-(instancetype)initWithTimeout: (double)seconds;
-(void)signal;
-(void)wait;
@end

@implementation DOBJCWaiter
-(instancetype)initWithTimeout: (double)seconds {
  if (self) {
    _cond = [[NSCondition alloc] init];
    _timeout = [NSDate dateWithTimeIntervalSinceNow:seconds];
    _done = false;
  }
  return self;
}
-(void)signal {
  [_cond lock];
  _done = true;
  [_cond signal];
  [_cond unlock];
}
-(void)wait {
  [_cond lock];
  while (!_done) {
    if (![_cond waitUntilDate:_timeout]) break;
  }
  [_cond unlock];
}
@end

FFI_EXPORT void* DOBJC_newWaiter(double timeoutSeconds) {
  DOBJCWaiter* waiter = [[DOBJCWaiter alloc] initWithTimeout:timeoutSeconds];
  // __bridge_retained increments the ref count. This is balanced by the
  // __bridge_transfer in DOBJC_awaitWaiter.
  return (__bridge_retained void*)(waiter);
}

FFI_EXPORT void DOBJC_signalWaiter(void* waiter) {
  // __bridge doesn't affect the ref count.
  [(__bridge DOBJCWaiter*)waiter signal];
}

FFI_EXPORT void DOBJC_awaitWaiter(void* waiter) {
  [(__bridge_transfer DOBJCWaiter*)waiter wait];
}
