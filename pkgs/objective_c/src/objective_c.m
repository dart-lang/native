// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSThread.h>
#import <dispatch/dispatch.h>
#import <objc/message.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

#include "ffi.h"
#include "include/dart_api_dl.h"
#include "os_version.h"

_Atomic bool _mainThreadIsListening = false;

FFI_EXPORT intptr_t DOBJC_initializeApi(void* data) {
  dispatch_async(dispatch_get_main_queue(), ^{
    _mainThreadIsListening = true;
  });
  return Dart_InitializeApiDL(data);
}

FFI_EXPORT void DOBJC_runOnMainThread(void (*fn)(void *), void *arg) {
  if (!_mainThreadIsListening || [NSThread isMainThread]) {
    fn(arg);
  } else {
    dispatch_async(dispatch_get_main_queue(), ^{
      fn(arg);
    });
  }
}

@interface DOBJCWaiter : NSObject {}
@property(strong) NSCondition* cond;
@property bool done;
-(void)signal;
-(void)wait;
@end

@implementation DOBJCWaiter
-(instancetype)init {
  self = [super init];
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
  c_version.major = (int)objc_version.majorVersion;
  c_version.minor = (int)objc_version.minorVersion;
  c_version.patch = (int)objc_version.patchVersion;
  return c_version;
}

void DOBJC_freePortBlockArgs(void* peer) {
  @autoreleasepool {
    id args = (__bridge_transfer id)peer;
    (void)args;
  }
}

void DOBJC_finalizePortBlockArgs(void* _, void* peer) {
  DOBJC_runOnMainThread(DOBJC_freePortBlockArgs, peer);
}

void DOBJC_finalizePortBlockWaiter(void* _, void* peer) {
  DOBJC_signalWaiter(peer);
}

FFI_EXPORT void DOBJC_invokeListenerPortBlock(int64_t port, void* args) {
  Dart_CObject cobj;
  cobj.type = Dart_CObject_kNativePointer;
  cobj.value.as_native_pointer.ptr = (intptr_t)args;
  cobj.value.as_native_pointer.size = 0;
  cobj.value.as_native_pointer.callback = DOBJC_finalizePortBlockArgs;

  if (!Dart_PostCObject_DL(port, &cobj)) {
    DOBJC_finalizePortBlockArgs(NULL, args);
  }
}

FFI_EXPORT void DOBJC_invokeBlockingPortBlock(
    int64_t port, void* args, void* waiter) {
  Dart_CObject cargs;
  cargs.type = Dart_CObject_kNativePointer;
  cargs.value.as_native_pointer.ptr = (intptr_t)args;
  cargs.value.as_native_pointer.size = 0;
  cargs.value.as_native_pointer.callback = DOBJC_finalizePortBlockArgs;

  Dart_CObject cwaiter;
  cwaiter.type = Dart_CObject_kNativePointer;
  cwaiter.value.as_native_pointer.ptr = (intptr_t)waiter;
  cwaiter.value.as_native_pointer.size = 0;
  cwaiter.value.as_native_pointer.callback = DOBJC_finalizePortBlockWaiter;

  Dart_CObject* cobjArray[] = {&cargs, &cwaiter};
  Dart_CObject cobj;
  cobj.type = Dart_CObject_kArray;
  cobj.value.as_array.values = cobjArray;
  cobj.value.as_array.length = sizeof(cobjArray) / sizeof(cobjArray[0]);

  if (!Dart_PostCObject_DL(port, &cobj)) {
    DOBJC_finalizePortBlockArgs(NULL, args);
    DOBJC_finalizePortBlockWaiter(NULL, waiter);
  }
}

@interface PortBlockFinalizer : NSObject {
  int64_t port;
}
- (instancetype)initWithPort:(int64_t) _port;
@end

@implementation PortBlockFinalizer
- (instancetype)initWithPort:(int64_t) _port {
  if (self = [super init]) {
    port = _port;
  }
  return self;
}
- (void)dealloc {
  Dart_CObject cobj;
  cobj.type = Dart_CObject_kNull;
  Dart_PostCObject_DL(port, &cobj);
}
@end

static const char BLOCK_FINALIZER_KEY;

FFI_EXPORT void DOBJC_attachPortBlockFinalizer(void* block, int64_t port) {
  PortBlockFinalizer* dtor = [[PortBlockFinalizer alloc] initWithPort:port];
  objc_setAssociatedObject(
      (__bridge id)block, &BLOCK_FINALIZER_KEY, dtor,
      OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
