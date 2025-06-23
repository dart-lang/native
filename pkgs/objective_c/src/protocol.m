// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "protocol.h"

#import <Foundation/NSDictionary.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSValue.h>
#import <objc/runtime.h>

#if !__has_feature(objc_arc)
#error "This file must be compiled with ARC enabled"
#endif

@implementation DOBJCDartProtocolBuilder {
  @public NSMutableDictionary *methods;
  Class clazz;
}

- (instancetype)initWithClassName: (const char*)name {
  methods = [NSMutableDictionary new];
  clazz = objc_allocateClassPair([DOBJCDartProtocol class], name, 0);
  return self;
}

- (void)implementMethod:(SEL)sel withBlock:(void*)block
    withTrampoline:(void*)trampoline withSignature:(char*)signature {
  class_addMethod(clazz, sel, trampoline, signature);
  NSValue* key = [NSValue valueWithPointer:sel];
  @synchronized(methods) {
    [methods setObject:(__bridge id)block forKey:key];
  }
}

- (void)addProtocol:(Protocol*) protocol {
  class_addProtocol(clazz, protocol);
}

- (void)registerClass {
  objc_registerClassPair(clazz);
}

- (DOBJCDartProtocol*)buildInstance: (Dart_Port)port {
  DOBJCDartProtocol* inst = [clazz alloc];
  return [inst initDOBJCDartProtocolFromDartProtocolBuilder:self
               withDisposePort:port];
}

- (void)dealloc {
  objc_disposeClassPair(clazz);
}

@end

@implementation DOBJCDartProtocol {
  DOBJCDartProtocolBuilder* builder;
  Dart_Port dispose_port;
}

- (id)getDOBJCDartProtocolMethodForSelector:(SEL)sel {
  return [builder->methods objectForKey:[NSValue valueWithPointer:sel]];
}

- (instancetype)initDOBJCDartProtocolFromDartProtocolBuilder:
    (DOBJCDartProtocolBuilder*)builder_
    withDisposePort:(Dart_Port)port {
  builder = builder_;
  dispose_port = port;
  return self;
}

- (void)dealloc {
  if (dispose_port != ILLEGAL_PORT) {
    Dart_PostInteger_DL(dispose_port, 0);
  }
}

@end
