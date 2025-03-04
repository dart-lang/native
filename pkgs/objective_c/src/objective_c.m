// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSThread.h>
#import <dispatch/dispatch.h>

#include "ffi.h"
#include "os_version.h"

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
@property bool done;
-(void)signal;
-(void)wait;
@end

@implementation DOBJCWaiter
-(instancetype)init {
  if (self) {
    _cond = [[NSCondition alloc] init];
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
    [_cond wait];
  }
  [_cond unlock];
}
@end

FFI_EXPORT void* DOBJC_newWaiter(void) {
  DOBJCWaiter* w = [[DOBJCWaiter alloc] init];
  // __bridge_retained increments the ref count, __bridge_transfer decrements
  // it, and __bridge doesn't change it. One of the __bridge_retained calls is
  // balanced by the __bridge_transfer in signalWaiter, and the other is
  // balanced by the one in awaitWaiter. In other words, this function returns
  // an object with a +2 ref count, and signal and await each decrement the
  // ref count.
  return (__bridge_retained void*)(__bridge id)(__bridge_retained void*)(w);
}

FFI_EXPORT void DOBJC_signalWaiter(void* waiter) {
  if (waiter) [(__bridge_transfer DOBJCWaiter*)waiter signal];
}

FFI_EXPORT void DOBJC_awaitWaiter(void* waiter) {
  [(__bridge_transfer DOBJCWaiter*)waiter wait];
}

FFI_EXPORT Version DOBJC_getOsVesion(void) {
  NSOperatingSystemVersion objc_version =
      [[NSProcessInfo processInfo] operatingSystemVersion];
  Version c_version;
  c_version.major = objc_version.majorVersion;
  c_version.minor = objc_version.minorVersion;
  c_version.patch = objc_version.patchVersion;
  return c_version;
}
